resource "docker_container" "common" {
    count = length(var.container_names)

    name = element(var.container_names, count.index)
    image    = var.docker_image

    tty        = var.tty
    attach     = var.attach 
    stdin_open = var.stdin_open
    command    = var.commands
    entrypoint = var.entrypoint

    networks_advanced {
        name         = var.network_name
        ipv4_address = element(var.ipv4_address, count.index)
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

# provider "docker" {
#   host = "unix:///var/run/docker.sock"
# }