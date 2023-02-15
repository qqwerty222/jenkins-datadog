resource "docker_container" "common" {
    image    = var.docker_image

    name     = var.container_name
    hostname = var.hostname

    tty        = var.tty
    stdin_open = var.stdin_open
    command    = var.commands
    entrypoint = var.entrypoint

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