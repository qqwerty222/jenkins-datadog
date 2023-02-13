resource "docker_container" "common" {
    image    = var.docker_image

    name     = var.container_name
    hostname = var.hostname

    tty        = var.tty
    stdin_open = var.stdin_open
    command    = var.commands
    entrypoint = var.entrypoint

    ports {
      internal = var.internal_port
      external = var.external_port
    }

    volumes {
      host_path      = "${path.cwd}/../../website/tests/junit_results.xml"
      container_path = "/usr/src/app/tests/junit_results.xml"
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