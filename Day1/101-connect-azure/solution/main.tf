provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "PREFIX-myfirstrg"
  location = "centralus"

  tags = {
    terraform = "true"
  }
}

variable "environments" {
  type        = list(string)
  default     = ["dev", "prod"]
  description = "List of environments to create resource groups for"
}

resource "azurerm_resource_group" "foreach" {
  for_each = toset(var.environments)

  name     = "PREFIX-myfirstrg-${each.key}"
  location = "centralus"

  tags = {
    terraform   = "true"
    environment = each.key
  }
}
