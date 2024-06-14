variable "location" {
  description = "The location of the resources"
  type        = string
}

variable "rg_name" {
    description = "The existing resource group name"
  type        = string
}
variable "rules_file" {
  description = "The path to the CSV file containing the rules"
  type        = string
  default     = "rules.csv"
}