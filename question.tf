# variable "subnets" {
#   description = "A list of subnets inside the vNet."
#   type        = map(any)
#   default = {
#     private = {
#       name             = "private"
#       address_prefixes = ["10.0.1.0/24"]  
#     }
#     public = {
#       name             = "public"
#       address_prefixes = ["10.0.2.0/24"] 
#     }
#   }
# }

# # Create a subnets
# resource "azurerm_subnet" "this" {
#   for_each = var.subnets

#   name                 = each.value["name"]
#   resource_group_name  = azurerm_resource_group.this.name
#   virtual_network_name = azurerm_virtual_network.this.name
#   address_prefixes     = each.value["address_prefixes"]
# }

# output "azure_subnet_id" {
#     value = {
#         for id in keys(var.subnets) : id => azurerm_subnet.this[id].id
#     }
#     description = "Lists the ID's of the subnets"
# }

# #Create a NICs
# resource "azurerm_network_interface" "this" {
#   for_each            = azurerm_subnet.this

#   name                = "nic-${each.value.name}-${var.environment}"
#   location            = azurerm_resource_group.this.location
#   resource_group_name = azurerm_resource_group.this.name

#   ip_configuration {
#     name                          = "${each.value.name}"
#     subnet_id                     = each.value.id #how to get id
#     private_ip_address_allocation = "Dynamic"
    
#     public_ip_address_id          = each.value.name == "public"? azurerm_public_ip.this.id : null
#   }
# }


# #Association NSG with public NIC
# resource "azurerm_network_interface_security_group_association" "this" {
#   network_interface_id = azurerm_network_interface.this["public"].id
#   network_security_group_id = azurerm_network_security_group.this.id
# }

# #Create a VMs
# resource "azurerm_linux_virtual_machine" "linuxvm" {
#   for_each            = azurerm_network_interface.this
  
#   name                = "vm-${each.value.name}-${var.environment}"
#   resource_group_name = azurerm_resource_group.this.name
#   location            = azurerm_resource_group.this.location
#   size                = "Standard_F2"
#   admin_username      = "adminuser"
#   network_interface_ids = [
#     azurerm_network_interface.this[each.key].id,
#   ]

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "16.04-LTS"
#     version   = "latest"
#   }
# }
