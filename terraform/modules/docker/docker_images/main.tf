resource "docker_image" "common" {
    name = var.image_name

    keep_locally = var.keep_locally
}


