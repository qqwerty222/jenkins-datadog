resource "docker_network" "common" {
    name = var.network_name

    driver = "bridge"

    dynamic ipam_config {
        for_each = var.ipam_config
        content {
            subnet   = ipam_config.value[0]
            ip_range = ipam_config.value[1] 
            gateway  = ipam_config.value[2]
        }
    }
}

