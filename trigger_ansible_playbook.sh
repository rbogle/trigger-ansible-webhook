#!/bin/sh

playbook="${1:-install}"
hostname="${2:-none}"

/bin/ansible-playbook /etc/ansible/playbooks/$1.yml -l $hostname --extra-vars "install_run=True"  2>&1 >> /var/log/ansible/$hostname.log

