terraform {
  required_version = ">= 1.3"

  required_providers {
    clevercloud = {
      source  = "CleverCloud/clevercloud"
      version = "~> 2.3"
    }
  }
}
