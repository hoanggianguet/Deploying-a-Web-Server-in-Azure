provider "azurerm" {
  features {}
}

data "azurerm_image" "packer-image" {
  name                = var.packer_image_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "main" {
    name                = "${var.prefix}-network"
    address_space       = ["10.0.0.0/24"]
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    tags                = var.tags

}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags                = var.tags

  security_rule {
    name                       = "DenyInternetInboundTraffic"
    description                = "Deny all Internet inbound traffic "
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "AllowVnetInboundTraffic"
    description                = "Allow inbound connections to other VMs on the subnet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface" "main" {
    count               = var.vm_num
    name                = "${var.prefix}-nic-${count.index}"
    resource_group_name = azurerm_resource_group.main.name
    location            = azurerm_resource_group.main.location
    tags                = var.tags
    ip_configuration {
        name                          = "${var.prefix}-ipconfig"
        subnet_id                     = azurerm_subnet.main.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_public_ip" "main" {
    name                = "${var.prefix}-ip"
    resource_group_name = azurerm_resource_group.main.name
    location            = azurerm_resource_group.main.location
    allocation_method   = "Static"
     tags                = var.tags
}

resource "azurerm_lb" "main" {
    name                = "${var.prefix}-lb"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    tags                = var.tags

    frontend_ip_configuration {
        name                 = "${var.prefix}-frontendip"
        public_ip_address_id = azurerm_public_ip.main.id
    }

}

resource "azurerm_lb_backend_address_pool" "main" {
    name                = "${var.prefix}-bap"
    resource_group_name = azurerm_resource_group.main.name
    loadbalancer_id     = azurerm_lb.main.id
}

resource "azurerm_availability_set" "main" {
    name                        = "${var.prefix}-aset"
    location                    = azurerm_resource_group.main.location
    resource_group_name         = azurerm_resource_group.main.name
    platform_fault_domain_count = 2
    tags     = var.tags
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vm_num
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids           = ["${element(azurerm_network_interface.main.*.id, count.index)}"]
  availability_set_id             = azurerm_availability_set.main.id
  source_image_id = data.azurerm_image.packer-image.id
  tags     = var.tags

  os_disk {
    name                 = "${var.prefix}-osdisk-${count.index}"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }



}

resource "azurerm_managed_disk" "main" {
  count                = var.vm_num
  name                 = "${var.prefix}-md-${count.index}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
  tags     = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  count              = var.vm_num
  managed_disk_id    = element(azurerm_managed_disk.main.*.id, count.index)
  virtual_machine_id = element(azurerm_linux_virtual_machine.main.*.id, count.index)
  lun                = "0"
  caching            = "ReadWrite"
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.vm_num
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
  ip_configuration_name   = "${var.prefix}-ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

resource "azurerm_network_interface_security_group_association" "main" {
  count                     = var.vm_num
  network_interface_id      = element(azurerm_network_interface.main.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.main.id
}