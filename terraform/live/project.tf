module "prod_node" {
    source = "../modules/docker_container"
    
    docker_image   = module.python_website.image_id

    container_name = "prod_node"
    hostname       = "prod_node"

    entrypoint = [
        "flask", "--app", "flaskr", "run", "-h", "0.0.0.0"
        ]

    internal_port = 5000
    external_port = 80
}

module "python_website" {
    source = "../modules/docker_images"
    image_name = "localhost:5000/website"
}