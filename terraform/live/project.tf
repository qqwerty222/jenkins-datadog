module "website_node" {
    source = "../modules/docker_container"
    
    docker_image   = module.website_image.id

    container_name = "website_node"
    hostname       = "website"

    internal_port = 8000
    external_port = 80

    host_path      = "${path.cwd}/../../website/log/access.log"
    container_path = "/usr/src/app/log/access.log"

    entrypoint = [
        "gunicorn",  
            "--bind",           "0.0.0.0:8000", 
            "--error-logfile",  "log/error.log",
            "--access-logfile", "log/access.log",
        "wsgi:app"
        ]
}

# module "nginx_node" {
#     source = "../modules/docker_container"

#     docker_image = module.nginx_image.id

#     container_name = "nginx"
#     hostname       = "nginx"

#     entrypoint = [
#         ""
#     ]
# }

module "website_image" {
    source = "../modules/docker_images"
    
    image_name = "localhost:5000/website"
}

# module "nginx_image" {
#     source = "../modules/docker_images"

#     image_name   = "nginx:1.22"
#     keep_locally = true
# }