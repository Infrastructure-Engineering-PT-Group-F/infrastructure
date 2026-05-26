# infrastructure

Terraform IaC for the FH Burgenland Group F platform: VPC, GKE, IAM / Workload
Identity, and platform addons. Provisions an empty but ready cluster. 
Tenant/application logic lives in the `gitops/` repo.

## IaC tool

**Terraform** (HashiCorp).

- Provider floor and version pins: `versions.tf`
- Provider config (project / region / zone): `providers.tf`, `variables.tf`
- Default region `europe-west1`, zone `europe-west1-b`.
