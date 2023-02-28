resource "docker_container" "common" {
    count     = var.container_count

    name       = "${var.name}${count.index + 1}"
    image      = var.docker_image

    tty        = var.tty
    attach     = var.attach 
    stdin_open = var.stdin_open
    command    = var.commands
    entrypoint = var.entrypoint
    env        = var.env_vars

    networks_advanced {
        name         = var.network["name"]
        ipv4_address = "${var.network["subnet"]}${var.network["start_from"] + count.index}"
    }

    dynamic "ports" {
      for_each = var.ports
      content {
        internal = ports.value[0]
        external = ports.value[1]
        # protocol = ports.value[2]
      }
    }

    dynamic "upload" {
      for_each = var.upload
      content {
        file    = upload.value[0]
        content = upload.value[1]
      }
    }

    dynamic "volumes" {
      for_each = var.volumes
      content {
        host_path      = volumes.value[0]
        container_path = volumes.value[1]
        read_only      = try(volumes.value[2], false)
      }
    }
}
