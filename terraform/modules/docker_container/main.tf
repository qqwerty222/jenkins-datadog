resource "docker_container" "common" {
    image    = var.docker_image

    name     = var.container_name

    tty        = var.tty
    attach     = var.attach 
    stdin_open = var.stdin_open
    command    = var.commands
    entrypoint = var.entrypoint

    # network      = var.network_name
    # ipv4_address = var.ipv4_address

    dynamic "networks_advanced" {
      for_each = var.networks
      content {
        name         = networks_advanced.value[0]
        ipv4_address = networks_advanced.value[1]
      }
    }

    dynamic "ports" {
      for_each = var.ports
      content {
        internal = ports.value[0]
        external = ports.value[1]
      }
    }

    dynamic "volumes" {
      for_each = var.volumes
      content {
        host_path      = volumes.value[0]
        container_path = volumes.value[1]
      }
    }
}

#-----config-----#
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}