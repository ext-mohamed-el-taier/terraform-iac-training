# Importing Existing Resources into State

## Expected Outcome

State is important to the Terraform workflow. Sometimes you have resources that were created outside Terraform that you'd like to manage with Terraform. You will learn how to create a simple Terraform configuration to represent these unmanaged resources, then import them so they can be managed by Terraform.

**Terraform offers two methods for importing resources:**
1. **`import` block (Terraform 1.5+)** - Declarative, recommended approach
2. **`terraform import` CLI command** - Imperative, legacy approach

You will learn both methods in this lab.

## How To
1. Login to the [Azure Portal](https://portal.azure.com).
1. Using the portal, create a new Resource Group with a name and location of your choice. You don't need to add tags because we won't be importing them.

    ![](./img/create-rg.png)
1. Using the portal, create a new VNet with a CIDR range "10.0.0.0/16". Make sure the VNet belongs to the Resource Group you just created!

1. These 2 resources, the Resource Group and VNet, represent cloud resources that were created outside of Terraform. We now want to manage them via Terraform...

### Step 1: Create the Resources in Terraform

You will create a `main.tf` file with the following:
1. A `terraform {}` block declaring the version of Terraform to use as well as the `azurerm` provider within the `required_providers` block.
1. An `azurerm` block for the provider configuration.
1. A [Resource Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) with the same name and location as the Resource Group you created via the portal.
1. A VNet resource with the same name, location, resource group, and CIDR range as the one you created in the  portal.

### Run Terraform Workflow

1. Run `terraform init` and `terraform plan`... what do you notice about your plan?
1. Run a `terraform apply -auto-approve` (don't ever do this in production, by the way!)... what happens?

### Understanding State, Resource Addressing, and Import for Azure

1. In order for Terraform to "know" about these resources, and thus, how to manage them, we have to import them. Thankfully, there are a handful of commands in the Terraform CLI that make working with state easier. If you're ever managing the statefile by hand, then you're either doing something very specific or you should rethink what you're doing!
1. The first thing to do is look at the command to import your specific resource. Fortunately, these commands are at the bottom of each of the resources.
    1. [Import Resource Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group#import)
    1. [Import VNet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network#import)
1. To understand what you're importing and where, it helps to understand [Resource Syntax](https://www.terraform.io/language/resources/syntax#resource-syntax), specifically, the resource "type" and "local name" as these are used to key a Terraform-defined resources to an actual resource in the cloud.
    1. e.g., a resource block defined in Terraform as `resource "azurerm_resource_group" "main" {}`, `azurerm_resource_group` is the type and `main` is the local name. The local name can be whatever you want, but it must be unique for that resource (unless you're using a meta-argument, such as "count").
1. The other piece of the import command is going to be defined by the resource-specific import command. In MANY (most?) cases, it's going to be some identifier in the cloud that uniquely identifies the resources. In Azure, resource IDs align to API endpoints. Most of the resources you encounter in Azure will be "namespaced" by both a subscription id and a resource group. [Further Reading](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview)
1. There are a couple of ways to retrieve the ID of a resource:

    1. Via the portal, typically on the "Overview" page of the resource. Sometimes the JSON View helps, if available.

        ![](./img/json-view.png)

    1. Via the Resource Explorer in the portal. I find it's easiest to use the SEARCH bar in the portal to locate it.
    
        ![](./img/resource-xplor.png)

### Import Resources

Terraform provides two ways to import resources. We'll cover both.

---

## Method 1: Import Block (Recommended - Terraform 1.5+)

The `import` block is the modern, declarative way to import resources. It allows you to define imports directly in your configuration and execute them as part of `terraform plan` and `terraform apply`.

### Step 1: Add Import Blocks to Your Configuration

Add the following `import` blocks to your `main.tf` (update the IDs to match your resources):

```hcl
import {
  to = azurerm_resource_group.main
  id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP_NAME"
}

import {
  to = azurerm_virtual_network.main
  id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP_NAME/providers/Microsoft.Network/virtualNetworks/YOUR_VNET_NAME"
}
```

### Step 2: Run Terraform Plan

```sh
terraform plan
```

The plan will show the resources being imported. Review the output to ensure the configuration matches the existing resources.

### Step 3: Apply the Import

```sh
terraform apply
```

This will import the resources into your state file.

### Step 4: Remove Import Blocks (Optional)

After a successful import, you can remove the `import` blocks from your configuration. They are only needed for the initial import operation.

### Benefits of Import Blocks
- **Declarative**: Imports are part of your configuration and can be code-reviewed
- **Plannable**: You can preview imports with `terraform plan` before applying
- **Batch imports**: Multiple resources can be imported in a single apply
- **CI/CD friendly**: Works naturally in automated pipelines
- **Generate configuration**: Use `terraform plan -generate-config-out=generated.tf` to auto-generate resource configurations for imported resources (Terraform 1.5+)

---

## Method 2: CLI Import Command (Legacy)

The `terraform import` CLI command is the traditional way to import resources. It imports one resource at a time directly into the state.

1. Import the Resource Group (your resource ID will vary)
  ```sh
  terraform import azurerm_resource_group.main /subscriptions/0174de8e-22d8-4082-a7a6-f4e808c60c08/resourceGroups/davessweettest1
  ```
1. Import the VNet (your resource ID will vary)
  ```sh
  terraform import azurerm_virtual_network.main /subscriptions/0174de8e-22d8-4082-a7a6-f4e808c60c08/resourcegroups/davessweettest1/providers/Microsoft.Network/virtualNetworks/davesvnet1
  ```

### When to Use CLI Import
- Quick, one-off imports during development
- When working with older Terraform versions (< 1.5)
- Simple scenarios where you don't need plan preview

---

### Validate Imports
1. Each import command you run should give you feedback as to whether or not the import succeeded.
  ```sh
  root@d7190a4a4411:/app/Day2/201-state-import/solution# terraform import azurerm_resource_group.main /subscriptions/0174de8e-22d8-4082-a7a6-f4e808c60c08/resourceGroups/davessweettest1
  azurerm_resource_group.main: Importing from ID "/subscriptions/0174de8e-22d8-4082-a7a6-f4e808c60c08/resourceGroups/davessweettest1"...
  azurerm_resource_group.main: Import prepared!
    Prepared azurerm_resource_group for import
  azurerm_resource_group.main: Refreshing state... [id=/subscriptions/0174de8e-22d8-4082-a7a6-f4e808c60c08/resourceGroups/davessweettest1]

  Import successful!

  The resources that were imported are shown above. These resources are now in
  your Terraform state and will henceforth be managed by Terraform.
  ```
1. Try importing the same resource more than once, what happens?
1. Note that the import requires you to be authenticated against the provider because it actually reaches out to the cloud API to check for the resource.
1. A way to validate your import succeeded is to run a `terraform plan`... why? Because a plan that comes back with `No Changes` is a good indicator that your import has succeeded. That means your Terraform codebase is inline with the statefile, at least.

### Apply Terraform
1. The last step is to run `terraform apply` and verify that you get a clean run. At this point, your resources are now managed with Terraform! Don't forget to destroy them when you're done (using Terraform, of course)!

---

## Bonus: Generate Configuration from Existing Resources (Terraform 1.5+)

If you have existing resources but don't want to write the Terraform configuration manually, you can use the `-generate-config-out` flag to auto-generate it:

```sh
terraform plan -generate-config-out=generated.tf
```

This will:
1. Read the import blocks you defined
2. Fetch the current state of those resources from Azure
3. Generate the corresponding Terraform resource blocks in `generated.tf`

**Note:** The generated configuration may need cleanup and adjustment, but it's a great starting point!

---

## Discussion Questions

1. What are the advantages of using the `import` block over the CLI command?
2. When might you still prefer to use the CLI import command?
3. How does the `-generate-config-out` feature change your workflow when importing large numbers of resources?
4. What happens if your Terraform configuration doesn't exactly match the imported resource's current state?
