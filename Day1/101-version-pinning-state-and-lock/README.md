# Version Pinning, State, and Lock

## Expected Outcome

You will use Terraform to create simple infrastructure in your Azure Subscription using pinned versions of Terraform and required providers. This will help you understand how versioning Terraform and Terraform Providers works as well as the constraints that can be placed around those versions. You will also begin to understand the role of the statefile in Terraform.

In this challenge, you will:

- Pin an older version of a provider and run through the Terraform workflow (init, plan, apply)
- Locate the provider checksum in the lock file.
- Locate the Terraform statefile.
- Update the provider pin and run through the Terraform workflow again.

## How To

### Create Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/101-version-pinning-state-and-lock/`.

**Create a file name `main.tf` and add the following terraform configuration block**
```hcl
terraform {
  required_version = ">= 1.14.0"
  required_providers {
    azurerm = {
      version = "4.52.0"
    }
  }
}
```

This puts version constraints around Terraform and the Terraform Provider used in your code. Terraform and Terraform Providers are versioned using Semantic Versioning, e.g. MAJOR.MINOR.PATCH.

The `>=` means that any version of the Terraform binary equal or greater to 1.14.0 will work with your codebase.

> NOTE: The `~>` operator is known as the "pessimistic contstraint operator" and can be used to allow flexibility within the acceptable PATCH versions of Terraform, providers, or private registry modules.

**Next, configure the AzureRM Provider**

```hcl
provider "azurerm" {
  features {}
}
```

> NOTE: The `features {}` block is empty, for now.

Finally, add a single Resource Group resource.

```hcl
resource "azurerm_resource_group" "main" {
  name     = "<REPLACE ME>"
  location = "centralus"
}
```

### Run the Terraform Workflow

`terraform init`
<details><summary>View Output</summary>
<p>

```sh
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "~> 4.52.0"...
- Installing hashicorp/azurerm v4.52.0...
- Installed hashicorp/azurerm v4.52.0 (self-signed, key ID 34365D9472D7468F)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!
```

</p>
</details>

---
`terraform plan`

<details><summary>View Output</summary>
<p>

```sh
$ terraform plan

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "centralus"
      + name     = "PREFIX-myfirstrg"
      + tags     = {
          + "terraform" = "true"
        }
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
      + name     = "PREFIX-version-test"

      + tags     = {
          + "terraform" = "true"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.main: Creating...
azurerm_resource_group.main: Creation complete after 0s [id=/subscriptions/0174de8e-22d8-4082-a7a6-f4e808c60c08/resourceGroups/PREFIX-myfirstrg]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
</p>
</details>

---

### Change the version of the AzureRM provider

Open `main.tf` and update the azurerm provider version to a newer value, e.g.:
```hcl
terraform {
  required_version = ">= 1.14.0"
  required_providers {
    azurerm = {
      version = "> 4.52.0" # this is where you're making the change
    }
  }
}

```
---
`terraform plan`

<details><summary>View Output</summary>
<p>

```sh
$ terraform plan

Error: Provider requirements cannot be satisfied by locked dependencies

The following required providers are not installed:

- registry.terraform.io/hashicorp/azurerm (> 4.52.0)

Please run "terraform init".
```

</p>
</details>

> NOTE: changes to versions require you to re-run `terraform init`
---
`terraform init`

<details><summary>View Output</summary>
<p>

```sh
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/azurerm from the dependency lock file

Error: Failed to query available provider packages

Could not retrieve the list of available versions for provider
hashicorp/azurerm: locked provider registry.terraform.io/hashicorp/azurerm
4.52.0 does not match configured version constraint > 4.52.0; must use
terraform init -upgrade to allow selection of new versions
```

</p>
</details>
---
That failed too! But why?

### Terraform Lock File
Introduced in Terraform version 0.14.x, .terraform.lock.hcl helps track the Terraform Provider dependencies to ensure consistency from one plan/apply to the next.

From your editor, navigate to `.terraform.lock.hcl`. Note this file may be hidden in your file browser, so please ensure that you're able to view hidden files.

Your `.terraform.lock.hcl` file will look something like this:
```hcl
# This file is maintained automatically by "terraform init".
# Manual edits may be lost in future updates.

provider "registry.terraform.io/hashicorp/azurerm" {
  version     = "4.52.0"
  constraints = "~> 4.52.0"
  hashes = [
    ...
  ]
}
```
Note the current `version` value does not match the `constraints` we set on the provider in our `main.tf`.

The `.terraform.lock.file` can be checked into version control (in fact, it's recommended) so that you can ensure consistency of dependencies across a team.

---
Now, run `terraform init -upgrade` to upgrade the provider version. Terraform will reach out to the `source` provider registry specified the `required_providers` block to download the provider version (and associated hashes to ensure consistency and checksum).

`terraform init -upgrade`

<details><summary>View Output</summary>
<p>

```sh
$ terraform init -upgrade

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "> 4.52.0"...
- Installing hashicorp/azurerm v2.87.0...
- Installed hashicorp/azurerm v2.87.0 (self-signed, key ID 34365D9472D7468F)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has made some changes to the provider dependency selections recorded
in the .terraform.lock.hcl file. Review those changes and commit them to your
version control system if they represent changes you intended to make.

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
### Terraform State

Open your editor and locate the `terraform.tfstate` file.

The Terraform statefile is critical to how Terraform works. The statefile is used to reconcile your Terraform code against:
1. what's in reality (in this case, your resource group deployed to Azure) and
1. what was deployed the last time Terraform was applied (the statefile).

> NOTE: You may also see a `terraform.tfstate.backup` file, but this only appears after making certain changes in your code and running `terraform apply` more than once.

A few things of note in the statefile:
1. The version of Terraform that was used to deploy the resources is listed in `terraform_state`. It is always easier to upgrade Terraform than it is to downgrade due to changes in the way resources *can* be represented in state amongst different versions of Terraform.
1. The `serial` value aligns with the number of time the state has been written. If you try to write state with a lower serial number than what is there, Terraform will throw an error. This is by design to prevent conflicts from happening.
1. The `lineage` is used to calculate the consistency of the statefile when it is used in configuration with remote state storage.

From your command line, execute the following command to inspect the resource addresses in state:

`terraform state list`

<details><summary>View Output</summary>
<p>

```sh
azurerm_resource_group.main
```
</p>
</details>

This allows you to see the resource addresses of the resources Terraform knows about in state.

### Cleanup

When you are done, destroy the infrastructure, you no longer need it.

---

## Resources
- [Terraform Version Contstraints](https://www.terraform.io/docs/language/expressions/version-constraints.html)
- [Provider Requirements](https://www.terraform.io/docs/language/providers/requirements.html)
- [Terraform State](https://www.terraform.io/docs/language/state/index.html)
- [Resource Addressing](https://www.terraform.io/docs/cli/state/resource-addressing.html)

