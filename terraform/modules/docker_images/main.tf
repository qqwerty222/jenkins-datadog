resource "docker_image" "common" {
    name = var.image_name

    build {
      context = var.build_context
    }

    keep_locally = false
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