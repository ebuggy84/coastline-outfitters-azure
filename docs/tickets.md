# Ticket Log

## Ticket #1: Cost guardrails

**Request:** Set a $100 monthly budget on the subscription with alerts at 50%, 80%, and 100% of actual spend, plus an alert if Azure forecasts going over. Must be in Terraform.

**Built:** A subscription-level budget with four notifications, using a data source to read the subscription ID instead of hardcoding it. This lives in my foundation configuration, not this repo, since it covers the whole subscription.

**Learned:** Budgets only send alerts. They don't stop resources from running, so destroying unused resources is still the real cost control. In the portal, the budget only appeared at the subscription scope, not the billing account scope, the same scope concept as RBAC.

## Ticket #2: Coastline resource group

**Request:** Create rg-coastline-prod in East US with company, environment, owner, and cost_center tags.

**Built:** A tagged resource group.

**Issue:** My first draft copied the whole foundation file, including the terraform and provider blocks, and changed the resource type to a made-up name. The type has to match the provider's vocabulary exactly (azurerm_resource_group). Only the local name is mine to choose.

**Learned:** Where resource arguments come from: the Terraform Registry's example usage and argument reference.

## Ticket #3: Central logging

**Request:** Create a Log Analytics workspace with the PerGB2018 SKU, 30-day retention, and the standard tags.

**Built:** law-coastline-prod, referencing the resource group's name and location instead of retyping them.

**Issue:** My draft used cat > main.tf with only the workspace block. That command replaces the whole file, so the resource group would have disappeared from the code, and the next apply would have deleted it. Caught in review before running anything.

**Learned:** Always check the plan's destroy count. The plan also showed the workspace's shared keys are stored in state, which is why state must stay locked down, and flagged local authentication and the missing daily cap for the security backlog.

## Ticket #4: Network

**Request:** Create vnet-coastline-prod (10.10.0.0/16) with web, app, data, and mgmt subnets.

**Built:** One virtual network and four subnets, each referencing the network.

**Learned:** Terraform built the network first, then all four subnets in parallel, because the references told it the dependency order. The plan also showed every subnet allows default outbound internet access, which went on the security backlog.
