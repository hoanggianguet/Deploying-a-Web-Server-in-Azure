variable "prefix" {
  description = "The prefix which should be used for all resources in this example."
  default = "udacity"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which the resources will be created"
  default     = "Azuredevops"
}

variable "packer_image_name" {
  type        = string
  description = "Name of the Packer image"
  default     = "packer-image"
}


variable "environment" {
  description = "The environment which should be used for all resources in this example."
  default = "dev"
}

variable "vm_num"{
  description = "The number of virtual machines to be deployed in this example."
  default = "2"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "East US"
}

variable "username" {
  description = "username for the virtual machine."
  default = "udacityuser"
}

variable "password" {
  description = "password for the virtual machine."
  default = "Udacity1Pass2@"
}

variable "image"{
  description = "The Packer Image location in Azure"
  default = "packer-image"
}

variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    create-by = "giangh2"
  }
}
