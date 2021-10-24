terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "1.22.2"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "digitalocean_ssh_key" "default" {
  name = "REBRAIN.SSH.PUB.KEY"
}

resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Example"
  public_key = var.my_key
}

resource "digitalocean_tag" "erste_tag" {
  name = var.e-mail
}

resource "digitalocean_tag" "zweite_tag" {
  name = "ubuntu"
}

resource "digitalocean_tag" "dritte_tag" {
  name = "centos"
}


resource "random_password" "my_passwords" {
  count   = tonumber(var.zahlen.num_von_vpc)
  length  = 12
  lower   = true
  upper   = true
  number  = true
  special = true
}

### DO Ubuntu###

resource "digitalocean_droplet" "denisdebian" {
  count              = tonumber(var.zahlen.num_von_vpc)
  image              = "ubuntu-18-04-x64"
  name               = "${var.dev.names_von_do_vpc.0}.devops.rebrain.srwx.net"
  region             = "fra1"
  size               = "s-1vcpu-1gb"
  private_networking = true
  ssh_keys           = [data.digitalocean_ssh_key.default.fingerprint, digitalocean_ssh_key.default.fingerprint]
  tags               = [digitalocean_tag.erste_tag.id, digitalocean_tag.zweite_tag.id]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "sudo apt update", "sudo apt install python3 -y", "echo Done!"
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }

    inline = [
      "/bin/echo -e '${random_password.my_passwords.*.result[count.index]}\n${random_password.my_passwords.*.result[count.index]}\n' | /usr/bin/passwd root"
    ]
  }
}

### DO Centos###

resource "digitalocean_droplet" "denisredhat" {
  count              = tonumber(var.zahlen.num_von_vpc)
  image              = "centos-7-x64"
  name               = "${var.dev.names_von_do_vpc.1}.devops.rebrain.srwx.net"
  region             = "fra1"
  size               = "s-1vcpu-1gb"
  private_networking = true
  ssh_keys           = [data.digitalocean_ssh_key.default.fingerprint, digitalocean_ssh_key.default.fingerprint]
  tags               = [digitalocean_tag.erste_tag.id, digitalocean_tag.dritte_tag.id]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "sudo yum -y update", "sudo yum install python3 -y", "echo Done!"
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }

    inline = [
      "/usr/bin/echo -e '${random_password.my_passwords.*.result[count.index]}\n${random_password.my_passwords.*.result[count.index]}\n' | /usr/bin/passwd root"

    ]
  }
}

#### aws records Ubuntu###

data "aws_route53_zone" "rebrain_zone" {
  name = "devops.rebrain.srwx.net"
}

resource "aws_route53_record" "a_records_ubuntu" {
  count   = tonumber(var.zahlen.num_von_vpc)
  zone_id = data.aws_route53_zone.rebrain_zone.zone_id
  name    = "${var.dev.names_von_do_vpc.0}.${data.aws_route53_zone.rebrain_zone.name}"
  type    = "A"
  records = [digitalocean_droplet.denisdebian.*.ipv4_address[count.index]]
  ttl     = "300"
}

resource "aws_route53_record" "www_a_records_ubuntu" {
  count   = tonumber(var.zahlen.num_von_vpc)
  zone_id = data.aws_route53_zone.rebrain_zone.zone_id
  name    = "www.${var.dev.names_von_do_vpc.0}.${data.aws_route53_zone.rebrain_zone.name}"
  type    = "A"

  alias {
    name                   = aws_route53_record.a_records_ubuntu.*.fqdn[count.index]
    zone_id                = data.aws_route53_zone.rebrain_zone.zone_id
    evaluate_target_health = true
  }
}

#### aws records Centos###

resource "aws_route53_record" "a_records_centos" {
  count   = tonumber(var.zahlen.num_von_vpc)
  zone_id = data.aws_route53_zone.rebrain_zone.zone_id
  name    = "${var.dev.names_von_do_vpc.1}.${data.aws_route53_zone.rebrain_zone.name}"
  type    = "A"
  records = [digitalocean_droplet.denisredhat.*.ipv4_address[count.index]]
  ttl     = "300"
}

resource "aws_route53_record" "www_a_records_centos" {
  count   = tonumber(var.zahlen.num_von_vpc)
  zone_id = data.aws_route53_zone.rebrain_zone.zone_id
  name    = "www.${var.dev.names_von_do_vpc.1}.${data.aws_route53_zone.rebrain_zone.name}"
  type    = "A"

  alias {
    name                   = aws_route53_record.a_records_centos.*.fqdn[count.index]
    zone_id                = data.aws_route53_zone.rebrain_zone.zone_id
    evaluate_target_health = true
  }
}

### outputs resoults ip records pass ###

data "template_file" "templatefile_results" {
  template = file("${path.module}/templates/my_result.tpl")
  count    = tonumber(var.zahlen.num_von_vpc)
  vars = {
    num                 = count.index
    my_dns_name_ubuntu  = aws_route53_record.a_records_ubuntu.*.fqdn[count.index]
    my_dns_name_centos  = aws_route53_record.a_records_centos.*.fqdn[count.index]
    my_first_ip_address = digitalocean_droplet.denisdebian.*.ipv4_address[count.index]
    my_second_ip_addres = digitalocean_droplet.denisredhat.*.ipv4_address[count.index]
    my_pass             = random_password.my_passwords.*.result[count.index]
  }
}

resource "local_file" "results" {
  content         = "NN;FQDN;IP-address;Password\n${replace(join(",", data.template_file.templatefile_results.*.rendered), ",", "")}"
  filename        = "${path.module}/outputs_result.csv"
  file_permission = "0660"
}

data "template_file" "templatefile_results_hosts" {
  template = file("${path.module}/templates/results.tpl")
  count    = tonumber(var.zahlen.num_von_vpc)
  vars = {
    results_dns_name_ubuntu   = aws_route53_record.a_records_ubuntu.*.fqdn[count.index]
    results_dns_name_centos   = aws_route53_record.a_records_centos.*.fqdn[count.index]
    results_ip_address_ubuntu = digitalocean_droplet.denisdebian.*.ipv4_address[count.index]
    results_ip_address_centos = digitalocean_droplet.denisredhat.*.ipv4_address[count.index]

  }
}

# Ansible
resource "local_file" "hosts_yml" {
  content         = "all:\n  hosts:\n${replace(join(",", data.template_file.templatefile_results_hosts.*.rendered), ",", "")}"
  filename        = "${path.module}/ansible/inventories/webservers/hosts.yml"
  file_permission = "0664"



  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=${path.module}/ansible/ansible.cfg ansible-playbook ${path.module}/ansible/nginx.yml"
  }
}
