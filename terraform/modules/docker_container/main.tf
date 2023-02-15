resource "docker_container" "common" {
    image    = var.docker_image

    name     = var.container_name

    tty        = var.tty
    attach     = var.attach 
    stdin_open = var.stdin_open
    command    = var.commands
    entrypoint = var.entrypoint

    dynamic "host" {
      for_each = var.host
      content {
        host = host.value[0]
        ip   = host.value[1]
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