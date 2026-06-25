# Capacity & Cost Planning and Management – Operating Cost Monitoring

## Status and Scope

This preliminary FinOps report supports GitHub issue #6, "Monitoring of operating costs". It documents the relationship between historical planning evidence, current live inventory, current Terraform declarations, and the first available sanitized actual-cost snapshot.

This report fulfills the assignment's Capacity & Cost Planning and Management requirement using a FinOps-oriented method. "Capacity & Cost Planning and Management" is the assessment-aligned scope; "FinOps-oriented" is the operating method used to compare planned capacity, live capacity, and actual billing evidence.

Issue #14, "Initial GCP Capacity and Cost Estimate", is unchanged and remains the immutable historical audit trail. The figure from issue #14 is used only as planning context, not as a like-for-like current baseline.

This report does not modify cloud resources, billing configuration, Terraform resources, Kubernetes resources, Helm releases, or GitHub issues. It also avoids committing billing account identifiers, project identifiers, account names, resource names, IP addresses, credentials, Terraform state, or `.tfvars` values.

## Executive Summary

Actual cost evidence currently shows `10.15 EUR` net for 1-24 June 2026. This is not a full-month cost.

The gross cost was `10.69 EUR`, and recorded savings were `-0.54 EUR`. Google Cloud did not provide a June forecast because historical data was insufficient.

Compute Engine and Kubernetes Engine are the leading service-level drivers. Together they account for `83.84%` of net period-to-date cost, with Compute Engine at `46.40%` and Kubernetes Engine at `37.44%`.

The comparison with the original `448.24 EUR/month` planning estimate is not directly comparable because the reporting period, deployed architecture, service sizing, region, and runtime maturity are materially different. No formal euro variance or percentage variance is calculated against the historical monthly estimate.

## Capacity & Cost Planning and Management Summary

| Dimension | Historical Planning Baseline | Live Capacity / Actual Evidence | Assessment |
| --- | --- | --- | --- |
| Worker capacity | `2` planned workers | `1` live running worker | Lower always-on capacity and lower expected operating cost, with reduced worker-level resilience. |
| Worker type | `e2-standard-2` | `n2-standard-2` | Machine family changed, so worker-count comparison alone is insufficient. |
| Region/location | `europe-west3` | `europe-west1-b` | Future estimates must use current-region assumptions. |
| Database sizing | PostgreSQL, `2 vCPU / 7.5 GiB RAM` | `POSTGRES_18` / `db-f1-micro` | Live database capacity is materially smaller than the planning assumption. |
| Cost evidence | `448.24 EUR/month` planned | `10.15 EUR` net for 1–24 June 2026 actual period-to-date | Useful for governance, not a formal monthly variance. |
| Availability | Historical plan assumption | Live one-worker cost-first pilot topology | Cost-efficient pilot posture, but not highly available. |

The current 10.15 EUR net value is a period-to-date observation, not a complete monthly run rate.

The historical estimate and current actual evidence are not directly comparable as a formal variance because the architecture, capacity, region, database tier, and reporting period differ materially.

## Evidence and Data Quality

The committed CSV is a sanitized service-level derivative of Google Cloud Billing Reports for 1-24 June 2026. It should be treated as preliminary period-to-date evidence.

| Evidence item | Status | Notes |
| --- | --- | --- |
| Historical issue #14 estimate | Available | Immutable planning evidence only. |
| Live GCP inventory | Available | Sanitized aggregate counts and attributes only. |
| Billing Reports service-level costs | Available | Sanitized CSV committed under `docs/finops/evidence/2026-06/`. |
| Billing Reports original screenshot | Pending manual attachment | Must be attached to issue #6 before closure. |
| Billing Reports original downloaded CSV | Pending manual attachment | Must be attached to issue #6 before closure. |
| BigQuery billing export | Unavailable through current CLI environment | No billing-table data was queried. |
| June forecast | Unavailable | Google Cloud did not provide a forecast because historical data was insufficient. |

The evidence coverage is 1-24 June 2026. The CSV filename and folder represent June 2026 evidence, but this report does not describe the values as a complete monthly cost.

## Historical Planning Baseline

Issue #14 recorded an initial planning estimate of `448.24 EUR/month`.

| Planning dimension | Historical issue #14 baseline |
| --- | --- |
| Estimate type | Initial GCP capacity and cost estimate |
| Reporting period | Monthly planning estimate |
| Region | `europe-west3` |
| Workers | `2` |
| Machine type | `e2-standard-2` |
| Boot disk | `80 GiB total` |
| Cloud SQL | PostgreSQL, `2 vCPU / 7.5 GiB RAM` |
| Public load balancer | `1` |
| Media CDN | Included |
| Cost status | `448.24 EUR/month` historical estimate |

This baseline is useful for auditability and explaining how the plan evolved. It is not a direct measure of the current deployed footprint or actual June costs.

## Current Live Architecture

The current live inventory is based on read-only aggregate discovery.

| Area | Live evidence |
| --- | --- |
| GKE clusters | `1` |
| GKE location | `europe-west1-b` |
| VM workers | `1` |
| VM machine type | `n2-standard-2` |
| VM state | `RUNNING` |
| Cloud SQL instances | `1` |
| Cloud SQL region | `europe-west1` |
| Cloud SQL engine | `POSTGRES_18` |
| Cloud SQL tier | `db-f1-micro` |
| External forwarding rules | `1` |
| Cloud Routers | `1` |
| Cloud DNS zones | `1` |
| Cloud Storage buckets | `1` |
| Billing enabled | `yes` |
| BigQuery billing-export metadata discovery | Unavailable |

Current Terraform declarations include the GKE platform cluster, managed node pool defaults, Cloud NAT, Cloud Router, Cloud DNS, Terraform state storage, Secret Manager containers, and ArgoCD bootstrap. Terraform also declares Cloud SQL prerequisites, but not a direct Cloud SQL instance resource.

### Capacity Delta and Availability Trade-Off

The live platform currently uses one running worker instead of two planned workers. This right-sizes always-on capacity for the early platform and coursework workload and reduces operating cost.

One worker is a deliberate cost-first pilot decision, but it is not highly available because worker-level workload resilience is limited. A production-grade high-availability target would require a revised capacity design, at least multiple worker nodes, and a separately recalculated operating-cost baseline.

Current evidence does not prove that autoscaling or the current topology provides high availability, so this report does not claim that it does.

## Actual Cost Snapshot

Actual cost evidence covers 1-24 June 2026 and is not a full-month invoice.

| Service | Gross cost EUR | Savings programmes EUR | Other savings EUR | Net cost EUR | Net share |
| --- | ---: | ---: | ---: | ---: | ---: |
| Compute Engine | 4.71 | 0.00 | 0.00 | 4.71 | 46.40% |
| Kubernetes Engine | 3.80 | 0.00 | 0.00 | 3.80 | 37.44% |
| Cloud Monitoring | 1.04 | 0.00 | 0.00 | 1.04 | 10.25% |
| Networking | 0.90 | 0.00 | -0.54 | 0.36 | 3.55% |
| Cloud SQL | 0.15 | 0.00 | 0.00 | 0.15 | 1.48% |
| Network Security | 0.08 | 0.00 | 0.00 | 0.08 | 0.79% |
| Cloud DNS | 0.01 | 0.00 | 0.00 | 0.01 | 0.10% |
| Total | 10.69 | 0.00 | -0.54 | 10.15 | 100.00% |

The Billing Reports UI showed `10.15 EUR` actual cost for 1-24 June 2026 and `-0.54 EUR` savings.

## Cost-Driver Interpretation

Compute Engine is the largest current cost driver, representing the worker VM footprint behind the platform. Kubernetes Engine is the second largest driver, representing the managed GKE service cost observed in the service-level billing report.

Cloud Monitoring appears as the third largest cost driver in this partial period. This should be reviewed during a full-month update because observability charges can vary with metric volume, retention, and workload behavior.

Networking includes recorded savings of `-0.54 EUR`, lowering its net service-level cost for the period. The live external forwarding rule indicates a network-edge cost driver exists, but ownership must be traced through GitOps or Kubernetes provisioning in a later full-month analysis because it is not declared directly by Terraform.

Cloud SQL currently appears at a small period-to-date cost, consistent with the live evidence showing a very small tier compared with the original planning assumption.

## Plan-to-Actual Comparison and Comparability

The comparison is **not directly comparable**.

| Dimension | Issue #14 historical baseline | Current Terraform declarations | Current live inventory and actual evidence | Comparability note |
| --- | --- | --- | --- | --- |
| Reporting period | Monthly planning estimate | Architecture declaration, not billing data | 1-24 June 2026 period-to-date | Not a full month. |
| Region | `europe-west3` | Defaults indicate `europe-west1` / `europe-west1-b` | `europe-west1` / `europe-west1-b` evidence | Region changed. |
| Worker count | `2` workers | Node pool defaults allow autoscaling from `1` to `5` | `1` running worker VM | Live footprint is smaller. |
| Machine type | `e2-standard-2` | Default `n2-standard-2` | `n2-standard-2` | Machine family changed. |
| Boot-disk model | `80 GiB total` | Default `40 GiB` balanced boot disk per node | Live disk details not included in sanitized inventory | Disk model cannot be fully reconciled from current evidence. |
| Cloud SQL sizing | PostgreSQL, `2 vCPU / 7.5 GiB RAM` | Prerequisites declared, no direct instance resource | PostgreSQL engine, `db-f1-micro` tier | Live tier is materially smaller. |
| Public load balancing | `1` public load balancer | No direct forwarding-rule declaration found | `1` external forwarding rule | Ownership requires GitOps/Kubernetes trace. |
| Media CDN | Included | No current service-level evidence in this report | No Media CDN service-level actual cost evidence | Not evidenced in current snapshot. |
| Cost status | `448.24 EUR/month` estimate | No Terraform price estimate | `10.15 EUR` net for 1-24 June 2026 | No formal variance calculated. |

Because the baseline is a monthly estimate and the actual evidence is a partial period from a different, right-sized architecture, this report intentionally avoids calculating a formal euro variance or percentage variance.

## Facts, Assumptions, and Evidence Gaps

### Proven Facts

- Historical baseline: `448.24 EUR/month`.
- Actual evidence: `10.15 EUR` net, `10.69 EUR` gross, `-0.54 EUR` recorded savings, 1–24 June 2026.
- Live capacity evidence: one GKE cluster, one running `n2-standard-2` worker, and one Cloud SQL instance with `POSTGRES_18` and `db-f1-micro`.
- Billing forecast was unavailable because historical data was insufficient.
- Compute Engine and Kubernetes Engine jointly represent `83.84%` of net period-to-date cost.

### Assumptions and Interpretations

- The live architecture appears deliberately right-sized for an early deployment.
- The current actual-cost snapshot cannot prove a steady-state monthly run rate.
- The lower observed period-to-date cost must not be represented as a proven monthly saving against the historical estimate.

### Evidence Gaps

- No complete post-steady-state calendar month is available.
- BigQuery Billing Export metadata was unavailable from the CLI environment, so no SKU-level attribution was performed.
- The service-level billing evidence does not prove the ownership path of the live external forwarding rule.
- There is no Media CDN cost evidence in the current service-level snapshot; this does not prove that Media CDN is absent.
- The original Billing Reports screenshot and downloaded CSV must be attached manually to Issue #6 before closure.
- The Billing Reports project-filter context must be visible in the manually attached screenshot or export evidence.

## Root Causes of the Current Difference

Planned capacity was two workers; live capacity is one worker, reducing always-on compute capacity and cost but reducing worker-level availability.

Planned and live machine families differ, so worker count alone cannot explain the cost difference. The historical estimate used `e2-standard-2`, while the current live inventory shows `n2-standard-2`.

The region changed from `europe-west3` to `europe-west1-b`, requiring current-region rather than historic-region pricing assumptions for future estimates.

Cloud SQL was materially down-sized from a `2 vCPU / 7.5 GiB RAM` planning assumption to `db-f1-micro`, reducing live database capacity and changing the cost profile.

The actual evidence covers only 1–24 June 2026, and costs began only late in the reporting period according to the Billing Reports view. Google Cloud did not provide a June forecast because historical data was insufficient.

Media CDN was included in the historical estimate but has no service-level actual-cost evidence in this snapshot.

An external forwarding rule exists live but is not directly declared by Terraform; future monthly analysis must trace its ownership through GitOps, Kubernetes provisioning, or another approved provisioning path.

BigQuery export unavailability limits service costs to high-level attribution and prevents SKU-level root-cause analysis.

## Lessons Learned and Follow-Up Controls

Capacity estimates must record the exact region, minimum worker count, machine family, disk model, database tier, availability target, and expected runtime state before pricing.

Historical estimates, current approved operating baseline, and actual billing results are separate controls and must not be merged into one misleading variance number.

A cost-efficient single-worker baseline must explicitly document its availability limitation and the incremental cost of a future high-availability topology.

Record gross cost, savings, and net cost separately. Savings should remain visible instead of being hidden inside the net amount.

Attach the original Billing Reports CSV and screenshot to issue #6 before closure so reviewers can trace the sanitized committed CSV back to source evidence.

Service-level billing data is adequate for monthly governance; BigQuery Billing Export is required later for SKU-level investigation and detailed chargeback.

Every billable edge resource, including forwarding rules and ingress-related components, needs a documented provisioning owner and lifecycle path.

Estimates must be recalibrated after the first complete, steady-state calendar month.

Compare three dimensions separately: the historical issue #14 baseline, the current as-code architecture, and actual billing results. Each answers a different question and should not be collapsed into one variance figure without normalization.

Repeat the report for a complete month and explicitly document whether the architecture changed during the period.

## Operating Cost Monitoring Model

| Control | Initial Operating Model |
| --- | --- |
| Owner | Project Lead acting as Platform & Cost Owner; ownership must be recorded for each monthly review. |
| Cadence | Monthly, after a complete calendar month has closed and billing data has settled. |
| Evidence | Billing Reports screenshot showing project context, original CSV attached manually to Issue #6, and sanitized service-level derivative committed in repository documentation. |
| Baseline | Establish a current operating baseline only after the first complete steady-state month; keep the historical Issue #14 estimate as a separate audit baseline. |
| Service review | Review total gross cost, savings, net cost, and cost by service. |
| Initial escalation threshold | Investigate any unplanned billable service, any service increase above 20% and at least 2 EUR against the approved operating baseline, or total monthly net cost above 20% of the approved operating baseline. |
| Initial-threshold limitation | These thresholds are provisional for the coursework pilot and must be recalibrated after the first complete steady-state month. |
| Escalation | Create a follow-up issue linked to Issue #6, document root cause and mitigation, and implement approved architecture or configuration changes through a pull request. |
| Monthly close | Attach original evidence to Issue #6, update the sanitized evidence table, record deviations and decisions, then refresh the presentation summary. |

## Presentation Summary

| Slide point | Summary |
| --- | --- |
| Historical baseline | `448.24 EUR/month` |
| Actual period-to-date | `10.15 EUR` net for 1-24 June 2026 |
| Leading drivers | Compute Engine `46.4%`, Kubernetes Engine `37.4%` |
| Interpretation | Early right-sized deployment, not a comparable monthly variance |
| Next control | Full-month update and attached billing evidence |

- Capacity: planned 2 e2-standard-2 workers in europe-west3; live 1 n2-standard-2 worker in europe-west1-b.
- Availability trade-off: current one-worker topology is cost-efficient for the pilot but not highly available.
- Interpretation: the period-to-date actual is evidence of an early right-sized deployment, not a comparable monthly cost variance.
- Control: establish a full-month operating baseline, retain original billing evidence, and investigate material deviations through the monthly operating model.

## Audit-Trail and Evidence-Location Caveat

The assignment expects actual-cost evidence to be logged with the original capacity-planning issue. Issue #14 is intentionally preserved as immutable historical planning evidence and is not modified by this work.

Therefore, actual-cost evidence is maintained in this repository documentation and must be manually attached to Issue #6. This preserves the historical planning audit trail but is a formal traceability caveat because the original planning issue is not updated.

No change to Issue #14 is suggested, requested, or performed.

## Issue #6 Acceptance-Criteria Status

| Criterion | Status |
| --- | --- |
| Actual costs documented | Complete |
| Sanitized evidence committed | Complete |
| Original screenshot and CSV attached to issue #6 | Pending manual action |
| Planned versus actual comparison | Complete with comparability limitation |
| Deviation explanation | Complete |
| Lessons learned | Complete |
| Final presentation reuse | Complete |
| Full-month update | Pending |
