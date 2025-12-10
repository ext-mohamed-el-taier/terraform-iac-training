# Terraform Apply with Plan Output

## Expected Outcome

You will learn how and why to output a Terraform Plan binary, which is then used to Apply.

## How To

### Create Terraform Configuration

For this example, we'll create a simple infrastructure example using Terraform. The main purpose of this lab is to explore what happens when a `terraform plan` is run with the `-output` flag.

Create a `main.tf` file with the following:
1. A variable named `resource_group_name`, which will be used to set the name of the resource group resource later in this example.
1. A variable named `location` which will be used to set the location of all resources in your `main.tf` file.
1. An Azure resource group (`azurerm_resource_group`) that consumes both the `resource_group_name` and `location` variables.

Create a `dev.tfvars` file with the following:
1. A value for `resource_group_name`. This name should have some level of uniqueness to it so it doesn't clash.
1. A value for `location`.

Run a `terraform plan`, specifying `-var-file=dev.tfvars` AND `-out=dev.tfplan`, so your command will look like this:
```sh
terraform plan -var-file=dev.tfvars -out=dev.tfplan
```

### Explore
1. What happens when you open `dev.tfplan` in your editor? What kind of file is it?
1. Run `terraform apply dev.tfplan`. How does this differ from running `terraform plan` and `terraform apply` separately? What about variables?
1. Run `terraform plan -destroy -var-file=dev.tfvars -out=dev.tfplan` followed by `terraform apply dev.tfplan`. What happened? Why?

### Why Outputting a Plan is _preferred_
1. Queue up another plan output by running `terraform plan -var-file=dev.tfvars -out=dev.tfplan`. **DO NOT APPLY (yet).**
1. Edit `dev.tfvars` and change the value of `resource_group_name` to something different than what it was.
1. Run `terraform plan -var-file=dev.tfvars -out=dev-edit.tfplan`.
1. Run `terraform apply dev-edit.tfplan`.
1. Run `terraform apply dev.tfplan`. What happened? Why? Think back to our lab on Terraform state and the `serial` and `lineage` values. How do these come into play here?
1. Come up with at least 2 reasons why outputting a plan is preferred and we will discuss.
