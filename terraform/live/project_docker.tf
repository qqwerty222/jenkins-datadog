module "website_net" {
    source = "../modules/docker/docker_network"

    network_name = "website_net"

    ipam_config  = [ 
        # [ subnet, ip_range, gateway ]
        [ "172.1.0.0/16", "172.1.1.0/24", "172.1.1.254"]
    ]
}

module "website_image" {
    source = "../modules/docker/docker_images"
    
    image_name = "localhost:5005/website"
}

module "website_node" {
    source = "../modules/docker/docker_container"
    
    container_names = ["website_node1", "website_node2", "website_node3"]
    docker_image    = module.website_image.id

    network_name    = "website_net"
    ipv4_address    = ["172.1.1.10", "172.1.1.11", "172.1.1.12"]

    ports       = [
        # [ internal, external]
        [8000, null]
    ]

    volumes     = [ 
        # [ "/host_path", "/container_path" ]
        ["/srv/website_logs/gunicorn/access.log", "/usr/src/app/log/access.log"],
        ["/srv/website_logs/gunicorn/error.log",  "/usr/src/app/log/error.log"]
    ]

    entrypoint  = [
        "gunicorn",  
            "--bind",           "0.0.0.0:8000", 
            "--error-logfile",  "log/error.log",
            "--access-logfile", "log/access.log",
        "wsgi:app"
    ]

    depends_on  = [ module.website_net ]
}

module "nginx_image" {
    source = "../modules/docker/docker_images"

    image_name   = "nginx:1.22"
    keep_locally = true
}

module "nginx_node" {
    source = "../modules/docker/docker_container"

    docker_image   = module.nginx_image.id
    container_names = ["nginx_node"]
    
    network_name    = "website_net"
    ipv4_address    = ["172.1.1.15"]

    ports = [
        # [ internal, external]
        [80, 80]
    ]

    volumes = [
        # [ "/host_path", "/container_path" ]
        ["${path.cwd}/conf/nginx.conf", "/etc/nginx/nginx.conf"],
        ["/srv/website_logs/nginx/access.log", "/var/log/nginx/access.log"],
        ["/srv/website_logs/nginx/error.log",  "/var/log/nginx/error.log"]
    ]

    depends_on = [ module.website_net ]
}

module "datadog_image" {
    source = "../modules/docker/docker_images"

    image_name   = "datadog"
    build = [{ context = "../modules/datadog", tag=["dd:test"] }]
    
    keep_locally = false
}

module "datadog_node" {
    source = "../modules/docker/docker_container"

    docker_image    = module.datadog_image.id
    container_names = ["datadog_node"]
    env_vars        = [
        "DD_API_KEY=${var.DATADOG_API_KEY}",
        "DD_HOSTNAME=docker_agent",
        "DD_SITE=datadoghq.eu",
        "DD_TAGS= env:dev "
        ] 

    network_name    = "website_net"
    ipv4_address    = ["172.1.1.20"]

    volumes = [
        # [ "/host_path", "/container_path", "read_only(default:false)" ]
        ["/var/run/docker.sock", "/var/run/docker.sock", true],
        ["/sys/fs/cgroup/", "/host/sys/fs/cgroup", true],
        ["/proc/", "/host/proc/", true],
    ]   
}

