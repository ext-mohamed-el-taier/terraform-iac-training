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

resource "azurerm_resource_group" "count" {
  count = 2

  name     = "PREFIX-myfirstrg-${count.index}"
  location = "centralus"

  tags = {
    terraform = "true"
  }
}
