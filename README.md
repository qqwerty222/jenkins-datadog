# Project Description
***
## Task:

Implement CI/CD pipeline, to test, deploy and monitor some application

*** 
## Main Tools:

- Docker
- Jenkins
- Datadog
- Terraform 

*** 
## Configuration:

- Host       - Windows 10
- Hypervisor - VirtualBox 7.0
- Dockerhost - (VM) Ubuntu Server 22.04 (10.0.2.15)
- Jenkins    - (VM) Ubuntu Server 22.04 (10.0.2.10)
- WSL - as control terminal

*** 
## Guide to reproduce:

-  [Prepare environment](#prepare-environment):
   1. Set up NAT network in VirtualBox 
   2. SSH into Virtual Machines
   3. Generate and use ssh-keys
   ---
  
- [Configure Dockerhost](#configure-dockerhost)
   1. Install Docker
   2. Create user for Jenkins 
   3. Prepare directories for website logs and terraform state
   ---

- [Configure Jenkins server](#configure-jenkins-server)
   1. Install Jenkins  
   2. SSH to jenkins user on Dockerhost
   3. Log in and configure Jenkins
   4. Connect Dockerhost as Jenkins node 
   5. Create jenkins pipeline
   ---
  
***
##  Project implementation

- [Terraform for Docker](#terraform-for-docker)
   1. [Docker images](#docker-images)
      - docker image resource
      - website image module
      - nginx image module
      - datadog-agent image module
   2. [Docker containers](#docker-containers)
      - docker container resource
      - website container module
      - nginx container module
      - datadog-agent container module
   3. [Docker network](#docker-network)
   ---

- Terraform for Datadog
   1. Connect to Datadog API
   2. Dashboard list
   3. Dashboards 
   4. Monitors
   5. Custom Checks
   6. Datadog Agent
   ---
  
- [Nginx](#nginx)
   1. Nginx configuration
   ---

- [Jenkins](#jenkins)
   1. Jenkinsfile
---  

# Guide to reproduce  

## Prepare environment

### Set up NAT network in VirtualBox 
---
NAT network means that VirtualBox creates dedicated network for your VMs, but with your host as gateway. To redirect ssh connections to one of VMs set up port forwarding in your NAT network

Port forwarding scheme:
| Name            | Protocol   | Host IP | Host Port | Guest IP  | Guest Port |
|-----------------|------------|---------|-----------|-----------|------------|
| DockerH-ssh     | TCP        |         | 2222      | 10.0.2.15 | 22         |
| DockerH-http    | TCP        |         | 80        | 10.0.2.15 | 80         |
| Jenkins-ssh     | TCP        |         | 2223      | 10.0.2.10 | 22         |
| Jenkins-ui      | TCP        |         | 8080      | 10.0.2.10 | 8080       |

### Connect to Dockerhost VM from Host (Windows Terminal)
---
   You can not connect to one of the VMs directly, you need to use loopback address (localhost).  
   - SSH to Dockerhost from Host (Windows Terminal)
      ```bash
      C:\Users\user>ssh -p 2222 bohdan@localhost
      ```


### Connect to Dockerhost VM from WSL
---
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
---

To ssh inside NAT network from one VM to another you can use internal ip addresses

- SSH to Dockerhost from Jenkins server
   ```bash
   bohdan@jenkins:~$ ssh bohdan@10.0.2.15
   ```

***  
## Generate and use ssh-keys

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

To prepare Dockerhost for work you need to install Docker, create user for Jenkins and directories to store terraform state and website logs

### Install Docker 
--- 
Official guide you can find here:
https://docs.docker.com/engine/install/ubuntu/

- Install utils you will need while docker installation
  ```bash
  bohdan@dockerhost:~$ sudo apt-get update
  ...
  bohdan@dockerhost:~$ sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  ...
  ```

- Create keyrings dir and download gpg key from docker site
  ```bash
  bohdan@dockerhost:~$ sudo mkdir -m 0755 -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  ```

- Create entry to local repo list
  ```bash
  bohdan@dockerhost:~$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  ```

- Update local repo list and install required docker packages
  ```bash
  bohdan@dockerhost:~$ sudo apt-get update
  ...
  bohdan@dockerhost:~$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  ...
  ```

- Add yourself to docker group to be able run it without sudo, and relogin to apply changes
  ```bash
  bohdan@dockerhost:~$ sudo usermod -aG docker bohdan
  bohdan@dockerhost:~$ su $USER
  ```

### Run docker registry
---

- Run docker registry
  ```bash
  bohdan@dockerhost:~$ docker run -d -p 5005:5000 --restart=always --name registry registry:2
  ...
  bohdan@dockerhost:~$ docker ps
   CONTAINER ID   IMAGE        COMMAND                  CREATED         STATUS         PORTS                                       
   8624b0e36d23   registry:2   "/entrypoint.sh /etc…"   5 seconds ago   Up 4 seconds   0.0.0.0:5005->5000/tcp

### Install terraform
---
Official guide you can find here:
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

- Install required packages
  ```bash
  bohdan@dockerhost:~$ sudo apt-get update
  bohdan@dockerhost:~$ sudo apt-get install gnupg software-properties-common
  ```

- Add HashiCorp gpg key
  ```bash
  bohdan@dockerhost:~$ wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  ```

- Create entry to local repo list
  ```bash
  bohdan@dockerhost:~$ echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
      https://apt.releases.hashicorp.com $(lsb_release -cs) main" |     sudo tee /etc/apt/sources.list.d/hashicorp.list
  ```

- Install terraform
  ```bash
  bohdan@dockerhost:~$ sudo apt update
  bohdan@dockerhost:~$ sudo apt-get install terraform
  ```

### Create Jenkins user
---

- Create Jenkins user 
  ```bash
  bohdan@dockerhost:~$ sudo useradd -m --shell /bin/bash jenkins
  ```

- Add user to docker and sudo groups
  ```bash
  bohdan@dockerhost:~$ sudo usermod -aG docker jenkins 
  bohdan@dockerhost:~$ sudo usermod -aG sudo jenkins
  ```

- Add jenkins to NOPASSWD group, to execute sudo commands without password
  ```bash
   bohdan@dockerhost:~$ sudo visudo
   ...
   @includedir /etc/sudoers.d
   bohdan ALL=(ALL) NOPASSWD:ALL
   jenkins ALL=(ALL) NOPASSWD:ALL
   ```

- Create .ssh/authorized_keys for jenkins user
  ```bash
   bohdan@dockerhost:~$ sudo -i
   root@dockerhost:~# su jenkins
   jenkins@dockerhost:/root$ mkdir /home/jenkins/.ssh
   jenkins@dockerhost:/root$ touch /home/jenkins/.ssh/authorized_keys
   ```

- Also you will need to gen and add public ssh-key into /home/jenkins/.ssh/authorized-keys (you can not log in using pass, only ssh-key)  

- And install java, because jenkins will run Dockerhost as agent
  ```bash
  bohdan@dockerhost:~$ sudo apt install openjdk-11-jre
  ```

### Prepare directories for website logs and terraform state
---

- Create directory for terraform state, and allow other users read and write
  ```bash
   bohdan@dockerhost:~$ sudo mkdir /srv/terraform_state
   bohdan@dockerhost:~$ sudo chmod o+rw /srv/terraform_state/
  ```

- Create directories for website and nginx logs
  ```bash
   bohdan@dockerhost:~$ sudo mkdir /srv/website_logs
   bohdan@dockerhost:~$ sudo chmod o+rw /srv/website_logs
   # change to jenkins user
   bohdan@dockerhost:~$ sudo -i
   root@dockerhost:~# su jenkins
   jenkins@dockerhost:$ mkdir /srv/website_logs/nginx
   jenkins@dockerhost:$ mkdir /srv/website_logs/gunicorn 
   ```
***
## Configure Jenkins Server

To prepare jenkins server you need to install Jenkins and terraform, set up ssh connection to dockerhost and configure Jenkins

### Install Jenkins
---
Official guide you can find here:  
https://www.jenkins.io/doc/book/installing/linux/#debianubuntu

- Install Java package
  ```bash
   bohdan@jenkins:~$ sudo apt update
   bohdan@jenkins:~$ sudo apt install openjdk-11-jre
   bohdan@jenkins:~$ java -version
   ```

- Install utils you will need while Jenkins installation
  ```bash
   bohdan@jenkins:~$ sudo apt-get update
   ...
   bohdan@jenkins:~$ sudo apt-get install \
      ca-certificates \
      curl \
      gnupg \
      lsb-release
   ...
  ```

- Add gpg key and Jenkins repo
  ```bash
   bohdan@jenkins:~$ sudo mkdir -m 0755 -p /etc/apt/keyrings
   curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
   /usr/share/keyrings/jenkins-keyring.asc > /dev/null
  
   bohdan@jenkins:~$ echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
   https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
   /etc/apt/sources.list.d/jenkins.list > /dev/null
  ```

- Update local repo and install Jenkins
  ```bash
   bohdan@jenkins:~$ sudo apt-get update
   bohdan@jenkins:~$ sudo apt-get install jenkins  
   ```

- Start Jenkins and enable on startup
  ```bash
   bohdan@jenkins:~$ sudo systemctl start jenkins
   bohdan@jenkins:~$ sudo systemctl enable jenkins
   bohdan@jenkins:~$ sudo systemctl status jenkins
   ```  

Don't forget to map port 8080 to Host, it is where Jenkins UI working  

### SSH to jenkins user on Dockerhost
---
[Generate and use ssh-keys](#generate-and-use-ssh-keys)
  
- Generate ssh-key for jenkins user
  ```bash
   bohdan@jenkins:~$ ssh-keygen
   Enter file in which to save the key (/home/bohdan/.ssh/id_rsa): /home/bohdan/.ssh/dockerhost-ssh
   ```

- Temporarly send it to home dir of bohdan user, and add into authorized_keys of jenkins user
  ```bash
   bohdan@jenkins:~$ scp /home/bohdan/.ssh/dockerhost-ssh.pub bohdan@10.0.2.15:/home/bohdan/dockerhost-ssh.pub
   # ssh into dockerhost
   bohdan@dockerhost:~$ sudo -i
   root@dockerhost:~$ cat /home/bohdan/dockerhost-ssh.pub >> /home/jenkins/.ssh/authorized_keys
   ```

- SSH into jenkins user on Dockerhost
  ```bash
   bohdan@jenkins:~$ ssh -i /home/bohdan/.ssh/dockerhost-ssh jenkins@10.0.2.15
   ```

This ssh-key you also can use as Jenkins credential to connect Dockerhost as node

### Create known_hosts file for jenkins (copy from bohdan user, because it already SSHed into dockerhost)
---

- Login as jenkins user on jenkins server
  ```bash
  bohdan@jenkins:~$ sudo -i
  root@jenkins:~# su jenkins
  ```

- Create known_hosts file for jenkins server
  ```bash
  jenkins@jenkins:~$ mkdir /var/lib/jenkins/.ssh
  jenkins@jenkins:~$ touch /var/lib/jenkins/.ssh/known_hosts
  ```

- Copy known_hosts from user bohdan, because it already SSHed to Dockerhost 
  ```bash
  jenkins@jenkins:~$ exit
  root@jenkins:~# cat /home/bohdan/.ssh/known_hosts >> /var/lib/jenkins/.ssh/known_hosts
  ```

### Log in and configure Jenkins
---

When you open Jenkins (http://localhost:8080) first time you will be asked for initialAdminPassword

- Get initialAdminPassword
  ```bash
   bohdan@jenkins:~$ sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    *password*

- Set up Jenkins:
  - After you get an offer to install some plugins, install suggested plugins  
  - Next create admin account 
  - Leave default Jenkins URL  
  - Set up ssh connection in your github repo | [Guide](https://github.com/qqwerty222/guide-book/blob/main/Git/Git%20repo%20create%20guide.md)
  - Go to http://localhost:8080/manage/credentials/store/system/domain/_/newCredentials and create:
   
   | Name | Kind | ID |
   |------|------|----|
   | jenkins         | SSH Username with private key | docker_host_ssh |
   | jenkins-master  | SSH Username with private key | ssh-github      |
   | datadog_api_key | Secret text                   | datadog_api_key |
   | datadog_app_key | Secret text                   | datadog_api_key |

  - Go to http://localhost:8080/manage/configureSecurity/
    - Set "Git Host Key Verification Configuration/Host key verification" to "Accept first connection"
### Connect Dockerhost as Jenkins node 
---
Jenkins node is server where Jenkins will execute commands, in current project you will use Dockerhost as Jenkins node  
It will run docker containers and terraform

- Connect new node 
  - Go to http://localhost:8080/manage/computer/new
    - Set name "terraform-docker" and pick "Permanent Agent"
    - Remote root dir: /home/jenkins
    - Labels: terraform_docker
    - Usage: Only build jobs with label expression matching this node
    - Launch method: SSH
      - Host: 10.0.2.15 (Dockerhost ip)
      - Credentials: jenkins
      - Host Key Verification Strategy: Known hosts file
  - There you can control new node: http://localhost:8080/manage/computer/terraform-docker/
  - There you can see logs: http://localhost:8080/manage/computer/terraform-docker/log

### Create jenkins pipeline
---

- Add new job 
  - Go to http://localhost:8080/view/all/newJob
    - Set name "python-website" and pick "Pipeline"
    - Set "Pipeline/Definition" to "Pipeline script from SCM"
      - SCM: Git
      - Repository URL: git@github.com:qqwerty222/jenkins-datadog.git
      - Credentials: jenkins-master
      - Branch Specifier: */dev
      - Script path: Jenkinsfile

- Try to build manually
  - Go to http://localhost:8080/job/python_website/
  - Click "Build now"

***
# Project implementanion

## Terraform for docker

I use containers to run python website, nginx, datadog-agent and docker registry that stores images for website container.

### Docker images:
---

- Terraform docker image resource 
  ```hcl
  # terraform/modules/docker_images/main.tf

  resource "docker_image" "common" {
    name = var.image_name

    dynamic "build" { 
        for_each = var.build
        content {
            context = build.value["context"]
            tag     = build.value["tag"]
        }
    }

    keep_locally = var.keep_locally
  }
  ```

  In current case i made build block dynamic, because only datadog-agent image is builded from Dockerfile. And i don't need to fill build block for website of nginx images

  Meaning of all variables used here you can find in [documentation](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image)

  Current resource have only one output, for image id:
  ```hcl
  # terraform/modules/docker_images/outputs.tf

  output "id" {
    value       = docker_image.common.image_id
    description = "Docker image ID"
  }
  ```

- Terraform website image module
  ```hcl
  # terraform/live/project_docker.tf

  module "website_image" {
    source = "../modules/docker/docker_images"
    
    image_name = "localhost:5005/website"
  }
  ```

  Image for website is builded by Jenkins job, and if pytest was successfull send it to docker registry, from where terraform take latest uploaded image.

- Terraform nginx image module
  ```hcl
  # terraform/live/project_docker.tf

  module "nginx_image" {
    source = "../modules/docker/docker_images"

    image_name   = "nginx:1.22"
    keep_locally = true
  }
  ```

  Image for nginx is downloaded from public docker source, and in this case i live keep_locally=true because there is no need to redownload it every time.

- Terraform datadog_image module
  ```hcl
  # terraform/live/project_docker.tf

  module "datadog_image" {
    source = "../modules/docker/docker_images"

    image_name   = "datadog"
    build        = [{ context = "../modules/datadog", tag=["dd:test"] }]
    
    keep_locally = false
  } 
  ```

  This image is builded from local Dockerfile, reason of this is datadog custom checks, config files of which must be located in datadog agent. Also one of checks needs ip util to work, so Dockerfile incude RUN command to install it

  ```hcl
  # terraform/modules/datadog/Dockerfile

  FROM gcr.io/datadoghq/agent:7

  RUN apt-get update && apt-get install iputils-ping && apt-get autoremove

  COPY dd_custom_checks/conf.d/. /etc/datadog-agent/conf.d/
  COPY dd_custom_checks/checks.d/. /etc/datadog-agent/checks.d/
  ```

### Docker containers
---

- Terraform docker container resource
  ```hcl
  # terraform/modules/docker_container/main.tf

  resource "docker_container" "common" {
    count     = var.container_count

    name       = "${var.name}${count.index + 1}"
    image      = var.docker_image

    tty        = var.tty
    attach     = var.attach 
    stdin_open = var.stdin_open
    command    = var.commands
    entrypoint = var.entrypoint
    env        = var.env_vars
  ...
  ```

  Docker container resource use special variable count, it specify how many containers will be started using this resource. It is equal to variable container_count i specified in modules.

  To make module more clear, i generate name for the container automatically. You need to specify only one name, and no matter what count you specified, containers' names will be "name + number of the container".

  Meaning of all variables used here you can find in [documentation](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container)

  Network block is not dynamic because i deploy one single custom network. But i deploy multiple number of containers, so their ipv4 config generated automatically from 2 parameters.  
  subnet - include first 3 numbers of ipv4 with dot in the end.  
  start_from - ip of each new container is ip of the previous container + 1.  
  start_from specify which ip will have first container.

  ```hcl
  # terraform/modules/docker_container/main.tf
  ...    
      networks_advanced {
        name         = var.network["name"]
        ipv4_address = "${var.network["subnet"]}${var.network["start_from"] + count.index}"
    }
  ...

  # terraform/modules/docker_container/variables.tf
  ...
    variable "network" {
        type = object({
            name            = string
            subnet          = string
            start_from      = number
        })
        default = null
        description = "Set custom network | network = { name='net_1', ipv4_subnet='1.1.1.', ip_started_from='10' }"
    }
  ...
  ```

  Blocks ports, upload and volumes are dynamic, to be able add multiple volumes or ports to one container, or don't specify files to upload for each container  

  Each block get list from module, and search for values for their indexes.

  ```hcl
  # terraform/modules/docker_container/main.tf
  ...
    dynamic "ports" {
      for_each = var.ports
      content {
        internal = ports.value[0]
        external = ports.value[1]
        # protocol = ports.value[2]
      }
    }

    dynamic "upload" {
      for_each = var.upload
      content {
        file    = upload.value[0]
        content = upload.value[1]
      }
    }

    dynamic "volumes" {
      for_each = var.volumes
      content {
        host_path      = volumes.value[0]
        container_path = volumes.value[1]
        read_only      = try(volumes.value[2], false)
      }
    }
  }

  # terraform/modules/docker_container/main.tf

  variable "ports" {
      type        = list
      default     = []
      description = "Internal/External ports to expose | [ 22, 2222 ]"
  }

  variable "upload" {
      type    = list
      default = []
      description = "File to upload before start of the container | [ '/container_path', 'content_of_the_file' ]"
  }

  variable "volumes" {
      type        = list
      default     = []
      description = "Volumes to create | [ '/host_path', '/container_path' ] "
  }
  ```

  Also to get full list of names and ips i use outputs
  ```
  # terraform/modules/docker/docker_container/outputs.tf
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
  ```

- Terraform website container module
  
  Website container needs volumes to bind logs with /srv dir on Dockerhost.  
  Port 8000, is standart port for gunicorn wsgi, thing that handle http requests from nginx.
  To start website app in docker container i use entrypoint with gunicorn command that starts python code.
  Container count is specified by environment variable you can find in "/terraform/live/variables.tf" and Jenkinsfile. 
  ```tf
  # terraform/modules/docker_container/main.tf

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
  
- Terraform nginx container module
  
  Nginx container also uses volumes to bind logs to /srv on Dockerhost   
  Also you can see upload block, it specify file to upload in container before start  
  I use it to upload rendered nginx.conf template using terraform variables
  ```
  # terraform/modules/docker_container/main.tf

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
  ```

- Terraform datadog-agent container module
  
  Datadog-agent uses volumes to get logs from Dockerhost, parameter true means that they are read-only  
  Also you can see a lot of env_vars, WEBSITE_COUNT is used in datadog custom_checks, another vars is just datadog connection parameters, they are taken from "/terraform/live/variables.tf"
  ```
  # terraform/modules/docker_container/main.tf

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

### Docker network
---

- Terraform docker network resource    
  All network configuration is list with 3 parameters and variable that specify name  
  Another parameters you can find in [documentation](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/network)
  ```tf
  # terraform/modules/docker_network/main.tf

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
  ```

  Variables for network configuration with description:
  ```
  # terraform/modules/docker_network/main.tf

  variable "network_name" {
    type        = string
    default     = null
    description = "Name of network to create"
  }

  variable "ipam_config" {
      type        = list
      default     = null
      description = " | ipam_config = [ subnet/16, ip_range/24, gateway.254 ]"
  }
  ```

- Terraform network module
  ```
  # terraform/modules/docker_network/main.tf

  module "website_net" {
    source = "../modules/docker/docker_network"

    network_name = "website_net"

    ipam_config  = [ 
        # [ subnet, ip_range, gateway ]
        [ "172.1.0.0/16", "172.1.1.0/24", "172.1.1.254"]
    ]
  }
  ```

## Nginx
---

### Nginx configuration

Nginx is running in docker container, in website_net docker network. Configuration file you can find in "terraform/live/conf/nginx_conf.tpl"

- Upstream block
  
  There is a list of ip addresses of website containers to which nginx will redirect requests.  
  But count of container is dynamic, in one environment it can be 3 in another 7, to update nginx config automatically i use terraform templates.  
  Below you can see for loop that generate string from list "website_addresses"  

  ```nginx
  # terraform/live/conf/nginx_conf.tpl

  http {
      upstream websites {
          %{ for address in website_addresses ~}
          server ${address}:8000;
          %{endfor ~}
      }
  ```

  Below you can see static nginx upstream config for 3 website containers. 
  ```nginx
  http {
    upstream websites {
	    server 172.1.1.10:8000;
	    server 172.1.1.11:8000;
	    server 172.1.1.12:8000;
    }
  ```

  It is part of the nginx container module, where i specify templatefile and list to to use in render
  ```
  # terraform/live/project_docker.tf

      upload  = [[ "/etc/nginx/nginx.conf", 
                templatefile("conf/nginx_conf.tpl", {
                    website_addresses = module.website_node.ipv4_addresses
                })
    ]]
  ```

- Log format block
  There i change log output, because i use upstream and want to see ip address of website container that handled request
  ```nginx
  # terraform/live/conf/nginx_conf.tpl

      log_format upstream     '[$time_local] $remote_addr $upstream_addr '  
                  '"$request" $status $body_bytes_sent '
                  '"$http_user_agent"';
  ```
  It is how new log entry looks like: [17/Feb/2023:15:27:03 +0000] 10.0.2.10 172.1.1.10:8000 "GET / HTTP/1.1" 200 336 "curl/7.81.0"

- Server block  
  This block specifies what port to listen, where save the logs, and what header send to website container.
  proxy_pass specifies to which address redirect requests, but in this case i don't specify ip address, i specify name of the upstream group
  ```nginx
  # terraform/live/conf/nginx_conf.tpl
  
      server{
          listen      80;
          server_name localhost;
          access_log /var/log/nginx/access.log upstream;
          error_log  /var/log/nginx/error.log;
          location / {
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  proxy_set_header Host $http_host;
                  proxy_pass http://websites;
          }
      }
  }
  ```

## Jenkins
---

### Jenkinsfile  
File that include all pipeline steps 

- Prebuild stage  
  There i set agent that will execute job steps ('terraform_docker')  
  Add cron trigger to check updates in git repository each minute  
  And set environment variables that will be used by terraform code and datadog agent  

  ```Jenkinsfile
  # Jenkinsfile

  pipeline {

    agent {label 'terraform_docker'}
    triggers { pollSCM('* * * * *') }
    environment {
        DATADOG_API_KEY = credentials('datadog_api_key')
        DATADOG_APP_KEY = credentials('datadog_app_key')
        TF_VAR_DATADOG_API_KEY = credentials('datadog_api_key')
        TF_VAR_WEBSITE_NODE_COUNT = 4
    }
  ...
  ```

- Prepare codebase stage  
  First step clear previous project folder that Jenkins create each build  
  Next clone repository from branch /dev, using ssh-key saved in Jenkins credentials

  ```Jenkinsfile
  # Jenkinsfile

  ...
      stages { 
        stage('Prepare Codebase'){
            steps{
                cleanWs()
                checkout scm: [$class: 'GitSCM', branches: [[name: '*/dev']], userRemoteConfigs: 
                [[credentialsId: 'ssh-github', url: 'git@github.com:qqwerty222/jenkins-project.git' ]]]
            }
        }
  ...
  ```
 
- Tests stage  
  In this stage i execute shell commands to build image from Dockerfile in test_website dir  
  Create container and run pytest in it, result file will be mounted in current project dir     
  catchError means that even if pytest failed, next step will be invoked anyway
  ```Jenkinsfile
  # Jenkinsfile

  ...
        stage('Run tests'){
            steps{
                catchError {
                    sh "docker build -t website:v${env.BUILD_NUMBER} test_website/."
                    sh "docker run --name website_v${env.BUILD_NUMBER} -i -v ${WORKSPACE}/test_website/junit_results.xml:/junit_results.xml website:v${env.BUILD_NUMBER} python -m pytest --junit-xml=/junit_results.xml"
                } 
            }
        }
  ...
  ```

- Get test result  
  In this step Junit save results of the pytest  
  If pytest was failed set status "FAILED" to the build with error "Pytest failed" and stop it, if pytest Ok Jenkins will run next stages 

  ```
  # Jenkinsfile

  ...
        stage('Get test result') {
            steps{
                catchError(buildResult: 'FAILURE'){
                    archiveArtifacts artifacts: 'test_website/junit_results.xml'
                    junit 'test_website/junit_results.xml'
                }
                
                script {
                    if (currentBuild.currentResult == "FAILURE")
                        error 'Pytest failed'
                }
            }
        } 
  ...
  ```

- Push image  
  This stages invokes only if pytest was succesfull  
  There using shell commands image builded in 'Run Tests' stage will be sended to docker registry

  ```Jenkinsfile
  # Jenkinsfile
  ...
        stage('Push image'){
            steps{
                sh "docker image tag website:v${env.BUILD_NUMBER} localhost:5005/website"
                sh "docker push localhost:5005/website"
            }
        }
  ...
  ```

- Update website  
  This stage add entry to logs with build number  
  After change directory to terraform/live and init terraform  
  Next destroy previous infrastructure and create new

  ```Jenkinsfile
  # Jenkinsfile

  ...
        stage('Update website'){
            steps {
                // left label in logs, to understand by what build they were created
                sh "echo '#-----build${env.BUILD_NUMBER}-----#' >> /srv/website_logs/gunicorn/access.log"
                sh "echo '#-----build${env.BUILD_NUMBER}-----#' >> /srv/website_logs/gunicorn/error.log"
                sh "echo '#-----build${env.BUILD_NUMBER}-----#' >> /srv/website_logs/nginx/access.log"
                sh "echo '#-----build${env.BUILD_NUMBER}-----#' >> /srv/website_logs/nginx/error.log"

                dir('terraform/live') {
                    sh 'terraform init'
                    sh 'terraform destroy -auto-approve'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
  ...
  ```

- Postbuild stage  
  Thist stage invokes always, it delete previously created docker image and container where pytest runned
  ```Jenkinsfile
  # Jenkinsfile 

  ...
      post {
          always {
              sh "docker rm  website_v${env.BUILD_NUMBER}"
              sh "docker rmi website:v${env.BUILD_NUMBER}"
          }
      }
  }
  ```




