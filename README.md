# infrastructure

Terraform IaC for the FH Burgenland Group F platform: VPC, GKE, IAM / Workload
Identity, and platform addons. Provisions an empty but ready cluster. 
Tenant/application logic lives in the `gitops/` repo.

## IaC tool

**Terraform** (HashiCorp).

- Provider floor and version pins: `platform/versions.tf`
- Provider config (project / region / zone): `platform/providers.tf`, `platform/variables.tf`
- Default region `europe-west1`, zone `europe-west1-b`.

## Layout

Each Terraform root module lives in its own folder so they are clearly separate:

- `bootstrap/` — one-time seed module run by an operator with their own
  ADC. Creates the least-privilege `terraform-automation` service account and
  enables the APIs needed to impersonate it. See [bootstrap/README.md](bootstrap/README.md).
- `platform/` — the main platform config (VPC, GKE, addons). Impersonates the
  SA created by `bootstrap/`.

## Provisioning identity

The `platform/` module runs as the `terraform-automation` SA via
`impersonate_service_account`. No long-lived SA keys; operators with
`roles/iam.serviceAccountTokenCreator` on the SA mint short-lived tokens. Roles
on the SA are granted incrementally per issue (least privilege).
