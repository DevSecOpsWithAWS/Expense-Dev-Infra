#!/bin/bash
ENVIRONMENT=$1
dnf install ansible -y

#push

#ansible-playbook -i inventory mysql.yaml

#pull

ansible-pull -i localhost, -U https://github.com/DevSecOpsWithAWS/Expanse-Ansible-Roles-tf.git main.yaml -e COMPONENT=frontend -e ENVIRONMENT=$1


