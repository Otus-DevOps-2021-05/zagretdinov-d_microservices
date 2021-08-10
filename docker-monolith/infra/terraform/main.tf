provider "yandex" {
service_account_key_file = var.service_account_key_file
cloud_id = var.cloud_id
folder_id = var.folder_id
zone = var.zone
}

resource "yandex_compute_instance" "dockerhost" {
  name = "dockerhos-${count.index}"
  count = 1

  resources {
    cores  = 2
    memory = 2
}
metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
}
  boot_disk {
    initialize_params {
      image_id = var.docker_image_id
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }
}
