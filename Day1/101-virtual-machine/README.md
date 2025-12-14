# Azure Virtual Machine

## Expected Outcome

In this challenge, you will create Azure Virtual Machines using modern Terraform practices.

You will gradually add Terraform configuration to build all the resources needed to be able to login to the Azure Virtual Machines.

The resources you will use in this challenge:

- Resource Group
- Virtual Network
- Subnet
- Network Interface
- Linux Virtual Machine
- Public IP Address

## How to

### Create the base Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/101-virtual-machine/`.

We will start with a few of the basic resources needed.

Create a `main.tf` file to hold our configuration.

First, configure the required providers:

```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

### Create Variables

Create a few variables that will help keep our code clean:

```hcl
variable "prefix" {
  type        = string
  description = "Prefix for all resource names"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
}
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

Create a file called `terraform.tfvars` and add the following variables:

```hcl
prefix   = "yourname"
location = "eastus"
```

> Note: Be sure to add a unique prefix, and an appropriate value for location. You can find valid locations by running `az account list-locations -o table`.

### Run Terraform Workflow

Run `terraform init` since this is the first time we are running Terraform from this directory.

Run `terraform plan` where you should see the plan of three new resources: Resource Group, Virtual Network, and Subnet.

<details><summary>View Output</summary>
<p>

```sh
$ terraform plan

Terraform will perform the following actions:

  # azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "yourname-vm-rg"
    }

  # azurerm_subnet.main will be created
  + resource "azurerm_subnet" "main" {
      + address_prefixes     = ["10.0.0.128/25"]
      + id                   = (known after apply)
      + name                 = "yourname-subnet"
      + resource_group_name  = "yourname-vm-rg"
      + virtual_network_name = "yourname-vnet"
    }

  # azurerm_virtual_network.main will be created
  + resource "azurerm_virtual_network" "main" {
      + address_space       = ["10.0.0.0/24"]
      + id                  = (known after apply)
      + location            = "eastus"
      + name                = "yourname-vnet"
      + resource_group_name = "yourname-vm-rg"
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

Now that we have base networking in place, we will add a Public IP, Network Interface, and Virtual Machine.
We will create a VM with an Azure Marketplace Image for Ubuntu 22.04 LTS.

Create the Public IP resource:

```hcl
resource "azurerm_public_ip" "linux" {
  name                = "${var.prefix}-linux-pubip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
```

Create the Network Interface resource:

```hcl
resource "azurerm_network_interface" "linux" {
  name                = "${var.prefix}-linux-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "config1"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux.id
  }
}
```

Create the Linux Virtual Machine resource:

```hcl
resource "azurerm_linux_virtual_machine" "linux" {
  name                            = "${var.prefix}-linux-vm"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = "Standard_A2_v2"
  admin_username                  = "testadmin"
  admin_password                  = "Password1234!"
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.linux.id]

  os_disk {
    name                 = "${var.prefix}-linux-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
```

Take note of the OS image reference for Ubuntu 22.04 LTS:

```hcl
source_image_reference {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts"
  version   = "latest"
}
```

Run a plan and apply to create these resources.

### Outputs

Add the following outputs:

```hcl
output "linux-private-ip" {
  value       = azurerm_network_interface.linux.private_ip_address
  description = "Linux Private IP Address"
}

output "linux-public-ip" {
  value       = azurerm_public_ip.linux.ip_address
  description = "Linux Public IP Address"
}
```

Run `terraform apply` to see these outputs, or run `terraform output` after applying.

### Windows VM (extra credit)

Add the Terraform needed to create another VM to the same subnet, but using a Windows Base image.
Use `azurerm_windows_virtual_machine` for Windows VMs.

Hint:

<details><summary>View Output</summary>
<p>

```hcl
resource "azurerm_windows_virtual_machine" "windows" {
  name                  = "${var.prefix}-windows-vm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = "Standard_A2_v2"
  admin_username        = "testadmin"
  admin_password        = "Password1234!"
  network_interface_ids = [azurerm_network_interface.windows.id]

  os_disk {
    name                 = "${var.prefix}-windows-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
```

</p>
</details>

### Scaling Virtual Machines with for_each (extra credit)

Use the `for_each` meta-argument to create multiple VMs from a map variable. This is the recommended approach for scaling resources because each instance is identified by a stable key rather than an index.

First, define a variable for your VMs:

```hcl
variable "vm_list" {
  type = map(object({
    name = string
    zone = string
  }))
  default = {
    "web" = {
      name = "webserver"
      zone = "1"
    }
    "app" = {
      name = "appserver"
      zone = "2"
    }
  }
  description = "Map of VMs with their unique attributes"
}
```

Then create your resources using `for_each`:

```hcl
resource "azurerm_linux_virtual_machine" "main" {
  for_each = var.vm_list

  name                            = "${var.prefix}-${each.value.name}"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = "Standard_A2_v2"
  zone                            = each.value.zone
  admin_username                  = "testadmin"
  admin_password                  = "Password1234!"
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.main[each.key].id]

  os_disk {
    name                 = "${var.prefix}-${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
```

> **Why `for_each` over `count`?**
> - With `for_each`, resources are identified by their key (e.g., "web", "app"). Removing one doesn't affect the others.
> - Adding or removing VMs only impacts those specific resources, not the entire set.

See the `solution-map/` folder for a complete working example.

### Clean up

When you are done, run `terraform destroy` to remove everything we created.

## Advanced areas to explore

1. Extract secrets into required variables or use Azure Key Vault.
2. Add a data disk using `azurerm_managed_disk` and `azurerm_virtual_machine_data_disk_attachment`.
3. Add a DNS Label to the Public IP Address.
4. Search for Marketplace Images using: `az vm image list --output table`
5. Use SSH keys instead of passwords for authentication.

## Resources

- [Azure Resource Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)
- [Azure Virtual Network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- [Azure Subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)
- [Azure Network Interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)
- [Azure Linux Virtual Machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)
- [Azure Windows Virtual Machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine)
- [Azure Public IP Address](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)
- [Terraform for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
