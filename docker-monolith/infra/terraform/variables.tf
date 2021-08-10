variable "service_account_key_file" {
  description = "key .json"
}
variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable "docker_image_id" {
  description = "Disk image"
}
variable "subnet_id" {
  description = "Subnet"
}
variable "public_key_path" {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable "private_key_path" {
  description = "Path to the PRIVATE key used for ssh access for connetions"
}
variable "region_id" {
  type    = string
  default = "ru-central1"
}
