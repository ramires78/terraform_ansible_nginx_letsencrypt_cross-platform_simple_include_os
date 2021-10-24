    ${results_dns_name_ubuntu}:
      ansible_ssh_host: ${results_ip_address_ubuntu}
      ansible_ssh_user: root

    ${results_dns_name_centos}:
      ansible_ssh_host: ${results_ip_address_centos}
      ansible_ssh_user: root
