
variable "location" {
  default="centralUS"
  type = string
}

variable "name" {
  default="examplenonprodacr"
  type = string
}

variable "sku" {
  type        = string
  description = "The SKU name of the container registry. Possible values are Basic, Standard and Premium. Classic (which was previously Basic) is supported only for existing resources"
  default     = "Standard"
}