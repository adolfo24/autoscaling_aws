#!/bin/bash
id=$(aws ec2 run-instances --image-id ami-841f46ff --key-name alucloud35-keypair --security-group-ids sg-c171d4b4 --instance-type t2.micro --subnet-id subnet-2bfb6c4f --query 'Instances[*].[InstanceId]' --output text)
echo $id
while true; do
        code=$(aws ec2 describe-instance-status --instance-ids $id --query 'InstanceStatuses[*].InstanceStatus.[Status]' --output text)
        echo $code
        if [ "$code" = "ok" ]; then
                dns=$(aws ec2 describe-instances --instance-ids $id --query 'Reservations[*].Instances[*].[PublicDnsName]' --output text)
                echo $dns
                break
        fi
        sleep 8
done

sudo echo -e "[webserver]\n$dns">/etc/ansible/hosts
sudo echo -e "module.exports={IP_DATABASE:'$dns'}">config.js
ansible-playbook -e 'host_key_checking=False' --private-key alucloud35-keypair.pem mongodb.yml