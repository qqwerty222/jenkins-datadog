resource "docker_image" "common" {
    name = var.image_name

    build {
        context = var.dockerfile_path
    }

    keep_locally = false
}