variable "name" {
  
  type = string
  default="prm-nonprod-db"
}

variable "location" {
  type = string
  default="centralUS"
}

variable "address_space" {
  type = string
  default="172.2.2.0/28"
}
variable "dns_name" {
  type=string
  default="prmnonprod.postgres.database.azure.com"
}