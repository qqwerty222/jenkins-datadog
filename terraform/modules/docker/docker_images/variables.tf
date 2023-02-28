variable "image_name" {
    type        = string
    default     = null
    description = "Name of the image"
}

variable "build" {
    
    description = "Dockerfile's dir and tag to assign to image | build = [{ context = '.', tag=['image:v1'] }]"
    type    = list(object({
        context = string,
        tag     = list(string)
    }))
    default = []
}
variable "keep_locally" {
    type        = bool
    default     = false
    description = "Delete image while terraform destroy"
}