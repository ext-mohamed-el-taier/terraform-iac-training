# Locals and Outputs

## Expected Outcome

You will understand how to use locals in your Terraform codebase and when they can be useful.

## How To

### Create Terraform Configuration

You will create a `main.tf` file with the following:
1. A `terraform {}` block declaring the version of Terraform to use as well as the `azurerm` provider within the `required_providers` block.
1. An `azurerm` block for the provider configuration.
1. A [Resource Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group). Make sure you use a unique Resource Group name, especially if using a shared subscription. We recommend using a variable each for the RG name and location!
1. An [Azure SQL Server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) instance deployed to the Resource Group. No need to create a database at this time.
1. Define a `random_password` block for the MSSQL Server administrator password and use the result of the random password to populate the `administrator_login_password` argument in the `azurerm_mssql_server` resource block.
1. Define a sensitive output to output the MSSQL Server administrator password.
1. Create a `locals` block with a property named `tags`. **NOTE** tags in the `azurerm` provider are defined as maps, so be sure to define your tags local as a map too!
    Define the following LOB tags:
    ```
    "BusinessUnit" = "DevOpsTeam",
    "Environment"  = "Dev",
    "ChargeBack"   = "IT"
    ```
1. All taggable resources should both be tagged with the LOB tags defined in the local.

> NOTE: [Tags are not inherited in Azure](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=json#inherit-tags) so *each* resource will need to have tags. This is where locals _can_ come in handy.

### Plan and Apply
1. Run the Terraform workflow to Plan (with output) and Apply your IaC configuration.
1. Note the output in both phases.
1. After the Apply, open the `.terraform.tfstate` file and note the password in the statefile. What differs between `stdout` output and what you see in the statefile? What does this tell you about the importance of securing your statefile from prying eyes?

<details><summary>View Output</summary>
<p>

```
Changes to Outputs:
  + mssql_login_password = (sensitive value)
```

and the statefile:

```
  "outputs": {
    "mssql_login_password": {
      "value": "PlainTextPassword!!!",
      "type": "string",
      "sensitive": true
    }
  },
```
</p></details>

### Cleanup
Destroy your resources with a `terraform destroy` when you are finished.

## Resources
- [Local Values](https://www.terraform.io/language/values/locals)
- [random_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)
- [Outputs](https://www.terraform.io/language/values/outputs)
- [Azure SQL DB](https://docs.microsoft.com/en-us/azure/azure-sql/database/)
- [azurerm_mssql_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server)
- [Azure Password Policy](https://docs.microsoft.com/en-us/sql/relational-databases/security/password-policy?redirectedfrom=MSDN&view=sql-server-ver15)
