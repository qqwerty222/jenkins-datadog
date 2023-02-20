terraform {
  backend "local" {
    path = "/srv/terraform_state/terraform.tfstate"
  }
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }

    datadog  = {
      # source = "DataDog/datadog"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

