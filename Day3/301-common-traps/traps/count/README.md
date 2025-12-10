# Count Loops

### Setting Up
1. Copy the `main.tf` file and the entire `network` directory from the `traps/scratch` lab we just completed. We'll be adding to this code.
1. If you didn't finish the previous lab in time, or unsure of your work, you may copy the code from `traps/scratch/solution`.

### Add New Features
In order to allow access to your newly deploy "Web", "App" and "DB" subnets, you've been tasked with opening some ports to them. For this exercise, you'll be using `azurerm_network_security_rule` resources and `azurerm_subnet_network_security_group_association` resources.

Because we're simulating common traps, the following instructions are going to take you down a path that we otherwise wouldn't recommend, but, we've all been down this path before :)

You decide to open up ports 22, 80, and 443 to all subnets via the `network` module.

1. Open up `traps/count/network/main.tf` and add a `locals` block.
    1. In the locals block, create a local named `inbound_allow_ports` and set it to a list of strings containing the 3 ports.
1. Create an `azurerm_network_security_group` resource (just one!) and give it the local name `allow_inbound` and name it `InboundFromInternet`.
1. Create an `azurerm_network_security_rule` with the local name `allow_inbound` too.
    1. Add the [count](https://www.terraform.io/language/meta-arguments/count) meta-argument to this block and set its value to the length of your `inbound_allow_ports` local using the `length()` function
    1. Fill out the following values for the remaining attributes of you security rule:
    ```
    name                        = format("allowInbound%s", local.inbound_allow_ports[count.index])
    priority                    = (100 + count.index)
    direction                   = "Inbound"
    access                      = "Allow" # May need to change to "Deny" to make this lab work in governed lab environment!
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = local.inbound_allow_ports[count.index]
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = var.resource_group_name
    network_security_group_name = azurerm_network_security_group.allow_inbound.name
    ```
1. Finally, add an `azurerm_subnet_network_security_group_association` resource to link your `azurerm_network_security_group` resource (NOT the rule) to each subnet.
    1. **HINT** use `for_each` to loop over the `var.subnets`
    1. **HINT** reference the output of the `azurerm_subnet` resource (which is itself a loop) using the `each.key` as the index of the resource value.

### Run Terraform Workflow
1. Apply your infrastructure from the `traps/count` directory.

### Inspect State Addresses
1. Run `terraform state list` to print a list of resource addresses in state.
1. At a glance, which of your `azurerm_network_security_rule` addresses is for port 443?

### Unexpected Changes
After your infrastructure has been running for some time, the security team implements a policy that port 22 is no longer allowed to be opened to the internet. You've been asked to amend your IaC to remove all network secaurity rules that allow inbound traffic from the internet on port 22.

1. Open `traps/count/network/main.tf` and locate the `local.inbound_allow_ports` list you defined prior.
1. Remove the "22" from the list, effectively removing the rule from your `count` loop. Save the file.
1. Run a `terraform plan` from the `traps/count` directory.
    1. What changes do you see?
    1. What changes did you expect to see?
    1. What accounts for the difference? **HINT** run `terraform state list`
    1. Why might `for_each` be preferred over `count`?

### Destroy
1. Run a targeted destroy on the security rule that opens port 80.
1. Destroy the rest of your infrastructure before completing this lab.
