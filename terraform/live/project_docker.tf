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

module "nginx_image" {
    source = "../modules/docker/docker_images"

    image_name   = "nginx:1.22"
    keep_locally = true
}

module "datadog_image" {
    source = "../modules/docker/docker_images"

    image_name   = "datadog"
    build        = [{ context = "../modules/datadog", tag=["dd:test"] }]
    
    keep_locally = false
}

module "website_node" {
    source = "../modules/docker/docker_container"
    
    name            = "website_node"
    docker_image    = module.website_image.id
    container_count = var.WEBSITE_NODE_COUNT
    
    network = { 
        name        = "website_net", 
        subnet      = "172.1.1.", 
        start_from  = 10
    }
    ports   = [ [8000, null] ]

    volumes = [ 
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

    depends_on = [ module.website_net ]
}

module "nginx_node" {
    source = "../modules/docker/docker_container"

    name            = "nginx_node"
    docker_image    = module.nginx_image.id

    network = { 
        name        = "website_net", 
        subnet      = "172.1.1.", 
        start_from  = 5
    }
    ports   = [ [80, 80] ]

    upload  = [[ "/etc/nginx/nginx.conf", 
                templatefile("conf/nginx_conf.tpl", {
                    website_addresses = module.website_node.ipv4_addresses
                })
    ]]

    volumes = [
        # [ "/host_path", "/container_path" ]
        # ["${path.cwd}/conf/nginx.conf", "/etc/nginx/nginx.conf"],
        ["/srv/website_logs/nginx/access.log", "/var/log/nginx/access.log"],
        ["/srv/website_logs/nginx/error.log",  "/var/log/nginx/error.log"]
    ]

    depends_on = [ module.website_net ]
}

module "datadog_node" {
    source = "../modules/docker/docker_container"

    name            = "datadog_node"
    docker_image    = module.datadog_image.id

    network = { 
        name        = "website_net", 
        subnet      = "172.1.1.", 
        start_from  = 6 
    }

    volumes = [
        # [ "/host_path", "/container_path", "read_only(default:false)" ]
        ["/var/run/docker.sock", "/var/run/docker.sock", true],
        ["/sys/fs/cgroup/", "/host/sys/fs/cgroup", true],
        ["/proc/", "/host/proc/", true],
    ]  

    env_vars        = [
        "WEBSITE_COUNT=${var.WEBSITE_NODE_COUNT}",
        "DD_API_KEY=${var.DATADOG_API_KEY}",
        "DD_HOSTNAME=docker_agent",
        "DD_SITE=datadoghq.eu",
        "DD_TAGS=env:dev "
    ]  

    depends_on = [ module.website_net ]
}

