output "ipv4_addresses" {
    value = [
        for x in docker_container.common[*].network_data[0]["ip_address"]: "${x}"
    ]
    description = "Output a list of created containers' names"
}

output "container_names" {
    value = [
        for name in docker_container.common[*].name: "${name}"
    ]
    description = "Output a list of created containers' names"
}