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

- `platform/` — the main platform config (VPC, GKE, addons).
