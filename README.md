# Project Description
***
## Task:
--- 
Implement CI/CD pipeline, to test, deploy and monitor some application

*** 
## Main Tools:
---
- Docker
- Jenkins
- Datadog
- Terraform 

*** 
## Configuration:
---
- Host       - Windows 10
- Hypervisor - VirtualBox 7.0
- Dockerhost - (VM) Ubuntu Server 22.04 (10.0.2.15)
- Jenkins    - (VM) Ubuntu Server 22.04 (10.0.2.10)
- WSL - as control terminal

*** 
## Steps to reproduce:
---
-  Prepare environment:
   1. Set up NAT network in VirtualBox 
   2. SSH into Virtual Machines
   3. Generate and use ssh-keys
   ---
  
- Configure Dockerhost
   1. Install Docker
   2. Create user for Jenkins 
   3. Prepare directories for website logs and terraform state
   ---

- Configure Jenkins server
   1. Install Jenkins  
   2. SSH to jenkins user on Dockerhost
   3. Log in and configure Jenkins
   4. Connect Dockerhost as Jenkins node 
   ---
  
- Terraform for Docker
   1. Docker images
   2. Docker containers
   3. Docker network
   ---

- Terraform for Datadog
   1. Connect to Datadog API
   2. Dashboard list
   3. Dashboards 
   4. Monitors
   5. Custom Checks
   6. Datadog Agent
   ---
  
- Nginx
   1. Nginx configuration
   ---

- Jenkins
   1. Set up Pipeline job
   2. Jenkinsfile
---  

# Guide to reproduce  

***
## Set up NAT network in VirtualBox 
---  

NAT network means that VirtualBox creates dedicated network for your VMs, but with your host as gateway.  
To redirect ssh connections to one of VMs set up port forwarding in your NAT network

### Port forwarding scheme:
---
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
---
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
---
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

- Add yourself to docker group to be able run it without sudo
  ```bash
  bohdan@dockerhost:~$ sudo usermod -aG docker bohdan
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

- Also you need to gen and add public ssh-key into /home/jenkins/.ssh/authorized-keys (you can not log in using pass, only ssh-key)  

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
   bohdan@dockerhost:~$ mkdir /srv/website_logs/gunicorn
   bohdan@dockerhost:~$ mkdir /srv/website_logs/nginx
   ```
***
## Configure Jenkins Server
---
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
   bohdan@jenkins:~$ scp /home/bohdan/.ssh/dockerhost-ssh.pub bohdan@10.0.2.15:/home/bohdan/dockerhost-ssh
   # ssh into dockerhost
   bohdan@dockerhost:~$ sudo -i
   root@dockerhost:~$ cat /home/bohdan/dockerhost-ssh >> /home/jenkins/.ssh/authorized_keys
   ```

- SSH into jenkins user on Dockerhost
  ```bash
   bohdan@jenkins:~$ ssh -i /home/bohdan/.ssh/dockerhost-ssh jenkins@10.0.2.15
   ```
  
This ssh-key you also can use as Jenkins credential to connect Dockerhost as node
   
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
   | jenkins         | SSH Username with private key | docker_host_ssh|
   | jenkins-master  | SSH Username with private key | ssh-github     |
   | datadog_api_key | Secret text                   | docker_host_ssh|
   | datadog_app_key | Secret text                   | docker_host_ssh|

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

