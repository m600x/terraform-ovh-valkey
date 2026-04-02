terraform {
  required_version = ">= 1.3"

  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = ">= 1.0, < 2.0"
    }
  }
}
