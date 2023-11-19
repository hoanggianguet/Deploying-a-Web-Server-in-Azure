# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

## Table of Contents
- [Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure](#azure-infrastructure-operations-project-deploying-a-scalable-iaas-web-server-in-azure)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Getting Started](#getting-started)
  - [Install our dependencies](#install-our-dependencies)
  - [Deploy a policy](#deploy-a-policy)
  - [Create and configure our environment variables](#create-and-configure-our-environment-variables)
    - [Login to Azure from Azure CLI](#login-to-azure-from-azure-cli)
    - [Create resource group](#create-resource-group)
    - [Create Azure credentials](#create-azure-credentials)
  - [Deploy the Packer template](#deploy-the-packer-template)
  - [Deploy the infrastructure as code with Terraform](#deploy-the-infrastructure-as-code-with-terraform)
    - [Output](#output)
  - [References](#references)

## Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

Infrastructure as Code (IaC) is the management of infrastructure (networks, virtual machines, load balancers, and connection topology) in a descriptive model, using the same versioning as DevOps team uses for source code. Like the principle that the same source code generates the same binary, an IaC model generates the same environment every time it is applied. IaC is a key DevOps practice and is used in conjunction with continuous delivery.

For this project we will use Azure as our cloud provider, in conjunction with Terraform for our IaC needs, and Packer, which will help us with the creation of virtual machine images. 

We will use a Packer template (in JSON format), with a Terraform template to deploy a customizable, scalable web server in Azure.

## Getting Started
In this project we will follow the following steps:
1. Install our dependencies
2. Deploy a policy
3. Create and configure our environment variables
4. Deploy the Packer template
5. Deploy the infrastructure as code with Terraform

## Install our dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

## Deploy a policy
We will deploy a security policy that enforces that all the resources that we deploy have a tag, this is to have a better understanding of what each resource does. The rules of the policy are defined in the ```enforceTag.json``` file. To deploy the policy we write in our command line:
```bash
az policy definition create --name tagging-policy --rules ./tagging-policy.json --params ./policy-definition-params.json --display-name "Enforce resource tagging policy" --description "This policy ensures all indexed resources in your subscription have tags and deny deployment if they do not." --mode Indexed
az policy assignment create --name tagging-policy --policy tagging-policy --params ./policy-assignment-params.json --display-name "Require a tag on resources" --description "Enforces a required tag and its value. Does not apply to resource groups." 
```

When we have done this, we should wait a few minutes and then enter the following command:
```bash
az policy assignment list
```

If everything went correctly, we should be able to see a json definition of our new policy:

![Policy assignment](images/az-policy-assignment-list.PNG)

We are ready to continue to the next step.

## Create and configure our environment variables
We will need to configure environment variables in our local computer to use the ```server.json``` Packer template. We will need to create an Azure resource group and then get 4 variables that we can obtain from the resource group.

### Login to Azure from Azure CLI
Ensure that you are logged in to your Azure Subscription

```bash
az login
```

### Create resource group
During the build process, Packer creates temporary Azure resources as it builds the source VM. To capture that source VM for use as an image, we must define a resource group. The output from the Packer build process is stored in this resource group.

```bash
 az group create -n Azuredevops -l eastus
```

### Create Azure credentials
Packer authenticates with Azure using a service principal. An Azure service principal is a security identity that you can use with apps, services, and automation tools like Packer. We control and define the permissions as to what operations the service principal can perform in Azure.

```bash
az ad sp create-for-rbac --role Contributor --scopes /subscriptions/<subscription_id> --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
```

We will also need to obtain the Azure Subscription ID with the following command:

```bash
az account show --query "{ subscription_id: id }"
```

With this 4 variables identified, we can now go to the terminal and export the environment variables with the following commands:

```bash
export ARM_CLIENT_ID=your_client_id
export ARM_CLIENT_SECRET=your_client_secret
export ARM_SUBSCRIPTION_ID=your_suscription_id
export ARM_TENANT_ID=your_tenant_id
```

Once you have exported this environment variables, use the ```printenv``` command to check that they are properly configured:

```bash
printenv
```

We can now proceed with the exercise

## Deploy the Packer template

Now we can deploy our Packer template with the following command:

```bash
packer build server.json
```



## Deploy the infrastructure as code with Terraform

The first step is to run the following Terraform command to download all necessary plugins:

```bash
terraform init
```

Should you wish to change the number of virtual machines that are deployed, or the resource group prefix, or anything else, feel free to change it in the ```vars.tf``` file. Just change the default value, or remove it and set it when you will deploy it.

Before we can plan our solution, we have to take into account that we have already created the resource group for our PackerImage, and Terraform does not allow to deploy resources into existing resource groups. 

To fix this we need to import the existing resource group to Terraform so that it knows to deploy our resources there. To do that we have to run the following command:

```bash
terraform import azurerm_resource_group.main /subscriptions/{subsriptionId}/resourceGroups/{resourceGroupName}
```

Once that is done, we can run the following command to plan our solution:

```bash
terraform plan -out solution.plan
``` 

To create our infrastructure in Azure we have to run the following command:

```bash
terraform apply
```

After we have deployed our infrastructure, we should get a confirmation message from Terraform

![Apply complete bash](images/apply-complete-cmd.PNG)

We can also check if the resources are deployed in the Azure Portal, the result will look something like the following:

![Apply complete portal](images/apply-complete-portal.PNG)

We can also check all the resources that we just deployed in Terraform with the following command:

```bash
terraform show
```

Finally, remember to destroy the resources:

```bash
terraform destroy
```
### Output

2. Output after create a server image using packer
``` bash
PS C:\Users\hoang\Desktop\Azure DevOps\nd082-Azure-Cloud-DevOps-Starter-Code-master\C1 - Azure Infrastructure Operations\project\starter_files\packer> packer build server.json
Warning: Bundled plugins used

This template relies on the use of plugins bundled into the Packer binary.
The practice of bundling external plugins into Packer will be removed in an
upcoming version.

To remove this warning and ensure builds keep working you can install these
external plugins with the 'packer plugins install' command

* packer plugins install github.com/hashicorp/azure

Alternatively, if you upgrade your templates to HCL2, you can use 'packer init'
with a 'required_plugins' block to automatically install external plugins.

You can try HCL2 by running 'packer hcl2_upgrade C:\Users\hoang\Desktop\Azure
DevOps\nd082-Azure-Cloud-DevOps-Starter-Code-master\C1 - Azure Infrastructure
Operations\project\starter_files\packer\server.json'


azure-arm: output will be in this color.

==> azure-arm: Running builder ...
==> azure-arm: Getting tokens using client secret
==> azure-arm: Getting tokens using client secret
    azure-arm: Creating Azure Resource Manager (ARM) client ...
==> azure-arm: Getting source image id for the deployment ...
==> azure-arm:  -> SourceImageName: '/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/providers/Microsoft.Compute/locations/East US/publishers/Canonical/ArtifactTypes/vmimage/offers/UbuntuServer/skus/18.04-LTS/versions/latest'
==> azure-arm: Creating resource group ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-y2xukl5fn3'
==> azure-arm:  -> Location          : 'East US'
==> azure-arm:  -> Tags              :
==> azure-arm:  ->> create-by : giangh2
==> azure-arm: Validating deployment template ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-y2xukl5fn3'
==> azure-arm:  -> DeploymentName    : 'pkrdpy2xukl5fn3'
==> azure-arm: Deploying deployment template ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-y2xukl5fn3'
==> azure-arm:  -> DeploymentName    : 'pkrdpy2xukl5fn3'
==> azure-arm: Getting the VM's IP address ...
==> azure-arm:  -> ResourceGroupName   : 'pkr-Resource-Group-y2xukl5fn3'
==> azure-arm:  -> PublicIPAddressName : 'pkripy2xukl5fn3'
==> azure-arm:  -> NicName             : 'pkrniy2xukl5fn3'
==> azure-arm:  -> Network Connection  : 'PublicEndpoint'
==> azure-arm:  -> IP Address          : '20.232.193.184'
==> azure-arm: Waiting for SSH to become available...
==> azure-arm: Connected to SSH!
==> azure-arm: Provisioning with shell script: C:\Users\hoang\AppData\Local\Temp\packer-shell1346211556
==> azure-arm: + echo Hello, World!
==> azure-arm: Querying the machine's properties ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-y2xukl5fn3'
==> azure-arm:  -> ComputeName       : 'pkrvmy2xukl5fn3'
==> azure-arm:  -> Managed OS Disk   : '/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/pkr-Resource-Group-y2xukl5fn3/providers/Microsoft.Compute/disks/pkrosy2xukl5fn3'
==> azure-arm: Querying the machine's additional disks properties ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-y2xukl5fn3'
==> azure-arm:  -> ComputeName       : 'pkrvmy2xukl5fn3'
==> azure-arm: Powering off machine ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-y2xukl5fn3'
==> azure-arm:  -> ComputeName       : 'pkrvmy2xukl5fn3'
==> azure-arm: Generalizing machine ...
==> azure-arm:  -> Compute ResourceGroupName : 'pkr-Resource-Group-y2xukl5fn3'
==> azure-arm:  -> Compute Name              : 'pkrvmy2xukl5fn3'
==> azure-arm:  -> Compute Location          : 'East US'
==> azure-arm: Capturing image ...
==> azure-arm:  -> Image ResourceGroupName   : 'Azuredevops'
==> azure-arm:  -> Image Name                : 'packer-image'
==> azure-arm:  -> Image Location            : 'East US'
==> azure-arm: 
==> azure-arm: Deleting individual resources ...
==> azure-arm: Adding to deletion queue -> Microsoft.Compute/virtualMachines : 'pkrvmy2xukl5fn3'
==> azure-arm: Adding to deletion queue -> Microsoft.Network/networkInterfaces : 'pkrniy2xukl5fn3'
==> azure-arm: Adding to deletion queue -> Microsoft.Network/publicIPAddresses : 'pkripy2xukl5fn3'
==> azure-arm: Adding to deletion queue -> Microsoft.Network/virtualNetworks : 'pkrvny2xukl5fn3'
==> azure-arm: Attempting deletion -> Microsoft.Network/publicIPAddresses : 'pkripy2xukl5fn3'
==> azure-arm: Waiting for deletion of all resources...
==> azure-arm: Attempting deletion -> Microsoft.Network/networkInterfaces : 'pkrniy2xukl5fn3'
==> azure-arm: Attempting deletion -> Microsoft.Network/virtualNetworks : 'pkrvny2xukl5fn3'
==> azure-arm: Attempting deletion -> Microsoft.Compute/virtualMachines : 'pkrvmy2xukl5fn3'
==> azure-arm: Error deleting resource. Will retry.
==> azure-arm: Name: pkripy2xukl5fn3
==> azure-arm: Error: network.PublicIPAddressesClient#Delete: Failure sending request: StatusCode=400 -- Original Error: Code="PublicIPAddressCannotBeDeleted" Message="Public IP address /subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/pkr-Resource-Group-y2xukl5fn3/providers/Microsoft.Network/publicIPAddresses/pkripy2xukl5fn3 can not be deleted since it is still allocated to resource /subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/pkr-Resource-Group-y2xukl5fn3/providers/Microsoft.Network/networkInterfaces/pkrniy2xukl5fn3/ipConfigurations/ipconfig. In order to delete the public IP, disassociate/detach the Public IP address from the resource.  To learn how to do this, see aka.ms/deletepublicip." Details=[]
==> azure-arm:
==> azure-arm: Error deleting resource. Will retry.
==> azure-arm: Name: pkrvny2xukl5fn3
==> azure-arm: Error: network.VirtualNetworksClient#Delete: Failure sending request: StatusCode=400 -- Original Error: Code="InUseSubnetCannotBeDeleted" Message="Subnet pkrsny2xukl5fn3 is in use by /subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/PKR-RESOURCE-GROUP-Y2XUKL5FN3/providers/Microsoft.Network/networkInterfaces/PKRNIY2XUKL5FN3/ipConfigurations/IPCONFIG and cannot be deleted. In order to delete the subnet, delete all the resources within the subnet. See aka.ms/deletesubnet." Details=[]
==> azure-arm:
==> azure-arm: Attempting deletion -> Microsoft.Network/publicIPAddresses : 'pkripy2xukl5fn3'
==> azure-arm: Attempting deletion -> Microsoft.Network/virtualNetworks : 'pkrvny2xukl5fn3'
==> azure-arm:  Deleting -> Microsoft.Compute/disks : '/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/pkr-Resource-Group-y2xukl5fn3/providers/Microsoft.Compute/disks/pkrosy2xukl5fn3'
==> azure-arm: Removing the created Deployment object: 'pkrdpy2xukl5fn3'
==> azure-arm: 
==> azure-arm: Cleanup requested, deleting resource group ...
==> azure-arm: Resource group has been deleted.
Build 'azure-arm' finished after 4 minutes 48 seconds.

==> Wait completed after 4 minutes 48 seconds

==> Builds finished. The artifacts of successful builds are:
--> azure-arm: Azure.ResourceManagement.VMImage:

OSType: Linux
ManagedImageResourceGroupName: Azuredevops
ManagedImageName: packer-image
ManagedImageId: /subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/packer-image
ManagedImageLocation: East US
```
3. Output after importing existing resource group to terraform state
``` bash
PS C:\Users\hoang\Desktop\Azure DevOps\nd082-Azure-Cloud-DevOps-Starter-Code-master\C1 - Azure Infrastructure Operations\project\starter_files\terraform> terraform import azurerm_resource_group.main /subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops
azurerm_resource_group.main: Importing from ID "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops"...
data.azurerm_image.packer-image: Reading...
azurerm_resource_group.main: Import prepared!
  Prepared azurerm_resource_group for import
azurerm_resource_group.main: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops]
data.azurerm_image.packer-image: Read complete after 1s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/packer-image]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```
4. Output after executing the terraform plan command
``` bash
PS C:\Users\hoang\Desktop\Azure DevOps\nd082-Azure-Cloud-DevOps-Starter-Code-master\C1 - Azure Infrastructure Operations\project\starter_files\terraform> terraform plan -out solution.plan
data.azurerm_image.packer-image: Reading...
azurerm_resource_group.main: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops]
data.azurerm_image.packer-image: Read complete after 2s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/packer-image]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # azurerm_availability_set.main will be created
  + resource "azurerm_availability_set" "main" {
      + id                           = (known after apply)
      + location                     = "eastus"
      + managed                      = true
      + name                         = "udacity-aset"
      + platform_fault_domain_count  = 2
      + platform_update_domain_count = 5
      + resource_group_name          = "Azuredevops"
      + tags                         = {
          + "create-by" = "giangh2"
        }
    }

  # azurerm_lb.main will be created
  + resource "azurerm_lb" "main" {
      + id                   = (known after apply)
      + location             = "eastus"
      + name                 = "udacity-lb"
      + private_ip_address   = (known after apply)
      + private_ip_addresses = (known after apply)
      + resource_group_name  = "Azuredevops"
      + sku                  = "Basic"
      + sku_tier             = "Regional"
      + tags                 = {
          + "create-by" = "giangh2"
        }

      + frontend_ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + id                                                 = (known after apply)
          + inbound_nat_rules                                  = (known after apply)
          + load_balancer_rules                                = (known after apply)
          + name                                               = "udacity-frontendip"
          + outbound_rules                                     = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = (known after apply)
          + private_ip_address_version                         = (known after apply)
          + public_ip_address_id                               = (known after apply)
          + public_ip_prefix_id                                = (known after apply)
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_lb_backend_address_pool.main will be created
  + resource "azurerm_lb_backend_address_pool" "main" {
      + backend_ip_configurations = (known after apply)
      + id                        = (known after apply)
      + inbound_nat_rules         = (known after apply)
      + load_balancing_rules      = (known after apply)
      + loadbalancer_id           = (known after apply)
      + name                      = "udacity-bap"
      + outbound_rules            = (known after apply)
    }

  # azurerm_linux_virtual_machine.main[0] will be created
  + resource "azurerm_linux_virtual_machine" "main" {
      + admin_password                                         = (sensitive value)
      + admin_username                                         = "udacityuser"
      + allow_extension_operations                             = true
      + availability_set_id                                    = (known after apply)
      + bypass_platform_safety_checks_on_user_schedule_enabled = false
      + computer_name                                          = (known after apply)
      + disable_password_authentication                        = false
      + extensions_time_budget                                 = "PT1H30M"
      + id                                                     = (known after apply)
      + location                                               = "eastus"
      + max_bid_price                                          = -1
      + name                                                   = "udacity-vm-0"
      + network_interface_ids                                  = (known after apply)
      + patch_assessment_mode                                  = "ImageDefault"
      + patch_mode                                             = "ImageDefault"
      + platform_fault_domain                                  = -1
      + priority                                               = "Regular"
      + private_ip_address                                     = (known after apply)
      + private_ip_addresses                                   = (known after apply)
      + provision_vm_agent                                     = true
      + public_ip_address                                      = (known after apply)
      + public_ip_addresses                                    = (known after apply)
      + resource_group_name                                    = "Azuredevops"
      + size                                                   = "Standard_D2s_v3"
      + source_image_id                                        = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/packer-image"
      + tags                                                   = {
          + "create-by" = "giangh2"
        }
      + virtual_machine_id                                     = (known after apply)

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + name                      = "udacity-osdisk-0"
          + storage_account_type      = "Standard_LRS"
          + write_accelerator_enabled = false
        }
    }

  # azurerm_linux_virtual_machine.main[1] will be created
  + resource "azurerm_linux_virtual_machine" "main" {
      + admin_password                                         = (sensitive value)
      + admin_username                                         = "udacityuser"
      + allow_extension_operations                             = true
      + availability_set_id                                    = (known after apply)
      + bypass_platform_safety_checks_on_user_schedule_enabled = false
      + computer_name                                          = (known after apply)
      + disable_password_authentication                        = false
      + extensions_time_budget                                 = "PT1H30M"
      + id                                                     = (known after apply)
      + location                                               = "eastus"
      + max_bid_price                                          = -1
      + name                                                   = "udacity-vm-1"
      + network_interface_ids                                  = (known after apply)
      + patch_assessment_mode                                  = "ImageDefault"
      + patch_mode                                             = "ImageDefault"
      + platform_fault_domain                                  = -1
      + priority                                               = "Regular"
      + private_ip_address                                     = (known after apply)
      + private_ip_addresses                                   = (known after apply)
      + provision_vm_agent                                     = true
      + public_ip_address                                      = (known after apply)
      + public_ip_addresses                                    = (known after apply)
      + resource_group_name                                    = "Azuredevops"
      + size                                                   = "Standard_D2s_v3"
      + source_image_id                                        = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/packer-image"
      + tags                                                   = {
          + "create-by" = "giangh2"
        }
      + virtual_machine_id                                     = (known after apply)

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + name                      = "udacity-osdisk-1"
          + storage_account_type      = "Standard_LRS"
          + write_accelerator_enabled = false
        }
    }

  # azurerm_managed_disk.main[0] will be created
  + resource "azurerm_managed_disk" "main" {
      + create_option                     = "Empty"
      + disk_iops_read_only               = (known after apply)
      + disk_iops_read_write              = (known after apply)
      + disk_mbps_read_only               = (known after apply)
      + disk_mbps_read_write              = (known after apply)
      + disk_size_gb                      = 1
      + id                                = (known after apply)
      + location                          = "eastus"
      + logical_sector_size               = (known after apply)
      + max_shares                        = (known after apply)
      + name                              = "udacity-md-0"
      + optimized_frequent_attach_enabled = false
      + performance_plus_enabled          = false
      + public_network_access_enabled     = true
      + resource_group_name               = "Azuredevops"
      + source_uri                        = (known after apply)
      + storage_account_type              = "Standard_LRS"
      + tags                              = {
          + "create-by" = "giangh2"
        }
      + tier                              = (known after apply)
    }

  # azurerm_managed_disk.main[1] will be created
  + resource "azurerm_managed_disk" "main" {
      + create_option                     = "Empty"
      + disk_iops_read_only               = (known after apply)
      + disk_iops_read_write              = (known after apply)
      + disk_mbps_read_only               = (known after apply)
      + disk_mbps_read_write              = (known after apply)
      + disk_size_gb                      = 1
      + id                                = (known after apply)
      + location                          = "eastus"
      + logical_sector_size               = (known after apply)
      + max_shares                        = (known after apply)
      + name                              = "udacity-md-1"
      + optimized_frequent_attach_enabled = false
      + performance_plus_enabled          = false
      + public_network_access_enabled     = true
      + resource_group_name               = "Azuredevops"
      + source_uri                        = (known after apply)
      + storage_account_type              = "Standard_LRS"
      + tags                              = {
          + "create-by" = "giangh2"
        }
      + tier                              = (known after apply)
    }

  # azurerm_network_interface.main[0] will be created
  + resource "azurerm_network_interface" "main" {
      + applied_dns_servers           = (known after apply)
      + dns_servers                   = (known after apply)
      + enable_accelerated_networking = false
      + enable_ip_forwarding          = false
      + id                            = (known after apply)
      + internal_dns_name_label       = (known after apply)
      + internal_domain_name_suffix   = (known after apply)
      + location                      = "eastus"
      + mac_address                   = (known after apply)
      + name                          = "udacity-nic-0"
      + private_ip_address            = (known after apply)
      + private_ip_addresses          = (known after apply)
      + resource_group_name           = "Azuredevops"
      + tags                          = {
          + "create-by" = "giangh2"
        }
      + virtual_machine_id            = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "udacity-ipconfig"
          + primary                                            = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = "Dynamic"
          + private_ip_address_version                         = "IPv4"
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_network_interface.main[1] will be created
  + resource "azurerm_network_interface" "main" {
      + applied_dns_servers           = (known after apply)
      + dns_servers                   = (known after apply)
      + enable_accelerated_networking = false
      + enable_ip_forwarding          = false
      + id                            = (known after apply)
      + internal_dns_name_label       = (known after apply)
      + internal_domain_name_suffix   = (known after apply)
      + location                      = "eastus"
      + mac_address                   = (known after apply)
      + name                          = "udacity-nic-1"
      + private_ip_address            = (known after apply)
      + private_ip_addresses          = (known after apply)
      + resource_group_name           = "Azuredevops"
      + tags                          = {
          + "create-by" = "giangh2"
        }
      + virtual_machine_id            = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "udacity-ipconfig"
          + primary                                            = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = "Dynamic"
          + private_ip_address_version                         = "IPv4"
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_network_interface_backend_address_pool_association.main[0] will be created
  + resource "azurerm_network_interface_backend_address_pool_association" "main" {
      + backend_address_pool_id = (known after apply)
      + id                      = (known after apply)
      + ip_configuration_name   = "udacity-ipconfig"
      + network_interface_id    = (known after apply)
    }

  # azurerm_network_interface_backend_address_pool_association.main[1] will be created
  + resource "azurerm_network_interface_backend_address_pool_association" "main" {
      + backend_address_pool_id = (known after apply)
      + id                      = (known after apply)
      + ip_configuration_name   = "udacity-ipconfig"
      + network_interface_id    = (known after apply)
    }

  # azurerm_network_interface_security_group_association.main[0] will be created
  + resource "azurerm_network_interface_security_group_association" "main" {
      + id                        = (known after apply)
      + network_interface_id      = (known after apply)
      + network_security_group_id = (known after apply)
    }

  # azurerm_network_interface_security_group_association.main[1] will be created
  + resource "azurerm_network_interface_security_group_association" "main" {
      + id                        = (known after apply)
      + network_interface_id      = (known after apply)
      + network_security_group_id = (known after apply)
    }

  # azurerm_network_security_group.main will be created
  + resource "azurerm_network_security_group" "main" {
      + id                  = (known after apply)
      + location            = "eastus"
      + name                = "udacity-nsg"
      + resource_group_name = "Azuredevops"
      + security_rule       = [
          + {
              + access                                     = "Allow"
              + description                                = "Allow inbound connections to other VMs on the subnet"
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "*"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "AllowVnetInboundTraffic"
              + priority                                   = 200
              + protocol                                   = "*"
              + source_address_prefix                      = "*"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
          + {
              + access                                     = "Deny"
              + description                                = "Deny all Internet inbound traffic "
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "*"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "DenyInternetInboundTraffic"
              + priority                                   = 100
              + protocol                                   = "*"
              + source_address_prefix                      = "*"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
        ]
      + tags                = {
          + "create-by" = "giangh2"
        }
    }

  # azurerm_public_ip.main will be created
  + resource "azurerm_public_ip" "main" {
      + allocation_method       = "Static"
      + ddos_protection_mode    = "VirtualNetworkInherited"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "eastus"
      + name                    = "udacity-ip"
      + resource_group_name     = "Azuredevops"
      + sku                     = "Basic"
      + sku_tier                = "Regional"
      + tags                    = {
          + "create-by" = "giangh2"
        }
    }

  # azurerm_resource_group.main will be updated in-place
  ~ resource "azurerm_resource_group" "main" {
        id       = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops"
        name     = "Azuredevops"
      ~ tags     = {
          + "create-by" = "giangh2"
        }
        # (1 unchanged attribute hidden)
    }

  # azurerm_subnet.main will be created
  + resource "azurerm_subnet" "main" {
      + address_prefixes                               = [
          + "10.0.0.0/24",
        ]
      + enforce_private_link_endpoint_network_policies = (known after apply)
      + enforce_private_link_service_network_policies  = (known after apply)
      + id                                             = (known after apply)
      + name                                           = "udacity-subnet"
      + private_endpoint_network_policies_enabled      = (known after apply)
      + private_link_service_network_policies_enabled  = (known after apply)
      + resource_group_name                            = "Azuredevops"
      + virtual_network_name                           = "udacity-network"
    }

  # azurerm_virtual_machine_data_disk_attachment.main[0] will be created
  + resource "azurerm_virtual_machine_data_disk_attachment" "main" {
      + caching                   = "ReadWrite"
      + create_option             = "Attach"
      + id                        = (known after apply)
      + lun                       = 0
      + managed_disk_id           = (known after apply)
      + virtual_machine_id        = (known after apply)
      + write_accelerator_enabled = false
    }

  # azurerm_virtual_machine_data_disk_attachment.main[1] will be created
  + resource "azurerm_virtual_machine_data_disk_attachment" "main" {
      + caching                   = "ReadWrite"
      + create_option             = "Attach"
      + id                        = (known after apply)
      + lun                       = 0
      + managed_disk_id           = (known after apply)
      + virtual_machine_id        = (known after apply)
      + write_accelerator_enabled = false
    }

  # azurerm_virtual_network.main will be created
  + resource "azurerm_virtual_network" "main" {
      + address_space       = [
          + "10.0.0.0/24",
        ]
      + dns_servers         = (known after apply)
      + guid                = (known after apply)
      + id                  = (known after apply)
      + location            = "eastus"
      + name                = "udacity-network"
      + resource_group_name = "Azuredevops"
      + subnet              = (known after apply)
      + tags                = {
          + "create-by" = "giangh2"
        }
    }

Plan: 19 to add, 1 to change, 0 to destroy.

Saved the plan to: solution.plan

To perform exactly these actions, run the following command to apply:
    terraform apply "solution.plan"
```
5. Output after executing the terraform apply command

``` bash
PS C:\Users\hoang\Desktop\Azure DevOps\nd082-Azure-Cloud-DevOps-Starter-Code-master\C1 - Azure Infrastructure Operations\project\starter_files\terraform> terraform apply "solution.plan"
azurerm_resource_group.main: Modifying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops]
azurerm_resource_group.main: Modifications complete after 5s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops]
azurerm_public_ip.main: Creating...
azurerm_virtual_network.main: Creating...       
azurerm_managed_disk.main[0]: Creating...       
azurerm_availability_set.main: Creating...      
azurerm_managed_disk.main[1]: Creating...       
azurerm_network_security_group.main: Creating...
azurerm_public_ip.main: Creation complete after 7s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/publicIPAddresses/udacity-ip]
azurerm_lb.main: Creating...
azurerm_availability_set.main: Creation complete after 7s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/availabilitySets/udacity-aset]
azurerm_network_security_group.main: Creation complete after 8s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/udacity-nsg]
azurerm_managed_disk.main[0]: Creation complete after 9s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/disks/udacity-md-0]
azurerm_managed_disk.main[1]: Creation complete after 9s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/disks/udacity-md-1]
azurerm_virtual_network.main: Still creating... [10s elapsed]
azurerm_virtual_network.main: Creation complete after 10s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/udacity-network]
azurerm_subnet.main: Creating...
azurerm_lb.main: Creation complete after 5s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb]
azurerm_lb_backend_address_pool.main: Creating...
azurerm_lb_backend_address_pool.main: Creation complete after 8s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/backendAddressPools/udacity-bap]
azurerm_subnet.main: Still creating... [10s elapsed]
azurerm_subnet.main: Creation complete after 10s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/udacity-network/subnets/udacity-subnet]
azurerm_network_interface.main[1]: Creating...
azurerm_network_interface.main[0]: Creating...
azurerm_network_interface.main[1]: Still creating... [10s elapsed]
azurerm_network_interface.main[0]: Still creating... [10s elapsed]
azurerm_network_interface.main[1]: Creation complete after 17s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1]
azurerm_network_interface.main[0]: Still creating... [20s elapsed]
azurerm_network_interface.main[0]: Still creating... [30s elapsed]
azurerm_network_interface.main[0]: Creation complete after 33s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0]
azurerm_network_interface_backend_address_pool_association.main[1]: Creating...
azurerm_network_interface_backend_address_pool_association.main[0]: Creating...
azurerm_network_interface_security_group_association.main[1]: Creating...
azurerm_network_interface_security_group_association.main[0]: Creating...
azurerm_linux_virtual_machine.main[0]: Creating...
azurerm_linux_virtual_machine.main[1]: Creating...
azurerm_network_interface_backend_address_pool_association.main[0]: Creation complete after 10s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0/ipConfigurations/udacity-ipconfig|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/backendAddressPools/udacity-bap]
azurerm_network_interface_security_group_association.main[1]: Creation complete after 10s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/udacity-nsg]
azurerm_network_interface_backend_address_pool_association.main[1]: Still creating... [10s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [10s elapsed]
azurerm_network_interface_security_group_association.main[0]: Still creating... [10s elapsed]
azurerm_network_interface_security_group_association.main[0]: Creation complete after 19s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/udacity-nsg]
azurerm_network_interface_backend_address_pool_association.main[1]: Still creating... [20s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [20s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [20s elapsed]
azurerm_network_interface_backend_address_pool_association.main[1]: Still creating... [30s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [30s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [30s elapsed]
azurerm_network_interface_backend_address_pool_association.main[1]: Creation complete after 34s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1/ipConfigurations/udacity-ipconfig|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/backendAddressPools/udacity-bap]
azurerm_linux_virtual_machine.main[1]: Still creating... [40s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [40s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [50s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [50s elapsed]
azurerm_linux_virtual_machine.main[0]: Creation complete after 56s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-0]
azurerm_linux_virtual_machine.main[1]: Creation complete after 56s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-1]
azurerm_virtual_machine_data_disk_attachment.main[0]: Creating...
azurerm_virtual_machine_data_disk_attachment.main[1]: Creating...
azurerm_virtual_machine_data_disk_attachment.main[1]: Still creating... [10s elapsed]
azurerm_virtual_machine_data_disk_attachment.main[0]: Still creating... [10s elapsed]
azurerm_virtual_machine_data_disk_attachment.main[0]: Still creating... [20s elapsed]
azurerm_virtual_machine_data_disk_attachment.main[1]: Still creating... [20s elapsed]
azurerm_virtual_machine_data_disk_attachment.main[1]: Still creating... [30s elapsed]
azurerm_virtual_machine_data_disk_attachment.main[0]: Still creating... [30s elapsed]
azurerm_virtual_machine_data_disk_attachment.main[0]: Creation complete after 37s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-0/dataDisks/udacity-md-0]
azurerm_virtual_machine_data_disk_attachment.main[1]: Creation complete after 37s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-1/dataDisks/udacity-md-1]

Apply complete! Resources: 19 added, 1 changed, 0 destroyed.
```

6. Output after executing the terraform destroy command

``` bash
PS C:\Users\hoang\Desktop\Azure DevOps\nd082-Azure-Cloud-DevOps-Starter-Code-master\C1 - Azure Infrastructure Operations\project\starter_files\terraform> terraform destroy
data.azurerm_image.packer-image: Reading...
azurerm_resource_group.main: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops]
azurerm_virtual_network.main: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/udacity-network]
azurerm_public_ip.main: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/publicIPAddresses/udacity-ip]
azurerm_managed_disk.main[0]: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/disks/udacity-md-0]
azurerm_availability_set.main: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/availabilitySets/udacity-aset]
azurerm_network_security_group.main: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/udacity-nsg]
azurerm_managed_disk.main[1]: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/disks/udacity-md-1]
data.azurerm_image.packer-image: Read complete after 1s [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/packer-image]
azurerm_subnet.main: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/udacity-network/subnets/udacity-subnet]
azurerm_lb.main: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb]
azurerm_lb_backend_address_pool.main: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/backendAddressPools/udacity-bap]
azurerm_network_interface.main[0]: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0]
azurerm_network_interface.main[1]: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1]
azurerm_network_interface_security_group_association.main[1]: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/udacity-nsg]
azurerm_network_interface_backend_address_pool_association.main[1]: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1/ipConfigurations/udacity-ipconfig|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/backendAddressPools/udacity-bap]
azurerm_network_interface_security_group_association.main[0]: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/udacity-nsg]
azurerm_network_interface_backend_address_pool_association.main[0]: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0/ipConfigurations/udacity-ipconfig|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/backendAddressPools/udacity-bap]
azurerm_linux_virtual_machine.main[0]: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-0]
azurerm_linux_virtual_machine.main[1]: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-1]
azurerm_virtual_machine_data_disk_attachment.main[1]: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-1/dataDisks/udacity-md-1]
azurerm_virtual_machine_data_disk_attachment.main[0]: Refreshing state... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-0/dataDisks/udacity-md-0]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # azurerm_availability_set.main will be destroyed
  - resource "azurerm_availability_set" "main" {
      - id                           = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/availabilitySets/udacity-aset" -> null
      - location                     = "eastus" -> null
      - managed                      = true -> null
      - name                         = "udacity-aset" -> null
      - platform_fault_domain_count  = 2 -> null
      - platform_update_domain_count = 5 -> null
      - resource_group_name          = "Azuredevops" -> null
      - tags                         = {
          - "create-by" = "giangh2"
        } -> null
    }

  # azurerm_lb.main will be destroyed
  - resource "azurerm_lb" "main" {
      - id                   = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb" -> null
      - location             = "eastus" -> null
      - name                 = "udacity-lb" -> null
      - private_ip_addresses = [] -> null
      - resource_group_name  = "Azuredevops" -> null
      - sku                  = "Basic" -> null
      - sku_tier             = "Regional" -> null
      - tags                 = {
          - "create-by" = "giangh2"
        } -> null

      - frontend_ip_configuration {
          - id                            = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/frontendIPConfigurations/udacity-frontendip" -> null
          - inbound_nat_rules             = [] -> null
          - load_balancer_rules           = [] -> null
          - name                          = "udacity-frontendip" -> null
          - outbound_rules                = [] -> null
          - private_ip_address_allocation = "Dynamic" -> null
          - public_ip_address_id          = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/publicIPAddresses/udacity-ip" -> null
          - zones                         = [] -> null
        }
    }

  # azurerm_lb_backend_address_pool.main will be destroyed
  - resource "azurerm_lb_backend_address_pool" "main" {
      - backend_ip_configurations = [
          - "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0/ipConfigurations/udacity-ipconfig",
          - "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1/ipConfigurations/udacity-ipconfig",
        ] -> null
      - id                        = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/backendAddressPools/udacity-bap" -> null   
      - inbound_nat_rules         = [] -> null
      - load_balancing_rules      = [] -> null
      - loadbalancer_id           = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb" -> null
      - name                      = "udacity-bap" -> null
      - outbound_rules            = [] -> null
    }

  # azurerm_linux_virtual_machine.main[0] will be destroyed
  - resource "azurerm_linux_virtual_machine" "main" {
      - admin_password                                         = (sensitive value) -> null
      - admin_username                                         = "udacityuser" -> null
      - allow_extension_operations                             = true -> null
      - availability_set_id                                    = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/availabilitySets/UDACITY-ASET" -> null 
      - bypass_platform_safety_checks_on_user_schedule_enabled = false -> null
      - computer_name                                          = "udacity-vm-0" -> null
      - disable_password_authentication                        = false -> null
      - encryption_at_host_enabled                             = false -> null
      - extensions_time_budget                                 = "PT1H30M" -> null
      - id                                                     = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-0" -> null  
      - location                                               = "eastus" -> null
      - max_bid_price                                          = -1 -> null
      - name                                                   = "udacity-vm-0" -> null
      - network_interface_ids                                  = [
          - "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0",
        ] -> null
      - patch_assessment_mode                                  = "ImageDefault" -> null
      - patch_mode                                             = "ImageDefault" -> null
      - platform_fault_domain                                  = -1 -> null
      - priority                                               = "Regular" -> null
      - private_ip_address                                     = "10.0.0.5" -> null
      - private_ip_addresses                                   = [
          - "10.0.0.5",
        ] -> null
      - provision_vm_agent                                     = true -> null
      - public_ip_addresses                                    = [] -> null
      - resource_group_name                                    = "Azuredevops" -> null
      - secure_boot_enabled                                    = false -> null
      - size                                                   = "Standard_D2s_v3" -> null
      - source_image_id                                        = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/packer-image" -> null
      - tags                                                   = {
          - "create-by" = "giangh2"
        } -> null
      - virtual_machine_id                                     = "f18f6ce8-57d6-4c04-aa1b-8cdad0d69119" -> null
      - vtpm_enabled                                           = false -> null

      - os_disk {
          - caching                   = "ReadWrite" -> null
          - disk_size_gb              = 30 -> null
          - name                      = "udacity-osdisk-0" -> null
          - storage_account_type      = "Standard_LRS" -> null
          - write_accelerator_enabled = false -> null
        }
    }

  # azurerm_linux_virtual_machine.main[1] will be destroyed
  - resource "azurerm_linux_virtual_machine" "main" {
      - admin_password                                         = (sensitive value) -> null
      - admin_username                                         = "udacityuser" -> null
      - allow_extension_operations                             = true -> null
      - availability_set_id                                    = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/availabilitySets/UDACITY-ASET" -> null 
      - bypass_platform_safety_checks_on_user_schedule_enabled = false -> null
      - computer_name                                          = "udacity-vm-1" -> null
      - disable_password_authentication                        = false -> null
      - encryption_at_host_enabled                             = false -> null
      - extensions_time_budget                                 = "PT1H30M" -> null
      - id                                                     = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-1" -> null  
      - location                                               = "eastus" -> null
      - max_bid_price                                          = -1 -> null
      - name                                                   = "udacity-vm-1" -> null
      - network_interface_ids                                  = [
          - "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1",
        ] -> null
      - patch_assessment_mode                                  = "ImageDefault" -> null
      - patch_mode                                             = "ImageDefault" -> null
      - platform_fault_domain                                  = -1 -> null
      - priority                                               = "Regular" -> null
      - private_ip_address                                     = "10.0.0.4" -> null
      - private_ip_addresses                                   = [
          - "10.0.0.4",
        ] -> null
      - provision_vm_agent                                     = true -> null
      - public_ip_addresses                                    = [] -> null
      - resource_group_name                                    = "Azuredevops" -> null
      - secure_boot_enabled                                    = false -> null
      - size                                                   = "Standard_D2s_v3" -> null
      - source_image_id                                        = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/packer-image" -> null
      - tags                                                   = {
          - "create-by" = "giangh2"
        } -> null
      - virtual_machine_id                                     = "57da278f-8171-47eb-b949-fce19c5e4bfc" -> null
      - vtpm_enabled                                           = false -> null

      - os_disk {
          - caching                   = "ReadWrite" -> null
          - disk_size_gb              = 30 -> null
          - name                      = "udacity-osdisk-1" -> null
          - storage_account_type      = "Standard_LRS" -> null
          - write_accelerator_enabled = false -> null
        }
    }

  # azurerm_managed_disk.main[0] will be destroyed
  - resource "azurerm_managed_disk" "main" {
      - create_option                     = "Empty" -> null
      - disk_iops_read_only               = 0 -> null
      - disk_iops_read_write              = 500 -> null
      - disk_mbps_read_only               = 0 -> null
      - disk_mbps_read_write              = 60 -> null
      - disk_size_gb                      = 1 -> null
      - id                                = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/disks/udacity-md-0" -> null
      - location                          = "eastus" -> null
      - max_shares                        = 0 -> null
      - name                              = "udacity-md-0" -> null
      - on_demand_bursting_enabled        = false -> null
      - optimized_frequent_attach_enabled = false -> null
      - performance_plus_enabled          = false -> null
      - public_network_access_enabled     = true -> null
      - resource_group_name               = "Azuredevops" -> null
      - storage_account_type              = "Standard_LRS" -> null
      - tags                              = {
          - "create-by" = "giangh2"
        } -> null
      - trusted_launch_enabled            = false -> null
      - upload_size_bytes                 = 0 -> null
    }

  # azurerm_managed_disk.main[1] will be destroyed
  - resource "azurerm_managed_disk" "main" {
      - create_option                     = "Empty" -> null
      - disk_iops_read_only               = 0 -> null
      - disk_iops_read_write              = 500 -> null
      - disk_mbps_read_only               = 0 -> null
      - disk_mbps_read_write              = 60 -> null
      - disk_size_gb                      = 1 -> null
      - id                                = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/disks/udacity-md-1" -> null
      - location                          = "eastus" -> null
      - max_shares                        = 0 -> null
      - name                              = "udacity-md-1" -> null
      - on_demand_bursting_enabled        = false -> null
      - optimized_frequent_attach_enabled = false -> null
      - performance_plus_enabled          = false -> null
      - public_network_access_enabled     = true -> null
      - resource_group_name               = "Azuredevops" -> null
      - storage_account_type              = "Standard_LRS" -> null
      - tags                              = {
          - "create-by" = "giangh2"
        } -> null
      - trusted_launch_enabled            = false -> null
      - upload_size_bytes                 = 0 -> null
    }

  # azurerm_network_interface.main[0] will be destroyed
  - resource "azurerm_network_interface" "main" {
      - applied_dns_servers           = [] -> null
      - dns_servers                   = [] -> null
      - enable_accelerated_networking = false -> null
      - enable_ip_forwarding          = false -> null
      - id                            = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0" -> null
      - internal_domain_name_suffix   = "jz4fd3z2xfuuzkf1gn4ms0kpud.bx.internal.cloudapp.net" -> null
      - location                      = "eastus" -> null
      - mac_address                   = "00-0D-3A-52-C7-89" -> null
      - name                          = "udacity-nic-0" -> null
      - private_ip_address            = "10.0.0.5" -> null
      - private_ip_addresses          = [
          - "10.0.0.5",
        ] -> null
      - resource_group_name           = "Azuredevops" -> null
      - tags                          = {
          - "create-by" = "giangh2"
        } -> null
      - virtual_machine_id            = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-0" -> null

      - ip_configuration {
          - name                          = "udacity-ipconfig" -> null
          - primary                       = true -> null
          - private_ip_address            = "10.0.0.5" -> null
          - private_ip_address_allocation = "Dynamic" -> null
          - private_ip_address_version    = "IPv4" -> null
          - subnet_id                     = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/udacity-network/subnets/udacity-subnet" -> null
        }
    }

  # azurerm_network_interface.main[1] will be destroyed
  - resource "azurerm_network_interface" "main" {
      - applied_dns_servers           = [] -> null
      - dns_servers                   = [] -> null
      - enable_accelerated_networking = false -> null
      - enable_ip_forwarding          = false -> null
      - id                            = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1" -> null
      - internal_domain_name_suffix   = "jz4fd3z2xfuuzkf1gn4ms0kpud.bx.internal.cloudapp.net" -> null
      - location                      = "eastus" -> null
      - mac_address                   = "00-0D-3A-52-C9-83" -> null
      - name                          = "udacity-nic-1" -> null
      - private_ip_address            = "10.0.0.4" -> null
      - private_ip_addresses          = [
          - "10.0.0.4",
        ] -> null
      - resource_group_name           = "Azuredevops" -> null
      - tags                          = {
          - "create-by" = "giangh2"
        } -> null
      - virtual_machine_id            = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-1" -> null

      - ip_configuration {
          - name                          = "udacity-ipconfig" -> null
          - primary                       = true -> null
          - private_ip_address            = "10.0.0.4" -> null
          - private_ip_address_allocation = "Dynamic" -> null
          - private_ip_address_version    = "IPv4" -> null
          - subnet_id                     = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/udacity-network/subnets/udacity-subnet" -> null
        }
    }

  # azurerm_network_interface_backend_address_pool_association.main[0] will be destroyed
  - resource "azurerm_network_interface_backend_address_pool_association" "main" {
      - backend_address_pool_id = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/backendAddressPools/udacity-bap" -> null     
      - id                      = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0/ipConfigurations/udacity-ipconfig|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/backendAddressPools/udacity-bap" -> null
      - ip_configuration_name   = "udacity-ipconfig" -> null
      - network_interface_id    = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0" -> null
    }

  # azurerm_network_interface_backend_address_pool_association.main[1] will be destroyed
  - resource "azurerm_network_interface_backend_address_pool_association" "main" {
      - backend_address_pool_id = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/backendAddressPools/udacity-bap" -> null     
      - id                      = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1/ipConfigurations/udacity-ipconfig|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/backendAddressPools/udacity-bap" -> null
      - ip_configuration_name   = "udacity-ipconfig" -> null
      - network_interface_id    = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1" -> null
    }

  # azurerm_network_interface_security_group_association.main[0] will be destroyed
  - resource "azurerm_network_interface_security_group_association" "main" {
      - id                        = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/udacity-nsg" -> null
      - network_interface_id      = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0" -> null
      - network_security_group_id = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/udacity-nsg" -> null
    }

  # azurerm_network_interface_security_group_association.main[1] will be destroyed
  - resource "azurerm_network_interface_security_group_association" "main" {
      - id                        = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/udacity-nsg" -> null
      - network_interface_id      = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1" -> null
      - network_security_group_id = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/udacity-nsg" -> null
    }

  # azurerm_network_security_group.main will be destroyed
  - resource "azurerm_network_security_group" "main" {
      - id                  = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/udacity-nsg" -> null
      - location            = "eastus" -> null
      - name                = "udacity-nsg" -> null
      - resource_group_name = "Azuredevops" -> null
      - security_rule       = [
          - {
              - access                                     = "Allow"
              - description                                = "Allow inbound connections to other VMs on the subnet"
              - destination_address_prefix                 = "*"
              - destination_address_prefixes               = []
              - destination_application_security_group_ids = []
              - destination_port_range                     = "*"
              - destination_port_ranges                    = []
              - direction                                  = "Inbound"
              - name                                       = "AllowVnetInboundTraffic"
              - priority                                   = 200
              - protocol                                   = "*"
              - source_address_prefix                      = "*"
              - source_address_prefixes                    = []
              - source_application_security_group_ids      = []
              - source_port_range                          = "*"
              - source_port_ranges                         = []
            },
          - {
              - access                                     = "Deny"
              - description                                = "Deny all Internet inbound traffic "
              - destination_address_prefix                 = "*"
              - destination_address_prefixes               = []
              - destination_application_security_group_ids = []
              - destination_port_range                     = "*"
              - destination_port_ranges                    = []
              - direction                                  = "Inbound"
              - name                                       = "DenyInternetInboundTraffic"
              - priority                                   = 100
              - protocol                                   = "*"
              - source_address_prefix                      = "*"
              - source_address_prefixes                    = []
              - source_application_security_group_ids      = []
              - source_port_range                          = "*"
              - source_port_ranges                         = []
            },
        ] -> null
      - tags                = {
          - "create-by" = "giangh2"
        } -> null
    }

  # azurerm_public_ip.main will be destroyed
  - resource "azurerm_public_ip" "main" {
      - allocation_method       = "Static" -> null
      - ddos_protection_mode    = "VirtualNetworkInherited" -> null
      - id                      = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/publicIPAddresses/udacity-ip" -> null
      - idle_timeout_in_minutes = 4 -> null
      - ip_address              = "20.231.60.197" -> null
      - ip_tags                 = {} -> null
      - ip_version              = "IPv4" -> null
      - location                = "eastus" -> null
      - name                    = "udacity-ip" -> null
      - resource_group_name     = "Azuredevops" -> null
      - sku                     = "Basic" -> null
      - sku_tier                = "Regional" -> null
      - tags                    = {
          - "create-by" = "giangh2"
        } -> null
      - zones                   = [] -> null
    }

  # azurerm_resource_group.main will be destroyed
  - resource "azurerm_resource_group" "main" {
      - id       = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops" -> null
      - location = "eastus" -> null
      - name     = "Azuredevops" -> null
      - tags     = {
          - "create-by" = "giangh2"
        } -> null
    }

  # azurerm_subnet.main will be destroyed
  - resource "azurerm_subnet" "main" {
      - address_prefixes                               = [
          - "10.0.0.0/24",
        ] -> null
      - enforce_private_link_endpoint_network_policies = false -> null
      - enforce_private_link_service_network_policies  = false -> null
      - id                                             = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/udacity-network/subnets/udacity-subnet" -> null
      - name                                           = "udacity-subnet" -> null
      - private_endpoint_network_policies_enabled      = true -> null
      - private_link_service_network_policies_enabled  = true -> null
      - resource_group_name                            = "Azuredevops" -> null
      - service_endpoint_policy_ids                    = [] -> null
      - service_endpoints                              = [] -> null
      - virtual_network_name                           = "udacity-network" -> null
    }

  # azurerm_virtual_machine_data_disk_attachment.main[0] will be destroyed
  - resource "azurerm_virtual_machine_data_disk_attachment" "main" {
      - caching                   = "ReadWrite" -> null
      - create_option             = "Attach" -> null
      - id                        = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-0/dataDisks/udacity-md-0" -> null        
      - lun                       = 0 -> null
      - managed_disk_id           = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/disks/udacity-md-0" -> null
      - virtual_machine_id        = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-0" -> null
      - write_accelerator_enabled = false -> null
    }

  # azurerm_virtual_machine_data_disk_attachment.main[1] will be destroyed
  - resource "azurerm_virtual_machine_data_disk_attachment" "main" {
      - caching                   = "ReadWrite" -> null
      - create_option             = "Attach" -> null
      - id                        = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-1/dataDisks/udacity-md-1" -> null        
      - lun                       = 0 -> null
      - managed_disk_id           = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/disks/udacity-md-1" -> null
      - virtual_machine_id        = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-1" -> null
      - write_accelerator_enabled = false -> null
    }

  # azurerm_virtual_network.main will be destroyed
  - resource "azurerm_virtual_network" "main" {
      - address_space           = [
          - "10.0.0.0/24",
        ] -> null
      - dns_servers             = [] -> null
      - flow_timeout_in_minutes = 0 -> null
      - guid                    = "f7517c4e-b93c-4c69-a8bb-337cc9694fa3" -> null
      - id                      = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/udacity-network" -> null
      - location                = "eastus" -> null
      - name                    = "udacity-network" -> null
      - resource_group_name     = "Azuredevops" -> null
      - subnet                  = [
          - {
              - address_prefix = "10.0.0.0/24"
              - id             = "/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/udacity-network/subnets/udacity-subnet"
              - name           = "udacity-subnet"
              - security_group = ""
            },
        ] -> null
      - tags                    = {
          - "create-by" = "giangh2"
        } -> null
    }

Plan: 0 to add, 0 to change, 20 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

azurerm_virtual_machine_data_disk_attachment.main[1]: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-1/dataDisks/udacity-md-1]
azurerm_network_interface_security_group_association.main[1]: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/udacity-nsg]
azurerm_network_interface_security_group_association.main[0]: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/udacity-nsg]
azurerm_virtual_machine_data_disk_attachment.main[0]: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-0/dataDisks/udacity-md-0]
azurerm_network_interface_backend_address_pool_association.main[1]: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1/ipConfigurations/udacity-ipconfig|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/backendAddressPools/udacity-bap] 
azurerm_network_interface_backend_address_pool_association.main[0]: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0/ipConfigurations/udacity-ipconfig|/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/backendAddressPools/udacity-bap] 
azurerm_network_interface_backend_address_pool_association.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...ity-lb/backendAddressPools/udacity-bap, 10s elapsed]
azurerm_virtual_machine_data_disk_attachment.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...es/udacity-vm-1/dataDisks/udacity-md-1, 10s elapsed]
azurerm_network_interface_security_group_association.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...work/networkSecurityGroups/udacity-nsg, 10s elapsed]
azurerm_network_interface_security_group_association.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...work/networkSecurityGroups/udacity-nsg, 10s elapsed]
azurerm_network_interface_backend_address_pool_association.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...ity-lb/backendAddressPools/udacity-bap, 10s elapsed]
azurerm_virtual_machine_data_disk_attachment.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...es/udacity-vm-0/dataDisks/udacity-md-0, 10s elapsed]
azurerm_network_interface_security_group_association.main[0]: Destruction complete after 10s
azurerm_network_interface_security_group_association.main[1]: Destruction complete after 10s
azurerm_network_security_group.main: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/udacity-nsg]
azurerm_network_security_group.main: Destruction complete after 4s
azurerm_virtual_machine_data_disk_attachment.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...es/udacity-vm-1/dataDisks/udacity-md-1, 20s elapsed]
azurerm_virtual_machine_data_disk_attachment.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...es/udacity-vm-0/dataDisks/udacity-md-0, 20s elapsed]
azurerm_network_interface_backend_address_pool_association.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...ity-lb/backendAddressPools/udacity-bap, 20s elapsed]
azurerm_network_interface_backend_address_pool_association.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...ity-lb/backendAddressPools/udacity-bap, 20s elapsed]
azurerm_network_interface_backend_address_pool_association.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...ity-lb/backendAddressPools/udacity-bap, 30s elapsed]
azurerm_virtual_machine_data_disk_attachment.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...es/udacity-vm-0/dataDisks/udacity-md-0, 30s elapsed]
azurerm_virtual_machine_data_disk_attachment.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...es/udacity-vm-1/dataDisks/udacity-md-1, 30s elapsed]
azurerm_network_interface_backend_address_pool_association.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...ity-lb/backendAddressPools/udacity-bap, 30s elapsed]
azurerm_network_interface_backend_address_pool_association.main[0]: Destruction complete after 33s
azurerm_virtual_machine_data_disk_attachment.main[1]: Destruction complete after 34s
azurerm_virtual_machine_data_disk_attachment.main[0]: Destruction complete after 35s
azurerm_managed_disk.main[1]: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/disks/udacity-md-1]
azurerm_managed_disk.main[0]: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/disks/udacity-md-0]
azurerm_linux_virtual_machine.main[1]: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-1]
azurerm_linux_virtual_machine.main[0]: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/udacity-vm-0]
azurerm_network_interface_backend_address_pool_association.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...ity-lb/backendAddressPools/udacity-bap, 40s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-1, 10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-0, 10s elapsed]
azurerm_managed_disk.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...s/Microsoft.Compute/disks/udacity-md-0, 10s elapsed]
azurerm_managed_disk.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...s/Microsoft.Compute/disks/udacity-md-1, 10s elapsed]
azurerm_managed_disk.main[1]: Destruction complete after 13s
azurerm_managed_disk.main[0]: Destruction complete after 13s
azurerm_network_interface_backend_address_pool_association.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...ity-lb/backendAddressPools/udacity-bap, 50s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-0, 20s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-1, 20s elapsed]
azurerm_network_interface_backend_address_pool_association.main[1]: Destruction complete after 59s
azurerm_lb_backend_address_pool.main: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb/backendAddressPools/udacity-bap]
azurerm_lb_backend_address_pool.main: Destruction complete after 5s
azurerm_lb.main: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/udacity-lb]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-1, 30s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-0, 30s elapsed]
azurerm_lb.main: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...osoft.Network/loadBalancers/udacity-lb, 10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-0, 40s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-1, 40s elapsed]
azurerm_lb.main: Destruction complete after 12s
azurerm_public_ip.main: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/publicIPAddresses/udacity-ip]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-1, 50s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-0, 50s elapsed]
azurerm_public_ip.main: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Network/publicIPAddresses/udacity-ip, 10s elapsed]
azurerm_public_ip.main: Destruction complete after 12s
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-0, 1m0s elapsed]
azurerm_linux_virtual_machine.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-1, 1m0s elapsed]
azurerm_linux_virtual_machine.main[1]: Destruction complete after 1m5s
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-0, 1m10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-0, 1m20s elapsed]
azurerm_linux_virtual_machine.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...t.Compute/virtualMachines/udacity-vm-0, 1m30s elapsed]
azurerm_linux_virtual_machine.main[0]: Destruction complete after 1m37s
azurerm_availability_set.main: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Compute/availabilitySets/udacity-aset]
azurerm_network_interface.main[1]: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-1]
azurerm_network_interface.main[0]: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/udacity-nic-0]
azurerm_availability_set.main: Destruction complete after 7s
azurerm_network_interface.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...etwork/networkInterfaces/udacity-nic-1, 10s elapsed]
azurerm_network_interface.main[0]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...etwork/networkInterfaces/udacity-nic-0, 10s elapsed]
azurerm_network_interface.main[0]: Destruction complete after 13s
azurerm_network_interface.main[1]: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...etwork/networkInterfaces/udacity-nic-1, 20s elapsed]
azurerm_network_interface.main[1]: Destruction complete after 27s
azurerm_subnet.main: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/udacity-network/subnets/udacity-subnet]
azurerm_subnet.main: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...udacity-network/subnets/udacity-subnet, 10s elapsed]
azurerm_subnet.main: Destruction complete after 13s
azurerm_virtual_network.main: Destroying... [id=/subscriptions/935af078-1669-488b-ae1c-5792c0fdb75d/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/udacity-network]
azurerm_virtual_network.main: Still destroying... [id=/subscriptions/935af078-1669-488b-ae1c-...etwork/virtualNetworks/udacity-network, 10s elapsed]
azurerm_virtual_network.main: Destruction complete after 14s
```

## References
- [What is Infrastructure as Code?](https://docs.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code)
- [Azure](https://portal.azure.com)
- [Azure Command Line Interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [Packer](https://www.packer.io/downloads)
- [Terraform](https://www.terraform.io/downloads.html)
- [How to use Packer to create Linux virtual machine images in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer)
- [Terraform Azure Documentation](https://learn.hashicorp.com/collections/terraform/azure-get-started)