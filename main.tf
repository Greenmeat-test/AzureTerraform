
resource "azurerm_resource_group" "this" {
  name     = "${var.resource_group_name}-${var.environment}"
  location = var.location
    
    tags        = {
    Environment = "${var.environment}"
  }
}

# Create a virtual network

resource "azurerm_virtual_network" "this" {
  name                = "${var.azurerm_virtual_network}-${var.environment}"
  address_space       = var.virtual_network_prefixes
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

# Create a subnets

resource "azurerm_subnet" "this" {
  count = length(var.subnet_names)

  name = "${var.subnet_names[count.index]}-${var.environment}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes = [var.subnet_prefixes[count.index]]
}

# Create a Public IP

resource "azurerm_public_ip" "this" {
  name                = "PIP-${var.environment}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"

  tags = {
    environment = "${var.environment}"
  }
}

#Create a NICs

resource "azurerm_network_interface" "this" {
  count               = length(var.subnet_names)

  name                = "nic-${var.subnet_names[count.index]}-${var.environment}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal${count.index}"
    subnet_id                     = "${azurerm_subnet.this[count.index].id}"
    private_ip_address_allocation = "Dynamic"
    
    public_ip_address_id          = count.index == 1? azurerm_public_ip.this.id : null
  }
}

#Association NSG with public NIC

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id = azurerm_network_interface.this.1.id
  network_security_group_id = azurerm_network_security_group.this.id
}

#Create a network security group

resource "azurerm_network_security_group" "this" {
  name                = "NSG-${var.environment}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = security_rule.value["name"]
      priority                   = security_rule.value["priority"]
      direction                  = security_rule.value["direction"]
      access                     = security_rule.value["access"]
      protocol                   = security_rule.value["protocol"]
      source_port_range          = security_rule.value["source_port_range"]
      destination_port_range     = security_rule.value["destination_port_range"]
      source_address_prefix      = security_rule.value["source_address_prefix"]
      destination_address_prefix = security_rule.value["destination_address_prefix"]
    }
  }
  
  tags          = {
    Environment = "${var.environment}"
  }
}

#Create a VMs

resource "azurerm_linux_virtual_machine" "linuxvm" {
  count               = 2
  
  name                = "vm-${count.index}-${var.environment}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.this[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
