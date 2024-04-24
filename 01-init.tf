terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    http = {
      source = "hashicorp/http"
      version = "3.4.0"
    }
    kubectl = {
      source = "alekc/kubectl"
      version = "2.0.3"
    }
  }
}
# Define vairables
variable "do_token" {}

# Set the provider for the terraform cli
provider "digitalocean" {
  token = var.do_token
}
