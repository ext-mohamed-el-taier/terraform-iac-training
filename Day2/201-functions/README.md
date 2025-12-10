# Functions

## Expected Outcome

You will discover Terraform functions and how to use a handful of them.

## How To

### Create Terraform Configuration

You will create a `main.tf` file with the following:
1. A `terraform {}` block declaring the version of Terraform to use as well as the `azurerm` provider within the `required_providers` block.
1. An `azurerm` block for the provider configuration.
1. 3 [variable blocks](https://www.terraform.io/language/values/variables):
    1. `resource_group_name` of [type](https://www.terraform.io/language/expressions/types) "string" (validation condition optional).
    1. `location` of [type](https://www.terraform.io/language/expressions/types) "string" (validation condition optional).
    1. `vnet_name` of [type](https://www.terraform.io/language/expressions/types) "string" (validation condition optional).
    1. `vnet_cidr` of [type](https://www.terraform.io/language/expressions/types) "string" (validation condition optional).
1. A [Resource Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group).
1. Create an [azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) resource block and use the value of the `vnet_cidr` variable as the value for the `address_space` property (NOTE it's a list type, so place the var between brackets `[]`) . DO NOT add any subnets (yet)!
1. Create a `dev.tfvars` file and fill out the values for your variables.
  Note: Your `vnet_cidr` should conform to [RFC1918](https://datatracker.ietf.org/doc/html/rfc1918#section-3) address space, be in CIDR format, and contain enough IP addresses for you to split it up cleanly into 3 subnets. I recommend a `/16` for this lab.
  For example, pick an address space such as `10.20.0.0/16` and if you get an error, try changing the number `20` in the second octet to a different number between 1 and 254.

### Init Terraform and Use the Console
1. `terraform init` from the directory where your `main.tf` is.
1. Run `terraform console -var-file=dev.tfvars` to drop into a console using your tfvars file as input. The console is a GREAT place for exploring functions! And we're going to just that.
1. Explore the console:
    1. Execute `var.vnet_cidr` to see the value of your variable input. It should match what's in your dev.tfvars file.
    1. We're going to use the [cidrsubnet function](https://www.terraform.io/language/functions/cidrsubnet) to calculate 3 CIDR blocks for use by the subnets that will belong to our vnet. We want to carve out 3 subnets with a /24. Using the `cidrsubnet` function, figure out how to create those 3 subnets!
    HINT: Use `var.vnet_cidr` as the value for `prefix` in `cidrsubnet()`
    HINT: The `newbits` value on a /16 CIDR should be set to `8` because 16+8=24...
    1. Let's also make the subnet names a concatentation that includes the `var.vnet_name` variable using the [format function](https://www.terraform.io/language/functions/format). Try it out via the console before using it your Terraform configuration!

### Add Subnets to Terraform
1. Create 3 [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) resource blocks, one for "web", one for "app", and one for "db". Use `cidrsubnet` and `format` to help define the properties of each resource - refer to your console session if you need to look values up!

### Plan and Apply
1. Run the Terraform workflow to Plan (with output) and Apply your IaC configuration.

### Targeted Destroy
1. Run `terraform state list` to see a list of the resource addresses in your deployment's statefile.
1. Run a [targeted destroy](https://www.terraform.io/cli/commands/plan#target-address) on the "app" subnet.
    1. **HINT** use `terraform destroy -h` from the command line to see how to pass the target option.
    1. We recommend using single quotes `'` around the resource address from the command line.
    1. Don't forget to pass in your .tfvars file with `-var-file=`.
1. Cleanup the rest of your resources by destroying them when you're finished.

## Questions
1. What do you notice about the `address_prefixes` and `name` values in your subnets in the plan output?
1. How did `terraform console` help you experiment with these functions? What would the alternative (running a plan) be less preferable in this situation?
1. How do the capabilities of functions `terraform console` help shape how you define your variables?

## Resources
- [Local Values](https://www.terraform.io/language/values/locals)
- [RFC1918 Address Space](https://datatracker.ietf.org/doc/html/rfc1918#section-3)
- [azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)
- [cidrsubnet function](https://www.terraform.io/language/functions/cidrsubnet)
- [format function](https://www.terraform.io/language/functions/format)
