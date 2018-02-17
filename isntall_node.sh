#!/bin/bash

sudo echo -e "[webserver]\nec2-34-200-241-198.compute-1.amazonaws.com">/etc/ansible/hosts
#ansible-playbook --private-key alucloud35-keypair.pem mongodb.yml
ansible-playbook --private-key alucloud35-keypair.pem node.yml