resource "docker_container" "common" {
    image    = var.docker_image

    name     = var.container_name
    hostname = var.hostname

    command    = var.start_command
    entrypoint = var.entrypoint
}