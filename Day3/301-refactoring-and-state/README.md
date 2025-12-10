# Refactoring Terraform and State

## Expected Outcome

Terraform is code, and as such, you may want to refactor it at some point. This lab will teach you how to plan for and execute a Terraform refactor, paying attention to the changes required in the state file.

## How To

### Apply the Initial Config
1. For this lab, the initial configuration has been provided for you in the `to_refactor` directory. This config should look familiar.
1. Run init/plan/apply. Be sure to pass in a unique `resource_group_name`.
1. Review the state of this deployment with `terraform state list`.

### Refactor
1. Create a new directory named `network`. This is going to serve as our local module directory for all networking resources in our codebase.
1. _Copy_ the following into the module:
    1. `vnet` variable - remove the `default` property completely.
    1. `subnets` variable - remove the `default` property completely.
1. _Move_ the following to the module:
    1. `azurerm_virtual_network`
    1. `azurerm_subnet`
    1. `vnet` output
    1. `subnet` output
1. _Add_ the following to the module:
    1. `resource_group_name` variable
    1. `location` variable
1. _Add_ a `module "network" {}` block and pass in the following variables to the module (these can be passed from the variables in the top-level `main.tf`):
    1. `location`
    1. `resource_group_name`
    1. `vnet`
    1. `subnets`

### Update main.tf
1. Return to the top-level `main.tf` file in the root of `to_refactor`.
1. Add a `module` block and source your module from the `network` directory.
1. Finally, add the following outputs to the top-level `main.tf` (outputs need to "bubble up"):
    1. `vnet` with its value set to `module.network.vnet`
    1. `subnets`... fill in the blank on the value :)
    1. optional `network` which outputs a glob of `module.network`.

### Run a Plan
1. Run an init/plan, passing in your unique `resource_group_name`.
1. What do you notice about your plan? This means our job isn't done. We need to move the resources in state that we moved into the module!

### Move Resources in State
1. Check the resources in state again with `terraform state list`. Make note of the resource addresses for the `azurerm_subnet` resources - remember it's a `for_each` loop, so the resources are indexed by the map name of each object.
1. Move the `azurerm_virtual_network` resource in state to the new resource address in the module using the `terraform state mv` command.
    **HINT** The _new_ resource addresses will be nested under `module.network`.
1. Move each of the 3 `azurerm_subnet` resources into the module.
    **HINT** you need to wrap the resource names in single quotes `''` so you don't  need to escape the index names/
```
terraform state mv '<source address>' '<destination address>'
```

### Validate your work
1. Run a plan... if you see no changes, then your state moves succeeded!
1. Run an apply - check that your outputs "bubble up".

### Prettify your code
1. Run `terraform fmt -recursive` to have the terraform cli auto-format your code RECURSIVELY. Thanks again, terraform cli!

### Run Targeted Destroy
1. Run `terraform state list` to see the resources addresses in state.
1. Run a targeted destroy on the "app" subnet (which is now in a module).
1. Destroy the rest of the infrastructure in your deployment.
