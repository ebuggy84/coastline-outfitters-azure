# Coastline Outfitters: Azure Environment with Terraform

Coastline Outfitters is a fictional 50-person outdoor gear retailer with an online store, an internal inventory app, a database, and a small IT team. I act as its cloud engineer, building and running its Azure environment entirely with Terraform.

Work arrives as tickets, the same way it would on a real IT team: build requests, change requests, incidents, and security reviews. Every ticket is logged in [docs/tickets.md](docs/tickets.md) with what was asked, what I built, and what I ran into.

## What's built so far

| Resource | Name | Purpose |
|---|---|---|
| Resource group | rg-coastline-prod | Holds every Coastline resource so it can be tracked and removed as a unit |
| Log Analytics workspace | law-coastline-prod | Central logging, 30-day retention |
| Virtual network | vnet-coastline-prod | 10.10.0.0/16 private network |
| Subnet | snet-web | 10.10.1.0/24, online store web servers |
| Subnet | snet-app | 10.10.2.0/24, inventory application |
| Subnet | snet-data | 10.10.3.0/24, database |
| Subnet | snet-mgmt | 10.10.4.0/24, IT management |

Automation in place: a CI/CD pipeline (GitHub Actions with OIDC authentication to Azure) runs format, validate, and plan on every pull request, and a scheduled drift-detection workflow checks the live environment against the code. Both are described below.

The network is split into tiers so traffic between them can be controlled. The 10.10.0.0/16 range was chosen so it doesn't overlap with my existing 10.0.0.0/16 network, which keeps future peering possible.

## Design decisions

1. **Remote state.** Terraform state lives in a locked-down Azure Storage account in its own resource group, accessed with Entra ID instead of a storage key, with state locking. State files are never committed, because they can contain secrets.
2. **No subscription ID in code.** The subscription is supplied through the ARM_SUBSCRIPTION_ID environment variable.
3. **References instead of hardcoded values.** Resources reference each other, such as the workspace reading the resource group's name and location, so changes flow through automatically and Terraform works out the build order.
4. **Required tags.** Every taggable resource carries company, environment, owner, and cost_center tags for cost tracking.
5. **Cost guardrails.** A $100 monthly subscription budget alerts at 50%, 80%, and 100% of actual spend, plus a forecast alert. It's managed in my separate foundation configuration.


## Drift detection

Infrastructure drift happens when the live environment stops matching the committed configuration, usually because someone makes a change directly in the portal instead of through code. A scheduled GitHub Actions workflow catches this: it runs `terraform plan` against the real environment every Monday, and on demand, and fails if the environment no longer matches the code.

How it works: the plan runs with `-detailed-exitcode`, which returns 0 when nothing has changed, 2 when there is drift, and 1 on a real error. The workflow reads that exit code and fails the run on drift so it surfaces as an alert rather than passing silently.

Demonstrated end to end:

1. Clean baseline. With the environment matching the code, the workflow reports "No changes" and passes.
2. Simulated unauthorized change. I added a tag directly on the resource group in the portal. The next run detected it (`Plan: 0 to add, 1 to change, 0 to destroy`), reported the drift, and failed.
3. Remediation. I removed the tag so the environment matched the code again, and the workflow passed.

One engineering note worth recording: the first version detected the drift in the plan output but the run still passed. The HashiCorp setup-terraform action wraps the Terraform binary and was masking the real exit code, so the detailed exit code came back as 0 instead of 2. Setting `terraform_wrapper: false` lets the real exit code through, which fixed it.

## Security backlog

Findings from reviewing Terraform plans, to be addressed in upcoming tickets:

1. All subnets allow default outbound internet access, including the database subnet.
2. The Log Analytics workspace allows shared-key (local) authentication instead of requiring Entra ID.
3. The workspace has no daily ingestion cap.
4. No network security groups are attached to the subnets yet.

## How to deploy

Requirements: Terraform, the Azure CLI signed in with az login, ARM_SUBSCRIPTION_ID set, and access to the state storage account.

    terraform init
    terraform plan
    terraform apply

## Roadmap

1. Network security groups for each tier
2. Virtual machines built with for_each and reusable modules
3. Azure Monitor Agent and data collection rules feeding the workspace
4. Microsoft Sentinel detections
5. A vulnerability prioritization service using CISA KEV and EPSS data
6. Backups and Azure Policy guardrails
