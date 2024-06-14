<!-- BEGIN_TF_DOCS -->
## What is Network Security Group ?

An Azure Network Security Group (NSG) is a core component of Azure's security fabric. Leveraging an NSG, you can filter traffic to and from Azure resources that you have commissioned on an Azure Virtual Network (VNet). At its core, an NSG is effectively a set of access control rules you assign to an Azure resource.

```hcl
data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "dev-project2-remotestate"
    storage_account_name = "project2remotestate"
    container_name       = "network-terraform-state"
    key                  = "nw-terraform.tfstate"
  }
}


locals {
  vnets   = data.terraform_remote_state.network.outputs.vnets
  subnets = data.terraform_remote_state.network.outputs.vnets.subnets
}

locals {
  rules_csv = try(csvdecode(file(var.rules_file)), [])
  nsg_name = {
    for subnet in local.subnets : subnet.name => "NSG-${subnet.name}"
  }
}

resource "azurerm_network_security_group" "this" {
  for_each = local.nsg_name
  name                = each.value
  resource_group_name = var.rg_name
  location            = var.location

  dynamic "security_rule" {
    for_each = { for rule in local.rules_csv : rule.name => rule }
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

No requirements.

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm)

- <a name="provider_terraform"></a> [terraform](#provider\_terraform)

## Resources

The following resources are used by this module:

- [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) (resource)
- [terraform_remote_state.network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The location of the resources

Type: `string`

### <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name)

Description: The existing resource group name

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_rules_file"></a> [rules\_file](#input\_rules\_file)

Description: The path to the CSV file containing the rules

Type: `string`

Default: `"rules.csv"`

## Outputs

No outputs.

## Modules

No modules.

This is sample Network Security Group using terraform module for learning purpose by Seenu.
<!-- END_TF_DOCS -->