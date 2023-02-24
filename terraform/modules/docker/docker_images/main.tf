resource "docker_image" "common" {
    name = var.image_name

    dynamic "build" { 
        for_each = var.build
        content {
            context = build.value["context"]
            tag     = build.value["tag"]
        }
    }

    keep_locally = var.keep_locally
}


