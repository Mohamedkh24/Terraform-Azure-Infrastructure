variable "location" {
  default = "North Europe"
}

variable "RG-name" {
  description = "The name of the Resource Group"
  default = "Terraform-RG"
}

# VNet Variables
variable "VNet-name" {
  type = list
  default = ["Hub-VNet","Spoke-VNet"]
}
variable "VNet-Address-Space" {
  type = list
  default = [["10.0.0.0/16"], ["20.0.0.0/16"]]
}

# Subnets Variables
variable "subnet-name" {
  type = list
  default = ["Subnet-1", "Subnet-2", "Priv-DB-Snet"]
}
variable "Sub-Prefix" {
  type = list
  default = [["10.0.1.0/24"], ["10.0.2.0/24"], ["20.0.1.0/24"]]
}

# VM Variables
variable "VM1-size" {
  default = "Standard_B2s"
}
variable "VM2-size" {
  default = "Standard_D2ds_v5"
}

variable "nsg_name" {
  type = list
  default = ["Win-VM-NSG","Lnx-VM-NSG"]
}
variable "allowed_ports1" {
  default = {
    RDP   = 3389
    HTTP  = 80
    HTTPS = 443
  }
}

variable "allowed_ports2" {
  default = {
    SSH   = 22
    HTTP  = 80
    HTTPS = 443
  }
}