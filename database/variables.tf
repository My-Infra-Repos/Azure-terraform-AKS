variable "name" {
  
  type = string
  default="example-nonprod-db"
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
  default="examplenonprod.postgres.database.azure.com"
}