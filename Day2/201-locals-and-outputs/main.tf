terraform {}

provider "azurerm" {}

locals {
  tags = {
    "BusinessUnit" = "DevOps"
  }
}

resource "azurerm_mssql_server" "main" {
  ...

  tags = local.tags
}
