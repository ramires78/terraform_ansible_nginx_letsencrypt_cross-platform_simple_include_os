## Description

### Ansible. TLS (NGINX+Let's+os_family Encrypt)

#### Roles description

Roles allow you to put together a playbook for different tasks from smaller parts for different situations and solutions. And you don't have to write scripts from the start.

#### Use of roles

```
- hosts: 
  - webservers
  become: true
  become_method: sudo
    
  roles:
    - { role: nginx, tags: web_install }
    - { role: vhosts, tags: make_hosts }
    - { role: TLS, tags: make_cert }

```

```shell
     
     ansible-playbook -i ./ansible/inventories/webservers/hosts.yml ./ansible/nginx.yml --list-task  
     
```
  
  play #1 (all): all  TAGS: []  
    tasks:  
      nginx : install Nginx und Letsencrypt on Ubuntu TAGS: [web_install]  
      nginx : install Nginx, EPEL, setrubleshoot und Letsencrypt on Centos  TAGS: [web_install]  
      nginx : add folder for my website TAGS: [add_opt_folders_website, web_install]  
      nginx : copy the nginx config file on ubuntu  TAGS: [nginx_conf, web_install]  
      vhosts : add folder for item and sertifications virtual hosts ubuntu  TAGS: [make_hosts]  
      vhosts : add folder for item and sertifications virtual hosts ubuntu  TAGS: [make_hosts]  
      TLS : letsencrypt and cron Centos TAGS: [make_cert]  
      TLS : letsencrypt and cron Ubuntu TAGS: [make_cert]  
      TLS : Aktualisieren der Diffie-Hellman-Parameter  TAGS: [hellman, make_cert]   
      

  
#### Target files for role 

`./roles/{name of specific role}/{vars,tasks,handlers}/`  

## Methods of creation  

1. Provision a virtual machine using Terraform on DO and A-Record on Route 53 from AWS:  

```shell
    terraform apply -var-file=terrafor.tfvars
         or 
    terraform apply -var-file=variables.tf
```
2. Provision of virtual hosts in the cloud with the help of Ansible:

```shell
    ansible-playbook -i ./ansible/inventories/webservers/hosts.yml ./ansible/nginx.yml
```

## The results

1. After using it, you can see the results

```shell
    cat outputs_result.csv
```
**P.S. Attention! Change the values of the variables to your own!**
