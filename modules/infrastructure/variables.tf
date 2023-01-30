variable "environment" {
  type = string
  description = "Name of enviroment"
}

variable "resource_group_name" {
  type    = string
  description = "The name of the rsourse group"
  default = "FinalTaskTFResourceGroup"
}

variable "location" {
  type        = string
  description = "The region for the deployment"
  default     = "westus2"
}

variable "azurerm_virtual_network" {
  default = "myTFVnet" 
}

variable "virtual_network_prefixes" {
  default = ["10.0.0.0/16"]
}

variable "subnet_names" {
  description = "A list of subnets inside the vNet."
  type        = list(string)
  default     = ["private", "public"]
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "nsg_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  description = "The values for each NSG rule "
} 
