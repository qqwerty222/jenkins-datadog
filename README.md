> # Project Description

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

## Steps to reproduce:
-  Prepare environment:
   1. Set up NAT network in VirtualBox 
   2. SSH into Virtual Machines
   3. Generate and use ssh-keys
  
- Configure Dockerhost
   1. Install Docker
   2. Create user for Jenkins 
   3. Prepare directories for website logs and terraform state

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
   1. Set up Pipeline job
   2. Jenkinsfile

> # Prepare environment

## NAT network configuration
NAT network means that VirtualBox creates dedicated network for your VMs, but with your host as gateway.  
To redirect ssh connections to one of VMs set up port forwarding in your NAT network

### Port forwarding scheme
| Name            | Protocol   | Host IP | Host Port | Guest IP  | Guest Port |
|-----------------|------------|---------|-----------|-----------|------------|
| DockerH-ssh     | TCP        |         | 2222      | 10.0.2.15 | 22         |
| DockerH-http    | TCP        |         | 80        | 10.0.2.15 | 80         |
| Jenkins-ssh     | TCP        |         | 2223      | 10.0.2.10 | 22         |
| Jenkins-ui      | TCP        |         | 8080      | 10.0.2.10 | 8080       |

*** 
### Connect to Dockerhost VM from Host (Windows Terminal)
You can not connect to one of the VMs directly, you need to use loopback address (localhost).  
- SSH to Dockerhost from Host (Windows Terminal)
   ```bash
   C:\Users\user>ssh -p 2222 bohdan@localhost
   ```

### Connect to Dockerhost VM from WSL
To connect one of VMs from WSL, you need to specify address of Host

- Get Host ip in WSL network (Windows Terminal)
   ```bash
   C:\Users\user>ipconfig
   Ethernet adapter vEthernet (WSL):
      ...
      IPv4 Address. . . . . . . . . . . : 172.19.80.1
      ...
   ```

- SSH to Dockerhost from WSL
   ```bash
   ╭─bohdan@WSL ~
   ╰─$ ssh -p2222 bohdan@172.19.80.1
   ```

### Connect to Dockerhost from Jenkins server
To ssh inside NAT network from one VM to another you can use internal ip addresses

- SSH to Dockerhost from Jenkins server
   ```bash
   bohdan@jenkins:~$ ssh bohdan@10.0.2.15
   ```

***
## Set up ssh key authentication
There is 2 types of ssh-keys public and private  
Public key is used by target machine to authorize user  
Private key is used by user to connect to target machine  
List of authorized public keys is stored in /home/user/.ssh/authorized_keys file  

- Generate ssh-key 
   ```bash
   ╭─bohdan@WSL ~
   ╰─$ ssh-keygen
   Generating public/private rsa key pair.
   Enter file in which to save the key (/home/bohdan/.ssh/id_rsa): /key/location/name
   ```

- Send public ssh-key to target machine
   ```bash
   ╭─bohdan@WSL ~
   ╰─$ scp -P2222 /key/location/name.pub bohdan@172.19.80.1:/home/bohdan/.ssh/key_name.pub
   ```

- Add public key to authorized keys on target machine
  ```bash
  bohdan@dockerhost:~/.ssh$ cat key_name.pub >> authorized_keys
  ```

- Connect to target machine using private ssh-key
  ```bash
  ╭─bohdan@WSL ~
  ╰─$ ssh -i for_test -p2222 bohdan@172.19.80.1
  ```

In current project you need to create ssh-keys for:
- Dockerhost
- Jenkins server
- Git repository

***
## Configure Dockerhost



