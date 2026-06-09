# infrastructure

Terraform IaC for the FH Burgenland Group F platform: VPC, GKE, IAM / Workload
Identity, and platform addons. Provisions an empty but ready cluster. 
Tenant/application logic lives in the `gitops/` repo.

## IaC tool

**Terraform** (HashiCorp).

- Provider floor and version pins: `platform/versions.tf`
- Provider config (project / region / zone): `platform/providers.tf`, `platform/variables.tf`
- Default platform region `europe-west3`, zone `europe-west3-a`.

## Layout

Each Terraform root module lives in its own folder so they are clearly separate:

- `bootstrap/` — one-time seed module run by an operator with their own ADC.
  Creates the least-privilege `terraform-automation` service account and the
  GCS bucket holding remote Terraform state for both modules. See
  [bootstrap/README.md](bootstrap/README.md).
- `platform/` — the main platform config (VPC, GKE, addons). Impersonates the
  SA created by `bootstrap/` and stores state in the same bucket under a
  separate `prefix`.

## Provisioning identity

The `platform/` module runs as the `terraform-automation` SA via
`impersonate_service_account`. No long-lived SA keys; operators with
`roles/iam.serviceAccountTokenCreator` on the SA mint short-lived tokens. Roles
on the SA are granted incrementally per issue (least privilege).

## Remote state

State for both root modules lives in the GCS bucket created by `bootstrap/`,
separated by `prefix`:

| Module | State key |
|---|---|
| `bootstrap/` | `gs://<project>-tfstate/bootstrap/default.tfstate` |
| `platform/`  | `gs://<project>-tfstate/platform/default.tfstate` |

Bucket properties:

- Uniform bucket-level IAM (no legacy ACLs).
- `public_access_prevention = "enforced"`.
- Object versioning enabled; lifecycle keeps the 5 newest versions.
- Locking is **native** to the GCS backend — no separate lock table.
- SA holds bucket-scoped `roles/storage.objectAdmin`, not project-wide storage admin.

### Auth model

Two independent auth paths during `terraform apply`:

| Concern | Identity | Where configured |
|---|---|---|
| Provisioning GCP resources (provider) | `terraform-automation` SA via impersonation | `<module>/providers.tf` (`impersonate_service_account`) |
| Reading/writing the state blob (backend) | Operator's ADC | `<module>/backend.tf` (default ADC; no override) |

The provider mints short-lived tokens via `iamcredentials.googleapis.com` on
every API call — no key material on disk. The backend uses the operator's ADC
because the SA does not (yet) have a keyless way to be invoked from outside
the operator's machine; once CI is wired up via Workload Identity Federation
(later issue), CI runs will use the SA for both paths.

### State recovery

Versioning is on (5 newer versions kept). To restore an earlier state:

```sh
gcloud storage ls -a gs://<project>-tfstate/<prefix>/default.tfstate
gcloud storage cp \
  gs://<project>-tfstate/<prefix>/default.tfstate#<generation> ./recovered.tfstate
```

### Bootstrap exception

`bootstrap/` creates the bucket itself, so its **first** apply runs against
local state (the bucket doesn't exist yet). After that one apply, state is
migrated into the bucket (`terraform init -migrate-state`). This is the only
documented bootstrap glue-point.

## Operating the modules

There's no Terraform at the repo root — each module is run from its own
folder. Consult the per-module README for variables and the exact
`init`/`plan`/`apply` sequence:

- `bootstrap/README.md` — first-time setup, SA + bucket creation, state migration.
- `platform/README.md` — day-to-day platform provisioning.
