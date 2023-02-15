module "website_net" {
    source = "../modules/docker_network"

    network_name = "website_net"

    ipam_config = [ 
        # [ subnet, ip_range, gateway ]
        [ "172.1.0.0/16", "172.1.1.0/24", "172.1.1.254"]
    ]
}

module "website_node" {
    source = "../modules/docker_container"
    
    docker_image   = module.website_image.id
    container_name = "website_node"

    networks = [
        ["website_net", "172.1.1.10"]
    ]

    ports = [
        # [ internal, external]
        [8000, null]
    ]

    volumes = [ 
        # [ "/host_path", "/container_path"]
        ["/srv/website_logs/gunicorn/access.log", "/usr/src/app/log/access.log"],
        ["/srv/website_logs/gunicorn/error.log",  "/usr/src/app/log/error.log"]
    ]

    entrypoint = [
        "gunicorn",  
            "--bind",           "0.0.0.0:8000", 
            "--error-logfile",  "log/error.log",
            "--access-logfile", "log/access.log",
        "wsgi:app"
    ]

    depends_on = [ module.website_net ]
}

module "nginx_node" {
    source = "../modules/docker_container"

    docker_image   = module.nginx_image.id
    container_name = "nginx_node"
    
    networks = [
        ["website_net", "172.1.1.15"]
    ]

    ports = [
        # [ internal, external]
        [80, 80]
    ]

    volumes = [
        # [ "/host_path", "/container_path"]
        ["${path.cwd}/../../nginx.conf", "/etc/nginx/nginx.conf"],
        ["/srv/website_logs/nginx/access.log", "/var/log/nginx/access.log"],
        ["/srv/website_logs/nginx/error.log",  "/var/log/nginx/error.log"]
    ]

    depends_on = [ module.website_net ]
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