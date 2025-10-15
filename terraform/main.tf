terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.163.0"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

resource "yandex_vpc_network" "socks_network" {
  name = "socks-network"
}

resource "yandex_vpc_subnet" "socks_subnet" {
  name           = "socks-subnet"
  network_id     = yandex_vpc_network.socks_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "swarm_master" {
  name              = "swarm-master"
  zone              = var.zone
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 20
      type     = "network-ssd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.socks_subnet.id
    nat       = true
  }
  metadata = {
    user-data = templatefile("user-data-swarm.sh", {
      is_master = true
    })
    ssh-keys = "ubuntu:${file("/home/mitin/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "swarm_worker" {
  count = 2
  name  = "swarm-worker-${count.index}"
  zone  = var.zone
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 20
      type     = "network-ssd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.socks_subnet.id
    nat       = true
  }
  metadata = {
    user-data = templatefile("user-data-swarm.sh", {
      is_master = false
    })
    ssh-keys = "ubuntu:${file("/home/mitin/.ssh/id_rsa.pub")}"
  }
}

