# Unit Testing Terraform Modules

## Expected Outcome
* You will learn how to write unit tests to validate Terraform modules you have written.

## How To

### Create your module
1. Create  a `main.tf` file to contain the module we're going to test. This module will abstract a simple [Azure Storage Account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account).
2. Create the following variables (inputs) to the module:
    1. resource group name
    2. location
    3. storage account tier (should default to "Standard"
    4. storage replication type (should default to "LRS"
    5. storage delete retention in days (should default to 7)
    6. tags (should default to `{}`)
3. Create an `azurerm_storage_account` resource in your module's `main.tf` file.

### Test your module
4. Create a directory named `tests`, and within this directory, a directory named `defaults` and a directory named `custom-config`.
5. Create a `test.tf` file in both the `defaults` and `custom-config` directories. Each of these represent a unit test with different module inputs. Your directory should look like this:
  ```sh
  .
  |-- main.tf
  `-- tests
      |-- defaults
      |   `-- test.tf
      `-- custom-config
          `-- test.tf

  ```
6. In each `test.tf`, you're going to create an `azurerm_resource_group` resource and call the module using the local path `../../`. For the `defaults` test, only pass in the variables that are required by the module. For the `custom-config`, pass in _all_ of the variables into the module.
7. Open your CLI and change into the `defaults` directory. Run the Terraform plan, apply, and finally destroy workflow. This will test your module.
8. Next, from the CLI, change into the `custom-config` directory. Run the Terraform plan, apply, and finally destroy workflow. This is another test of your module.

## Resources
- [azurerm_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
- [azurerm_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)
- [Azure built-in Roles for Blobs](https://docs.microsoft.com/en-us/azure/storage/blobs/authorize-access-azure-active-directory#azure-built-in-roles-for-blobs)
- [azurerm_client_config](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config)
- [Terraform Testing Experiment](https://www.terraform.io/language/modules/testing-experiment)
- [Terraform Module Unit Test Prototype - Unofficial](https://registry.terraform.io/providers/apparentlymart/testing/latest/docs)
