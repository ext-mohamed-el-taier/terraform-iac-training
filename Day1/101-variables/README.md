# Terraform Variables

## Expected Outcome

You will learn how to use variables to make your Terraform code more reusable.

## How To

### Create Terraform Configuration

For this exercise, you're going to use the `azurerm` [Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) to deploy a Storage Account to Azure.

> NOTE: In Azure, all resources must belong to a Resource Group. Be sure to deploy a Resource Group and place the Storage Account into that Resource Group.

You will create a `main.tf` file with the following:
1. A `terraform {}` block declaring the version of Terraform to use as well as the `azurerm` provider within the `required_providers` block.
1. An `azurerm` block for the provider configuration.
1. A [Resource Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group). Make sure you use a unique Resource Group name, especially if using a shared subscription.
1. A "Standard" SKU [Storage Account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) of the "LRS" account replication type within the Resource Group.
1. A [variable named](https://www.terraform.io/docs/language/values/variables.html) `storage_account_name` that will set the name of the above Storage Account.
1. Run through the Terraform workflow by running `terraform plan` and if all looks good, `terraform apply`. Note what happens when you run both plan and apply with regard to `storage_account_name`.

### Troubleshooting
You may notice that this tutorial is largely unguided. That's by design - we want this lab to more accurately reflect a real-world scenario.

Here are some tips for troubleshooting:
1. Storage Accounts are picky about naming. If you name your Storage Account something that the Azure API doesn't allow, it will let you know. Read error messages carefully.
1. Storage Account names have to be [globally unique](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftstorage) (as in, unique across ALL OF AZURE!), so if you named your Storage Account "teststorage", it's not going to be unique. Try adding some random integers to the name, like "teststorage28313".
1. Depending on the role your user principal has been granted to your subscription, you may NOT have access to data in the Storage Account after Terraform creates it. More on that in a future lab!

### Inputting variables to Terraform

This exercise will build on the Resource Group and Storage Account that you just defined in your `main.tf`.

When you applied your Terraform configuration, you were prompted to provide your storage account name from the commandline (unless you set a default value in your variable). This approach works up to a point, but as your configuration gets more complex and you add more variables, having to enter them every time you run `terraform plan`, `terraform apply`, and `terraform destroy` becomes tedious. As your Terraform grows into automated execution, such as via a pipeline, in many cases you won't have the option to input the variables through the commandline anyhow!

Let's explore some of the other ways we can feed variable input to Terraform.
---
*a named tfvars file*
1. First, look at your commandline and make note of the `storage_account_name` variable you input the last time you ran `terraform apply`
1. Create a new file in the same directory as your `main.tf` and call it `input.tfvars` (you can name it whatever you want).
1. Open `input.tfvars` and add a line which reads `storage_account_name = <your storage account name>`. Save this file.
1. Run a plan, passing in the `input.tfvars` file, like so:
  ```sh
  terraform plan -var-file=input.tfvars
  ```

---
*an `*.auto.tfvars` file*
1. First, look at your commandline and make note of the `storage_account_name` variable you input the last time you ran `terraform apply`
1. Create a new file in the same directory as your `main.tf` and call it `input.auto.tfvars` (you can name it whatever you want).
1. Open `input.auto.tfvars` and add a line which reads `storage_account_name = <your storage account name>`. Save this file.
1. Run a plan
1. Delete the `input.auto.tfvars` file before continuing

---
*ENV vars*
1. First, look at your commandline and make note of the `storage_account_name` variable you input the last time you ran `terraform apply`
1. Create a new environment variable named `TF_VAR_storage_account_name` and set the value to your storage account name. Case matters.

    **On bash:**
    ```sh
    export TF_VAR_storage_account_name=<your storage account name>
    ```
    Validate with `ls env`

    **In pwsh:**
    ```pwsh
    $env:TF_VAR_storage_account_name = <your storage account name>
    ```
    Validate with `dir env:`
1. Run a plan

---
*Passing in variables as parameters*
1. First, look at your commandline and make note of the `storage_account_name` variable you input the last time you ran `terraform apply`
1. Run a plan, passing in the variable, like so:
  ```sh
  terraform plan -var='storage_account_name=<your storage account name>'
  ```

### Cleanup

When you are done, destroy the infrastructure, you no longer need it.

---

## Resources
- [azurerm Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [azurem_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)
- [azurerm_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
- [Terraform Input Variables](https://www.terraform.io/docs/language/values/variables.html)
