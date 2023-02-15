module "website_node" {
    source = "../modules/docker_container"
    
    docker_image   = module.website_image.id
    container_name = "website_node"

    host = [ ["website", "172.17.0.3"] ]

    ports = [
        # [ internal, external]
        [8000, null]
    ]

    volumes = [ 
        # [ "/host_path", "/container_path"]
        ["${path.cwd}/../../log/gunicorn/access.log", "/usr/src/app/log/access.log"],
        ["${path.cwd}/../../log/gunicorn/error.log",  "/usr/src/app/log/error.log"]
    ]

    entrypoint = [
        "gunicorn",  
            "--bind",           "0.0.0.0:8000", 
            "--error-logfile",  "log/error.log",
            "--access-logfile", "log/access.log",
        "wsgi:app"
    ]
}

module "nginx_node" {
    source = "../modules/docker_container"

    docker_image   = module.nginx_image.id
    container_name = "nginx_node"

    host  = [ ["nginx", "172.17.0.4"] ]
    
    ports = [
        # [ internal, external]
        [80, 80]
    ]

    volumes = [
        # [ "/host_path", "/container_path"]
        ["${path.cwd}/../../nginx.conf", "/etc/nginx/nginx.conf"],
        ["${path.cwd}/../../log/nginx/access.log", "/var/log/nginx/access.log"],
        ["${path.cwd}/../../log/nginx/error.log",  "/var/log/nginx/error.log"]
    ]
}

module "website_image" {
    source = "../modules/docker_images"
    
    image_name = "localhost:5000/website"
}

module "nginx_image" {
    source = "../modules/docker_images"

    image_name   = "nginx:1.22"
    keep_locally = true
}