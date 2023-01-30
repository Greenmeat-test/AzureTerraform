# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  #required_version = ">= 1.1.0"
  backend "azurerm" {
    resource_group_name  = "tfstateRG01"
    storage_account_name = "tfstate0115567"
    container_name       = "tfstate1"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}