# Azure Virtual Machine

## Expected Outcome

In this challenge, you will create a Azure Virtual Machine.

You will gradually add Terraform configuration to build all the resources needed to be able to login to the Azure Virtual Machine.

The resources you will use in this challenge:

- Resource Group
- Virtual Network
- Subnet
- Network Interface
- Virtual Machine
- Public IP Address

## How to

### Create the base Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/101-virtual-machine/`.

We will start with a few of the basic resources needed.

Create a `main.tf` file to hold our configuration.

### Create Variables

Create a few variables that will help keep our code clean:

```hcl
variable "prefix" {}

variable "location" {}
```

### Create a Resource Group

Now create a Resource Group to contain all of our infrastructure using the variables to interpolate the parameters:

```hcl
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-vm-rg"
  location = var.location
}
```

### Create Virtual Networking

In order to create an Azure Virtual Machine we need to create a network in which to place it.

Create a Virtual Network and Subnet using a basic CIDR block to allocate an IP block:

```hcl
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.128/25"]
}
```

> Notice that we use the available metadata from the `azurerm_resource_group.main` resource to populate the parameters of other resources.

### Pass in Variables

Create a file called 'terraform.tfvars' and add the folowing variables:

```sh
prefix   = ""
location = ""
```

> Note: Be sure to add a unique prefix, and an appropriate value for location. Do you know where to find valid 'locations'?

### Run Terraform Workflow

Run `terraform init` since this is the first time we are running Terraform from this directory.

Run `terraform plan` where you should see the plan of two new resources, namely the Resource Group and the Virtual Network.

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
      + name     = "PREFIX-vm-rg"
      + tags     = (known after apply)
    }

  # azurerm_subnet.main will be created
  + resource "azurerm_subnet" "main" {
      + address_prefix       = "10.0.0.128/25"
      + id                   = (known after apply)
      + ip_configurations    = (known after apply)
      + name                 = "PREFIX-vm-subnet"
      + resource_group_name  = "PREFIX-vm-rg"
      + virtual_network_name = "PREFIX-vm-vnet"
    }

  # azurerm_virtual_network.main will be created
  + resource "azurerm_virtual_network" "main" {
      + address_space       = [
          + "10.0.0.0/24",
        ]
      + id                  = (known after apply)
      + location            = "centralus"
      + name                = "PREFIX-vm-vnet"
      + resource_group_name = "PREFIX-vm-rg"
      + tags                = (known after apply)

      + subnet {
          + address_prefix = (known after apply)
          + id             = (known after apply)
          + name           = (known after apply)
          + security_group = (known after apply)
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.
```

</p>
</details>

If your plan looks good, go ahead and run `terraform apply` and type "yes" to confirm you want to apply.
When it completes you should see:

```sh
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

### Create the Linux Azure Virtual Machine

Now that we have base networking in place, we will add a Network Interface and Virtual Machine.
We will create a VM with an Azure Marketplace Image for Ubuntu 18.04.

Create the Network Interface resource:

```hcl
resource "azurerm_network_interface" "linux" {
  name                = "${var.prefix}-linuxnic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "config1"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "dynamic"
  }
}
```

Create the Virtual Machine resource:

```hcl
resource "azurerm_virtual_machine" "linux" {
  name                  = "${var.prefix}-linuxvm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.linux.id]
  vm_size               = "Standard_A2_v2"

  storage_os_disk {
    name              = "${var.prefix}linuxvm-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}linuxvm"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}
```

Take note of the OS image:

```hcl
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
```

Run a plan and apply to create both these resources.

### Outputs

Add the following output:

```hcl
output "linux-private-ip" {
  value       = azurerm_network_interface.linux.private_ip_address
  description = "Linux Private IP Address"
}
```

Run `terraform output` to see just these outputs without having to run refresh again.

### Windows VM (extra credit)

Add the Terraform needed to create another VM to the same subnet, but using a Windows Base image.
This will require a slightly different `azurerm_virtual_machine` resource block, can you determine what needs to change based on the online docs?

Hint:

<details><summary>View Output</summary>
<p>

```sh
publisher = "MicrosoftWindowsServer"
offer     = "WindowsServer"
sku       = "2016-Datacenter"
version   = "latest"
```

</p>
</details>

### Scaling the Virtual Machine (extra credit)

Utilize the [count meta arguement](https://www.terraform.io/intro/examples/count.html) to allow for the scaling of VM's.

### Clean up

When you are done, run `terraform destroy` to remove everything we created.

## Advanced areas to explore

1. Extract secrets into required variables.
2. Add a data disk.
3. Add a DNS Label to the Public IP Address.
4. Search for Marketplace Images. (hint: use the Azurel CLI and start with `az vm image -h`)

## Resources

- [Azure Resource Group](https://www.terraform.io/docs/providers/azurerm/r/resource_group.html)
- [Azure Virtual Network](https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html)
- [Azure Subnet](https://www.terraform.io/docs/providers/azurerm/r/subnet.html)
- [Azure Network Interface](https://www.terraform.io/docs/providers/azurerm/r/network_interface.html)
- [Azure Virtual Machine](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html)
- [Public IP Address](https://www.terraform.io/docs/providers/azurerm/r/public_ip.html)
