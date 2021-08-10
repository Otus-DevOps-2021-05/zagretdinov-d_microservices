terraform {
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket   = "zagretdinov-d-microservices-terraform"
    region   = "ru-central1"
    key      = "terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
