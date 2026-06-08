# bootstrap

One-time **seed** module, run by a human operator with their own credentials (ADC).
It creates:

- the least-privilege `terraform-automation` service account that the
  `platform/` module impersonates for all later provisioning, and
- the GCS bucket that holds remote Terraform state for both `bootstrap/` and
  `platform/`, with bucket-scoped `roles/storage.objectAdmin` on the SA.

For the shared bucket layout, auth model, and recovery commands, see
[`../README.md`](../README.md#remote-state).

## Required tfvars

| Variable | Example | Notes |
|---|---|---|
| `project_id` | `your-gcp-project-id` | Must have billing enabled. |
| `state_bucket_name` | `<project_id>-tfstate` | Globally unique. |
| `operator_members` | `["user:you@example.com"]` | IAM members allowed to impersonate the SA. |

`region` defaults to `europe-west1`; override only if you change the cluster
region.

## Run

```sh
gcloud auth application-default login
nano terraform.tfvars   # set project_id, state_bucket_name, operator_members
```

### Stage 1 — first apply (local state)

The gcs backend points at a bucket that does not exist yet. Hide `backend.tf`
from Terraform's loader (it only picks up `*.tf` files) so this first run uses
local state:

```sh
mv backend.tf backend.tf.disabled
terraform init -reconfigure
terraform plan -out tfplan
terraform apply tfplan
```

Stage 1 creates the SA and the bucket.


### Stage 2 — restore backend.tf and migrate state into the bucket

```sh
mv backend.tf.disabled backend.tf       # restore the gcs backend
terraform init -migrate-state           # answer "yes" to copy local state to gcs
rm -f terraform.tfstate*                # archive locally; never commit
```

From now on `bootstrap/` runs against remote state. Subsequent role grants on
the SA (added incrementally per issue) `apply` against the bucket.

## Verify

```sh
terraform output -raw terraform_service_account_email
terraform output -raw state_bucket_name
gcloud auth print-access-token \
  --impersonate-service-account="$(terraform output -raw terraform_service_account_email)"
gcloud storage buckets describe "gs://$(terraform output -raw state_bucket_name)" \
  --format='value(versioning.enabled,iamConfiguration.publicAccessPrevention)'
```

## Extend the SA's permissions

The SA gets new roles **incrementally** — never broad
roles like `roles/owner` or `roles/editor`. Two kinds of grants:

- **Project-wide roles** — listed in `var.tf_sa_roles` (default in
  `variables.tf`). The `google_project_iam_member.terraform_roles` resource
  expands the list with `for_each`.
- **Resource-scoped roles** — bound directly to the target resource (e.g.
  the bucket-scoped `roles/storage.objectAdmin` in `state_bucket.tf`). Prefer
  these whenever a role only needs to apply to one resource.

### Add a project-wide role (typical case)

1. In the PR for the issue that needs the new capability, append the role to
   the **default** of `tf_sa_roles` in `bootstrap/variables.tf`. Example for an
   issue that needs the SA to manage Compute networks:

   ```hcl
   default = [
     "roles/serviceusage.serviceUsageAdmin",
     "roles/compute.networkAdmin",     # added for #NN — VPC
   ]
   ```

   The trailing comment names the issue so reviewers can audit *why* each
   role exists.

2. Apply the bootstrap module (operator with ADC; remote state):

   ```sh
   cd infrastructure/bootstrap
   terraform plan -out tfplan          # should show one IAM addition
   terraform apply tfplan
   ```

3. Verify:

   ```sh
   PROJECT_ID=<your-project-id>
   SA=$(terraform output -raw terraform_service_account_email)
   gcloud projects get-iam-policy "$PROJECT_ID" \
     --flatten=bindings \
     --filter="bindings.members:serviceAccount:$SA" \
     --format='value(bindings.role)'
   ```

### Add a resource-scoped role

When the role only needs to apply to one resource (a specific bucket, secret,
or SA), bind it on the resource — don't add to `tf_sa_roles`. Example pattern
(already used for state-bucket access):

```hcl
resource "google_storage_bucket_iam_member" "tf_sa_<purpose>" {
  bucket = google_storage_bucket.<name>.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}
```

### Remove a role

Delete the entry from `tf_sa_roles` (project-wide) or delete the
`google_*_iam_member` resource (resource-scoped). `terraform plan` will show
the binding removal; `terraform apply` revokes it. Never edit IAM in the
console — that drift will be reverted on the next apply.

### Why not `roles/editor`?

`roles/editor` would let the SA do almost anything in the project, defeating
the per-issue audit trail and the "least privilege" assignment rule. A
mis-scoped `apply` could then quietly create resources the team never
reviewed. The incremental list makes every privilege grant a reviewed PR.
