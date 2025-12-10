# Workstation Configuration

In this lab you will install all the tooling into your user account on the BlackRock "ADM ADM" jumphost.

### Set Proxy Config
1. Edit your `~/.bashrc` file (you can create it if it doesn't exist) with the following:
    ```sh
		export http_proxy=http://httpproxy:8080
		export ftp_proxy=http://ftpproxy:8080
		export https_proxy=http://httpproxy:8080
		export HTTPS_PROXY=http://httpproxy:8080
		export HTTP_PROXY=http://httpproxy:8080
		export no_proxy=.bfm.com,.blackrock.com,.blkint.com,localhost,puppet-pe
    ```
1. Save and close this file, then source it with `source ~/.bashrc`.
1. Validate the proxy config is there by running `env | grep -i PROXY`. You MUST have the proxy variables in your shell's environment before continuing.

### Download Terraform
1. Make sure you're current working directory is somewhere within your home directory.
1. Download Terraform using `wget`. For this week's labs, we'll be using Terraform 0.14.8.
    ```sh
    wget https://releases.hashicorp.com/terraform/0.14.8/terraform_0.14.8_linux_386.zip
    ```
1. Extract the `terraform` binary, and add it to your PATH.
1. Confirm it is working by running `which terraform` and `terraform version`.

### Verify Installations

Verify you can run the following commands, with the appropriate results:

> **Note:** Versions may be greater than what is listed here.

**git**
```sh
$ git --version
git version 2.22.0.windows.1
```

**azure cli**
```sh
$ az -v
azure-cli                         2.X.X

...other dependencies and information...

Legal docs and information: aka.ms/AzureCliLegal

Your CLI is up-to-date.
```

**terraform**
```sh
$ terraform -v
Terraform v0.14.8
```

### Azure DevOps Access

This lab repo is stored in Azure DevOps at [https://dev.azure.com/1A4D/Cirrus/_git/TerraformTraining](https://dev.azure.com/1A4D/Cirrus/_git/TerraformTraining). You will need to clone this repo to your ADM home directory to complete the labs.

1. Run `git clone git@ssh.dev.azure.com:v3/1A4d/Cirrus/TerraformTraining`
1. If you get an "AccessDenied" message, ensure that:
    1. Your public key has been [uploaded to Azure DevOps](https://dev.azure.com/1A4d/_details/security/keys/index)
    1. You have an `~/.ssh/config` file configured to use the proxy and, optionally, point to your private key:
        ```sh
       	StrictHostKeyChecking no
				UserKnownHostsFile /dev/null
				LogLevel ERROR
				CheckHostIP no
				ConnectTimeout=3
				ServerAliveInterval=2
				Host ssh.dev.azure.com
						User git
						Port 22
						Hostname ssh.dev.azure.com
						TCPKeepAlive yes
						IdentitiesOnly yes
						#IdentityFile ~/.ssh/custom_key
						ProxyCommand /usr/bin/nc --proxy webproxy-http.blackrock.com:8080 %h %p
        ```

### Login to Azure

Login with the Azure CLI by running `az login`.

```sh
$ az login --tenant BLACKROCK-ONEALADDIN
Note, we have launched a browser for you to login. For old experience with device code, use "az login --use-device-code"
You have logged in. Now let us find all the subscriptions to which you have access...
```

Once complete, verify Azure CLI Access by running `az account show -o table`.

```sh
$ az account show -o table
EnvironmentName    IsDefault    Name                             State    TenantId
-----------------  -----------  -------------------------------  -------  ------------------------------------
AzureCloud         True         Visual Studio Premium with MSDN  Enabled  GUID
```

Ensure that you've set your az cli context to the "ALADDIN-TFTRAINING-LAB" subscription (you should have received an email invite).
* You may need to visit the Privileged Identity Management page from the portal in order to Activate your access.

```sh
az account set --subscription 'ALADDIN-TFTRAINING-LAB'
```

You are now connecting to Azure from the Azure CLI!

As one last step here, login to the [Azure Portal](https://portal.azure.com/), this will be useful to see the resources get created.
