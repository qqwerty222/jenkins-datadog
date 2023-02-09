variable "container_name" {
    type    = string
    default = null
}

variable "hostname" {
    type    = string
    default = null
}

variable "docker_image" {
    type    = string
    default = null
}

variable "start_command" {
    type    = list
    default = null
}

variable "entrypoint" {
    type    = list
    default = null
}