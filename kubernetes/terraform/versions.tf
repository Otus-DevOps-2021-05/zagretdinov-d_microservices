terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    yandex = {
      source = "terraform-providers/yandex"
    }
  }
  required_version = ">= 0.13"
}
