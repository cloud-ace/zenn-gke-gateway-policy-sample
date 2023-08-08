variable "project_id" {
  type        = string
  description = "Please enter your Google Cloud project ID."
}

variable "region" {
  type        = string
  description = "Please enter the region you want to deploy to."
  default     = "asia-northeast1"
}
