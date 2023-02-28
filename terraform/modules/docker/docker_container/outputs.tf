output "ipv4_addresses" {
    value = [
        for x in docker_container.common[*].network_data[0]["ip_address"]:
        "${x}"
    ]
}