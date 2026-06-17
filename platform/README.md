# platform

Main HashiCorp Terraform configuration for the platform infrastructure.

This root module provisions the shared platform network, a zonal Google
Kubernetes Engine Standard cluster in `europe-west1-b` with one dedicated
managed node pool, and the initial ArgoCD bootstrap.

State is stored in the GCS bucket created by `bootstrap/` under
`prefix = "platform"`. The `google` provider runs as the
`terraform-automation` service account via impersonation, with no service
account keys. For the shared bucket layout, auth model, and recovery commands,
see [`../README.md`](../README.md#remote-state).

## What This Provisions

- Creates the custom-mode platform VPC and a regional subnet in
  `europe-west1`.
- Creates subnet secondary IP ranges named `pods` and `services`.
- Creates a zonal GKE Standard cluster in `europe-west1-b`.
- Removes the default node pool and creates a dedicated managed node pool.
- Creates the public delegated Cloud DNS managed zone
  `gcp.ajdininfrastructure.lol.` for platform add-ons.
- Enables Workload Identity with the standard
  `<project_id>.svc.id.goog` workload identity pool.
- Keeps worker nodes private, so they do not receive public IP addresses.
- Keeps the Kubernetes control plane endpoint publicly reachable.
- Uses the platform VPC, platform subnet, and the `pods` and `services`
  secondary ranges for VPC-native IP allocation.
- Installs ArgoCD into the `argocd` namespace with the Terraform Helm
  provider.
- Installs the initial ArgoCD root App-of-Apps through the `argocd-apps` Helm
  chart.

Terraform only bootstraps ArgoCD. Long-term platform add-ons such as
cert-manager, ExternalDNS, External Secrets Operator, Crossplane, ingress, and
tenant resources are managed from the `gitops` repository after ArgoCD is up.

## Selected GKE Sizing

The managed node pool defaults to:

| Setting | Value |
|---|---|
| Cluster type | Zonal GKE Standard |
| Location | `europe-west1-b` |
| Node count | `3` |
| Machine type | `n2-standard-2` |
| Operating system | Container-Optimized OS with containerd |
| Provisioning model | Regular |
| Boot disk type | Balanced Persistent Disk (`pd-balanced`) |
| Boot disk size | `40` GiB per node |

Three `n2-standard-2` nodes provide a small but usable baseline for shared
platform services while keeping the initial cost profile modest.

## Prerequisites

1. `bootstrap/` has been applied so the remote state bucket and
   `terraform-automation` service account exist.
2. The bootstrap module has enabled the required Google Cloud APIs, including
   `compute.googleapis.com`, `container.googleapis.com`, and
   `dns.googleapis.com`.
3. Your user is listed in `operator_members` for `bootstrap/`, so you hold
   `roles/iam.serviceAccountTokenCreator` on the service account.
4. `gcloud` is installed, authenticated, and pointed at the right project.
5. The platform VPC and subnet are managed in this root module, so the cluster
   can attach directly to them during planning and apply.
6. For ArgoCD bootstrap, the GKE cluster is reachable from the operator
   running Terraform.

## Required Variables

Create `terraform.tfvars` locally. This file is gitignored and must not be
committed.

| Variable | Default | Notes |
|---|---|---|
| `project_id` | required | Same project as `bootstrap/`. |
| `tf_sa_account_id` | `terraform-automation` | Must match `bootstrap/`. |
| `region` | `europe-west1` | Provider default region. |
| `zone` | `europe-west1-b` | Zonal GKE cluster location. |
| `cluster_name` | `group-f-platform-gke` | GKE cluster name. |
| `node_pool_name` | `primary-pool` | Dedicated managed node pool name. |
| `node_min_count` | `1` | Minimum worker nodes per zone when autoscaling. |
| `node_max_count` | `5` | Maximum worker nodes per zone when autoscaling. |
| `node_machine_type` | `n2-standard-2` | Worker machine type. |
| `node_boot_disk_size_gb` | `40` | Balanced PD boot disk size per node. |
| `cluster_deletion_protection` | `false` | Allows cluster deletion for environment cleanup. |
| `delegated_dns_managed_zone_name` | `gcp-ajdininfrastructure-lol` | Public Cloud DNS managed zone for `gcp.ajdininfrastructure.lol.`. |
| `master_ipv4_cidr_block` | `172.16.0.0/28` | Private control plane CIDR used for cluster-to-node communication. |
| `argocd_namespace` | `argocd` | Namespace where ArgoCD is installed. |
| `argocd_chart_repository` | `https://argoproj.github.io/argo-helm` | Helm repository for the ArgoCD chart. |
| `argocd_chart_name` | `argo-cd` | ArgoCD Helm chart name. |
| `argocd_chart_version` | `9.5.17` | Pinned ArgoCD chart version. |
| `argocd_apps_chart_name` | `argocd-apps` | Helm chart used to install the ArgoCD root App-of-Apps. |
| `argocd_apps_chart_version` | `2.0.5` | Pinned argocd-apps chart version. |
| `argocd_root_application_name` | `root` | Name of the Terraform-managed root ArgoCD Application. |
| `gitops_repo_url` | `https://github.com/Infrastructure-Engineering-PT-Group-F/gitops.git` | GitOps repository reconciled by ArgoCD. |
| `gitops_target_revision` | `main` | Git revision reconciled by the root Application. |
| `gitops_root_application_path` | `platform` | Path containing child ArgoCD Application manifests. |

## Network Layout

One **custom-mode VPC** with one regional subnet in `europe-west1`. The
subnet carries two secondary ranges so GKE can run in **VPC-native**
(alias-IP) mode.

| Range | Purpose | Default CIDR | Variable |
|---|---|---|---|
| Subnet primary | Node IPs | `10.0.0.0/24` | `subnet_cidr` |
| Secondary `pods` | Pod IPs | `10.10.0.0/16` | `pods_cidr` |
| Secondary `services` | Service IPs | `10.20.0.0/20` | `services_cidr` |

Notes:

- VPC name `vpc-platform` (`var.vpc_name`); subnet name
  `vpc-platform-europe-west1` so a second region could be added later
  without rename.
- `private_ip_google_access = true` on the subnet - nodes reach
  `*.googleapis.com` without external IPs or Cloud NAT.
- **Secondary range sizes are baked at create time.** Changing
  `pods_cidr` or `services_cidr` after the subnet exists triggers
  destroy/recreate, which takes down the cluster. Pick once with headroom
  - the defaults are GKE's own recommendation.
- The GKE cluster uses `google_compute_network.platform`,
  `google_compute_subnetwork.platform`, and the fixed secondary range names
  `pods` and `services`.
- The GKE cluster uses private nodes and reserves
  `master_ipv4_cidr_block` for control plane communication while keeping the
  control plane endpoint publicly reachable.

## Delegated DNS Zone

`dns.tf` manages the public Cloud DNS zone for
`gcp.ajdininfrastructure.lol.`. The zone name defaults to
`gcp-ajdininfrastructure-lol`, and outputs expose the zone name, DNS name, and
authoritative name servers so the domain delegation can be documented outside
Terraform. ExternalDNS and cert-manager receive Workload Identity service
accounts with `roles/dns.admin` scoped to this managed zone only.

## Outbound Internet (Cloud NAT)

Nodes have no external IPs, so reaching the public internet needs egress NAT.
`nat.tf` adds a regional **Cloud Router** plus **Cloud NAT** gateway on the
platform VPC:

- `nat_ip_allocate_option = "AUTO_ONLY"` - Google allocates ephemeral NAT IPs.
  No reserved static egress IP.
- `source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"` -
  NATs the subnet primary and the `pods`/`services` secondary ranges.
- `log_config` is enabled with `ERRORS_ONLY` to surface dropped egress
  cheaply.

## ArgoCD Bootstrap

ArgoCD itself is installed with a Terraform-managed Helm release. The release
creates the `argocd` namespace if needed, keeps `argocd-server` as a
`ClusterIP` service, and does not create an ingress. Use local port-forwarding
for initial validation:

```sh
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

After ArgoCD is installed, Terraform installs a second Helm release using the
`argocd-apps` chart. That release creates the root App-of-Apps and depends on
the main ArgoCD Helm release, keeping the bootstrap close to a single Terraform
apply while avoiding plan-time dependency on ArgoCD custom resource schemas.

The root Application points at
`https://github.com/Infrastructure-Engineering-PT-Group-F/gitops.git`,
revision `main`, path `platform`, and includes only `*/application.yaml`.

## Run

```sh
gcloud auth application-default login
cd infrastructure/platform
terraform init                    # initialize providers and backend
terraform plan -out tfplan        # write the reviewed plan to a file
```
`terraform init` creates the `platform/` prefix in the bucket on first run -
no migration step needed, unlike `bootstrap/`.
`terraform apply` must be executed manually by the team after reviewing the
plan:

```sh
terraform apply tfplan
```

Do not run `terraform apply` from automation.

## Day-to-Day Commands

```sh
terraform state list              # inspect managed resources
terraform output                  # read exported values
terraform plan                    # preview in-place changes
terraform fmt -recursive          # format Terraform files
terraform validate                # verify configuration syntax and schema
```

## Troubleshooting

- `Error refreshing state: ... 403 ... storage.objects.get`: your ADC does not
  have access to the state bucket. Re-check bootstrap and operator access.
- `Error: failed to get a token ... iam.serviceAccountTokenCreator`: your user
  is not allowed to impersonate the `terraform-automation` service account.
- `bucket ... does not exist` during `terraform init`: bootstrap has not been
  applied yet.
- GKE network or secondary range errors during planning/apply usually mean the
  platform VPC/subnet resources or their `pods`/`services` secondary ranges do
  not match what the cluster expects.
