# terraform-aws

## Task: 
 Implement CI/CD pipeline, to test, deploy and monitor some application

## Main Tools:
- Docker
- Jenkins
- Datadog
- Terraform 

## Configuration:
- Host       - Windows 10
- Hypervisor - VirtualBox 7.0
- Dockerhost - (VM) Ubuntu Server 22.04 (10.0.2.15)
- Jenkins    - (VM) Ubuntu Server 22.04 (10.0.2.10)
- WSL - as control terminal
***

## Project overview:
-  Prepare environment to work:
   1. Configure NAT network in VirtualBox
   2. Set up connection between VMs using ssh keys  
   3. SSH from WSL into Virtual Machines
  
- Configure Dockerhost
   1. Install Docker
   2. Prepare directories for website logs and terraform state

- Configure Jenkins
   1. Install Jenkins  
   2. Create credentials for GIT and Dockerhost 
   3. Connect Dockerhost as Jenkins node 
  
- Terraform for Docker
   1. Docker images
   2. Docker containers
   3. Docker network

- Terraform for Datadog
   1. Connect to Datadog API
   2. Dashboard list
   3. Dashboards 
   4. Monitors
   5. Custom Checks
   6. Datadog Agent
  
- Nginx
  1. Nginx configuration

- Jenkins
    1. Create and set up Pipeline
    2. Jenkinsfile

***
