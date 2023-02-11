terraform {
  backend "local" {
    path = "/srv/terraform_state/terraform.tfstate"
  }
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