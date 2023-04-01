
variable "location" {
  default="centralUS"
  type = string
}

variable "loganalytics_name" {
  default="prm-nonprod-logAnalytics"
  type = string
}

variable "log_retention_days" {
  type        = string
  description = "Time in days to keep the logs available in Azure Monitor"
  default     = 30
}