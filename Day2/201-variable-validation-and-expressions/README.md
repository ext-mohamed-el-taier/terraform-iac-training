# Variable Validation and Expressions

## Expected Outcome
* You will understand what Expressions are in Terraform and how to use them.
* You will use Expressions and Functions to perform basic input variable validation for variables passed into your Terraform codebase.

## How To
You will create a `main.tf` file with the following:
1. A `terraform {}` block declaring the version of Terraform to use as well as the `azurerm` provider within the `required_providers` block.
1. An `azurerm` block for the provider configuration.
1. 3 [variable blocks](https://www.terraform.io/language/values/variables):
    1. `location` of [type](https://www.terraform.io/language/expressions/types) "string", and [validation condition](https://www.terraform.io/language/values/variables#custom-validation-rules) that accepts 2 possible values, "eastus2" and "australia".
    1. `resource_group_name` of [type](https://www.terraform.io/language/expressions/types) "string", and [validation condition](https://www.terraform.io/language/values/variables#custom-validation-rules) to limit the name length between 1 and 90 characters.
    BONUS: Add an additional condition to only accept the [allowed characters in a resource group name](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftresources). HINT: you don't need to fit all your conditions onto one line, you can group conditions with `&&`.
    1. `key_vault_name` of [type](https://www.terraform.io/language/expressions/types) "string", and [validation condition](https://www.terraform.io/language/values/variables#custom-validation-rules) to limit the name length between 3 and 24 characters.
1. A resource group that uses your [validated variable](https://www.terraform.io/language/expressions/references#input-variables) as the name property.
1. A key vault that uses your [validated variable](https://www.terraform.io/language/expressions/references#input-variables) as the name property.

## Resources
- [Expressions](https://www.terraform.io/language/expressions)
- [Variables](https://www.terraform.io/language/values/variables)
- [Resource Group Name requirements](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftresources)
- [Key Vault Name requirements](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftkeyvault)
