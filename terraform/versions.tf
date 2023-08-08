terraform {
  required_version = ">= 1.5.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.77.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "google" {
  project = var.project_id
}

provider "random" {}
