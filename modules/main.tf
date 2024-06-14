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