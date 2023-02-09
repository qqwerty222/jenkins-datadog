module "docker_test_node_image" {
    path = "../modules/docker_images"

    name = "test_node_image"
    
    dockerfile_path = "../Dockerfiles/test_node.dockerfile"
}
