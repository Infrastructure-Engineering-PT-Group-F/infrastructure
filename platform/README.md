# platform

Main Terraform configuration for the GKE platform (VPC, GKE, IAM, addons).
Provisions an empty but ready cluster. Tenant logic lives in `gitops` repo.

State is stored in the GCS bucket created by `bootstrap/` under
`prefix = "platform"`. The `google` provider runs as the
`terraform-automation` SA via impersonation - no SA keys. For the shared
bucket layout, auth model, and recovery commands, see
[`../README.md`](../README.md#remote-state).

## Prerequisites

1. `bootstrap/` has been applied — SA + state bucket exist; SA holds bucket-
   scoped `roles/storage.objectAdmin`. See `../bootstrap/README.md`.
2. Your user is listed in `operator_members` for `bootstrap/`, so you hold
   `roles/iam.serviceAccountTokenCreator` on the SA.
3. `gcloud` installed and pointed at the right project.

## Required tfvars

| Variable | Default | Notes |
|---|---|---|
| `project_id` | — (required) | Same project as `bootstrap/`. |
| `tf_sa_account_id` | `terraform-automation` | Must match `bootstrap/`. |
| `region` | `europe-west1` | |
| `zone` | `europe-west1-b` | |

Create `terraform.tfvars` (gitignored) with at least `project_id`.

## Run

```sh
gcloud auth application-default login        # if not already
cd infrastructure/platform
terraform init                               # connects to gs://<project>-tfstate/platform/
terraform plan -out tfplan
terraform apply tfplan                       # operator applies; cost-sensitive
```

`terraform init` creates the `platform/` prefix in the bucket on first run —
no migration step needed (unlike `bootstrap/`).

## Day-to-day commands

```sh
terraform state list                         # what we manage
terraform output                             # platform outputs
terraform plan                               # dry-run before any change
terraform fmt -recursive                     # before committing
```

## Troubleshooting

- **`Error refreshing state: ... 403 ... storage.objects.get`** — your ADC
  doesn't have access to the state bucket. Re-check that you ran the bootstrap
  apply against this project, and that your account has at least
  `roles/storage.objectViewer` on the bucket (operator's project-level
  `roles/editor` covers this).
- **`Error: failed to get a token ... iam.serviceAccountTokenCreator`** — you
  are not in `operator_members`. Re-apply `bootstrap/` with your account
  added, or ask the bootstrap operator to add you.
- **`bucket ... does not exist`** during `terraform init` — bootstrap hasn't
  been applied yet; complete `bootstrap/` first.
