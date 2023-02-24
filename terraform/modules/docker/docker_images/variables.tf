variable "image_name" {
    type    = string
    default = null
}

variable "build" {
    type    = list(object({
        context = string,
        tag     = list(string)
    }))
    default = []
}
variable "keep_locally" {
    type    = bool
    default = false
}