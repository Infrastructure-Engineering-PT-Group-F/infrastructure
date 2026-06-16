# Access and Permission Model

This document describes the intended access and permission model for the
platform across GitHub, Google Cloud, and Kubernetes, plus lecturer access. It
stays at a high level and contains no secrets, project identifiers, service
account emails, or key material.

## Principles

The model follows a small set of rules everywhere:

- **Least privilege.** Every identity is granted only the permissions it needs
  and those permissions are added incrementally as features land rather than up
  front
- **Keyless authentication.** No long-lived service account keys and no stored
  cloud credential, Identities mint short-lived tokens on demand
- **Auditability.** Every change lands through a reviewed pull request that
  references an issue, on a rebase-only linear history
- **Secrets stay out of git.** Sensitive values are managed outside the
  repositories and are never committed

## GitHub Access

The work lives in the `Infrastructure-Engineering-PT-Group-F` organization.

| Repository       | Visibility | Purpose                                |
| ---------------- | ---------- | -------------------------------------- |
| `infrastructure` | public     | Terraform IaC                          |
| `gitops`         | public     | ArgoCD app-of-apps and service catalog |
| `backend`        | public     | Application backend and its image      |
| `frontend`       | private    | Application frontend and its image     |

- Team members hold write access to the repositories
- The default branch is protected. Changes arrive through pull requests that are
  reviewed, pass CI, reference an issue, and use Conventional Commits
- CI authenticates to Google Cloud through Workload Identity Federation, so no
  cloud keys are stored as GitHub secrets

## Lecturer Access

Lecturer `@muhlba91` needs administrative visibility on both the source and the
running platform. This is tracked as a checklist because it is currently applied
by hand (see [bootstrap-exceptions.md](bootstrap-exceptions.md)).

- [ ] Repository admin on the organization repositories.
- [ ] `cluster-admin` on the GKE cluster.

## Google Cloud IAM

GCP provisioning uses a single automation identity plus per-workload identities.

- **Terraform automation service account.** The only identity that provisions
  GCP resources. It is impersonated rather than keyed. Its roles are granted
  incrementally per issue and never include `owner` or `editor`. For state it
  holds a bucket-scoped storage role rather than project-wide storage admin.
- **Operators.** Human operators hold `roles/iam.serviceAccountTokenCreator` on
  the automation service account so they can mint short-lived tokens to run
  Terraform. They do not hold broad project roles for day-to-day work.
- **Per-workload service accounts.** The GitOps controller, Crossplane, and the
  application workloads each get their own Google service account, scoped to
  only what that workload requires. Roles are attached as each capability is
  implemented.

## Workload Identity and OIDC

Two keyless paths replace what would otherwise be service account keys:

- **CI to Google Cloud (Workload Identity Federation).** GitHub Actions present
  a short-lived OIDC token. The federation pool trusts the GitHub organization
  and the IaC pipeline uses it to impersonate the Terraform automation service
  account. No service account keys exist in CI.
- **In-cluster to Google Cloud (GKE Workload Identity).** Kubernetes service
  accounts are bound to Google service accounts, so pods receive short-lived
  Google credentials from the node metadata server. No key files are mounted
  into containers.

## Kubernetes RBAC

Cluster authorization is kept coarse for operators and tight for workloads.

- **Cluster administrators.** Platform operators and the lecturer hold
  `cluster-admin`
- **GitOps controller.** ArgoCD reconciles the desired state under its own
  service account
- **Per-application service accounts.** Each application runs under a dedicated
  Kubernetes service account bound to its Google service account through
  Workload Identity, with no broad cluster roles
- **Tenant isolation (planned).** Each tenant namespace will receive namespaced
  RBAC together with NetworkPolicies and resource quotas, so tenants cannot act
  across namespace boundaries

## What Is Intentionally Not Documented Here

This document deliberately omits project identifiers, service account emails,
tokens, and any other sensitive values. Application and tenant secrets are
planned to be managed through Google Secret Manager and the External Secrets
Operator, and are never stored in the repositories.

## Related Documentation

- [Root README](../README.md) for provisioning identity and the remote state
  auth model.
- [`bootstrap/README.md`](../bootstrap/README.md) for the seed procedure and
  operator access.
- [`bootstrap-exceptions.md`](bootstrap-exceptions.md) for the manual access
  steps, including lecturer access.
