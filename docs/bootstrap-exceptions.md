# Manual Bootstrap Exceptions

The platform is provisioned through Infrastructure as Code (Terraform in this
repo) and GitOps (ArgoCD in the `gitops/` repo). A small number of steps cannot
reasonably be automated because they create the very accounts, identities, or
state that the automation depends on. This document lists those manual
exceptions, why each one exists, when it has to happen, and who owns it.

The owners below are stated as roles. The team should map each role to a named
person before handover.

## Automated vs Manual

Everything after the one-time seed is automated:

- **Terraform (`infrastructure/`)** provisions the VPC, the zonal GKE cluster
  and node pool, IAM and Workload Identity, runtime-critical project IAM
  grants, the Workload Identity Federation trust for CI, and the remote state
  bucket
- **GitOps (`gitops/`)** provisions the in-cluster platform add-ons and the
  per-tenant resources through the ArgoCD app-of-apps pattern

The steps in the next section are the only ones performed by hand.

## Exceptions

| #  | Manual step                                                  | Why it is manual                                                                                                                                                                                                                                         | When                                                                                                                                                   | Owner                 |
| -- | ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------- |
| 1  | GitHub organization and repository creation                  | The IaC that configures CI trust lives inside the org, so the org and repos must exist before any automation can run                                                                                                                                     | Once, before everything else                                                                                                                           | Project lead          |
| 2  | GCP project creation, billing link, and credits              | Creating a project and attaching a billing account requires an identity with billing rights and is a prerequisite to every GCP API call. Education credits are applied out of band.                                                                      | Once, before the Terraform seed                                                                                                                        | Billing account owner |
| 3  | Domain registration and registrar nameserver delegation      | Buying a domain is a commercial transaction, and delegating nameservers happens at the registrar, outside the cluster. The DNS provider is still to be decided.                                                                                          | Before cert-manager and ExternalDNS can serve public hostnames                                                                                         | Domain owner          |
| 4  | Initial operator access for the seed                         | The bootstrap module creates the least-privilege `terraform-automation` service account, so before it exists a human operator must run the seed with their own elevated credentials.                                                                     | Once, immediately before the bootstrap apply                                                                                                           | Operator              |
| 5  | Bootstrap first apply with local state, then state migration | The bootstrap module creates its own remote state bucket, so the first apply runs against local state and is then migrated with `terraform init -migrate-state`.                                                                                         | Once, during the bootstrap apply                                                                                                                       | Operator              |
| 6  | Lecturer access (GitHub admin and cluster-admin)             | Lecturer `@muhlba91` is granted repository admin in GitHub and `cluster-admin` in the cluster. This is currently applied by hand and not yet codified.                                                                                                   | Before evaluation and handover                                                                                                                         | Project lead          |
| 7  | Tenant runtime secret value seeding                          | The AVWX API token and the GHCR pull token are externally issued and cannot be auto-generated, so their values are added to the Terraform-created Secret Manager secrets by a human operator. No value is committed to Git or stored in Terraform state. | After the platform apply has created the `avwx-api-key` and `ghcr-pull` secrets, and before the tenant runtime-secret ESO delivery is expected to sync | Operator              |

## Detail

### 1. GitHub organization and repository creation

The GitHub organization `Infrastructure-Engineering-PT-Group-F` and its repos
were created through the GitHub UI. This is a classic chicken and egg case: the
Workload Identity Federation trust in `bootstrap/wif.tf` is scoped to this
organization, so the organization has to exist first. No automation can create
the home it would itself live in.

### 2. GCP project creation, billing link, and credits

The Google Cloud project and its billing link are created before any Terraform
runs, because every GCP API call and the remote state bucket depend on an
active, billable project. Education credits are redeemed separately and are
tracked alongside the capacity and cost planning work.

### 3. Domain registration and registrar nameserver delegation

The domain is registered at a registrar and its nameservers are delegated to the
chosen DNS provider. Both actions are external to the cluster. Until the
delegation is in place, cert-manager cannot complete ACME DNS-01 challenges and
ExternalDNS cannot publish records. The DNS provider choice is still open.

### 4. Initial operator access for the seed

The `bootstrap/` module is the seed that creates the `terraform-automation`
service account and grants operators `roles/iam.serviceAccountTokenCreator` on
it. The first operator to run the seed therefore cannot impersonate that service
account yet and instead authenticates with their own Application Default
Credentials, which must carry enough rights to create the service account, the
state bucket, and to enable the required APIs. See
[`../bootstrap/README.md`](../bootstrap/README.md).

### 5. Bootstrap first apply with local state, then state migration

Because `bootstrap/` creates the bucket that will hold remote state, its first
apply has nowhere remote to store state and runs locally. After that single
apply the state is migrated into the bucket with
`terraform init
-migrate-state`. This is the only state-handling glue point in
the project and is also summarized in the
[root README](../README.md#bootstrap-exception).

### 6. Lecturer access

Lecturer `@muhlba91` receives repository admin on the GitHub side and
`cluster-admin` on the Kubernetes side so the work can be reviewed and operated.
At present both are applied manually. Codifying the cluster-admin binding as IaC
or GitOps is a possible later improvement that would remove this exception.

### 7. Tenant runtime secret value seeding

The platform Terraform (`platform/secrets.tf`) creates the Secret Manager
secrets `avwx-api-key` and `ghcr-pull` as empty containers and grants the
External Secrets Operator service account a least-privilege
`roles/secretmanager.secretAccessor` binding per secret. Terraform does not
create the secret values, so no payload enters Terraform state. The values are
externally issued credentials that cannot be auto-generated, which the
assignment explicitly permits storing manually in the secrets management
platform.

Run this after the platform Terraform apply has created the two secrets and
before the tenant runtime-secret ESO delivery is expected to sync:

```sh
PROJECT_ID=<PROJECT_ID>

read -rs AVWX_TOKEN; echo
read -rs GHCR_PAT;   echo

printf '%s' "$AVWX_TOKEN" | gcloud secrets versions add avwx-api-key \
  --data-file=- --project="$PROJECT_ID"
printf '%s' "$GHCR_PAT" | gcloud secrets versions add ghcr-pull \
  --data-file=- --project="$PROJECT_ID"

unset AVWX_TOKEN GHCR_PAT
```

This creates no service-account key, commits no plaintext value, and keeps the
values out of Git and Terraform state. On a full teardown and rebuild, the two
values must be re-seeded before the ESO delivery becomes Ready.

## Related Documentation

- [Root README](../README.md) for the auth model and remote state layout.
- [`bootstrap/README.md`](../bootstrap/README.md) for the seed procedure and
  state migration.
- [`platform/README.md`](../platform/README.md) for day-to-day provisioning.
