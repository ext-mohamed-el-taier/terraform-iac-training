# Connecting To Azure

## Expected Outcome

You will use Terraform to create simple infrastructure in your Azure Subscription.

In this challenge, you will:

- Initialize Terraform
- Run a `plan` on simple a simple resource
- Run an `apply` to create Azure infrastructure
- Run a `destroy` to remove Azure infrastructure

## How To

### Create Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/101-connect-azure/`.

**First, add the following block to configure the provider... we'll come back to this in more detail later.**

Create a file named `main.tf` and add the azurerm provider configuration
```hcl
provider "azurerm" {
  features {}
}
```

Next, add a single Resource Group resource.
```hcl
resource "azurerm_resource_group" "main" {
  name     = "{PREFIX}-myfirstrg"
  location = "centralus"
}
```

> NOTE: It is critical that you chose a unique PREFIX if you are in a shared Azure Subscription.

This will create a simple Resource Group and allow you to walk through the Terraform Workflow.

### Authenticate To Azure

**Option 1**

Login via the azure cli:

```sh
az login

# Only needed if you have access to more than one Azure Subscription.
az account set -s 'ALADDIN-TFTRAINING-LAB'
```

(Optional) Login to a specific Tenant with the azure cli:
```sh
az login --tenant 61aa25d6-f23d-4b7d-a98c-9ab3c0235e10
az login --tenant OneAladdin.onmicrosoft.com
```

More information can be found [here](https://www.terraform.io/docs/providers/azurerm/auth/azure_cli.html).

**Option 2**

Login using a Service Principal. This is more common in CI/CD pipelines and other automated machine processes.

Set the following environment variables:

```sh
$ export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
$ export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
$ export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
$ export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

More information can be found [here](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal).

### Run the Terraform Workflow

`terraform init`
<details><summary>View Output</summary>
<p>

```sh
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "azurerm" (terraform-providers/azurerm) X.X.X...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.azurerm: version = "~> X.X.X"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

</p>
</details>

---
`terraform plan`

<details><summary>View Output</summary>
<p>

```sh
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "centralus"
      + name     = "tstraub-myfirstrg"
      + tags     = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

</p>
</details>

---
`terraform apply`
<details><summary>View Output</summary>
<p>

```sh
$ terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "centralus"
      + name     = "tstraub-myfirstrg"
      + tags     = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.main: Creating...
azurerm_resource_group.main: Creation complete after 2s [id=/subscriptions/GUID/resourceGroups/tstraub-myfirstrg]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
</p>
</details>

---

Congrats, you just created your first Azure resource using Terraform!

### Verify in the Azure Portal

Head over to the [Azure Portal](https://portal.azure.com/)

View all Resource Groups and you should see the recently created Resource Group.

![](img/portal-firstrg.png)

### Scale Resources

Now add a new Resource Group resource that scales using `for_each`. This is the preferred approach over `count` because resources are keyed by name rather than index, making additions and removals safer.

> Note: This is ADDING another `resource` block in addition to the one you have already created.

First, define a variable to hold the list of environments:

```hcl
variable "environments" {
  type        = list(string)
  default     = ["dev", "prod"]
  description = "List of environments to create resource groups for"
}
```

Then create the resource group using `for_each` with `toset()`:

```hcl
resource "azurerm_resource_group" "foreach" {
  for_each = toset(var.environments)

  name     = "{PREFIX}-myfirstrg-${each.key}"
  location = "centralus"

  tags = {
    terraform   = "true"
    environment = each.key
  }
}
```

Run another `terraform plan` then `terraform apply` and validate the resource groups have been created.

> **Why `for_each` over `count`?**
> - With `count`, resources are identified by index (0, 1, 2...). If you remove an item from the middle, all subsequent resources shift and get recreated.
> - With `for_each`, resources are identified by their key (e.g., "dev", "prod"). Removing one doesn't affect the others.

---
## Advanced areas to explore

1. Play around with adjusting the `environments` variable, then running `plan` and `apply`. Notice how adding or removing an environment only affects that specific resource.
2. Run the `plan` command with the `-out` option and apply that output.
3. Add additional tags to each resource.


---
### Cleanup

When you are done, destroy the infrastructure, you no longer need it.

The output will look ***similar*** to this:

```sh
$ terraform destroy
azurerm_resource_group.main: Refreshing state... (ID: /subscriptions/.../resourceGroups/challenge01-rg)
azurerm_resource_group.foreach["dev"]: Refreshing state... (ID: /subscriptions/.../resourceGroups/challenge01-rg-dev)
azurerm_resource_group.foreach["prod"]: Refreshing state... (ID: /subscriptions/.../resourceGroups/challenge01-rg-prod)

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  - azurerm_resource_group.foreach["dev"]

  - azurerm_resource_group.foreach["prod"]

  - azurerm_resource_group.main

Plan: 0 to add, 0 to change, 3 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

...

azurerm_resource_group.foreach["dev"]: Destruction complete after 45s
azurerm_resource_group.foreach["prod"]: Destruction complete after 45s
azurerm_resource_group.main: Destruction complete after 45s

Destroy complete! Resources: 3 destroyed.
```

Because the infrastructure is now managed by Terraform, we can destroy just like before.

Run a `terraform destroy` and follow the prompts to remove the infrastructure.

## Resources

- [Terraform for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
- [Terraform count](https://developer.hashicorp.com/terraform/language/meta-arguments/count)
