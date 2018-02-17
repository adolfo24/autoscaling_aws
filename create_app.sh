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
echo "Configurando AMI"
ansible-playbook -e 'host_key_checking=False' --private-key alucloud35-keypair.pem node.yml
ami=$(aws ec2 create-image --instance-id $id --name "ICP_AMI_API_$id" --description "API nodejs" --output text)
echo $ami
while true; do
        code=$(aws ec2 describe-images --image-ids $ami --query 'Images[*].[State]' --output text)
        echo "estado de AMI: "$code
        if [ "$code" = "available" ]; then
                break
        fi
        sleep 5
done
echo "ami creada!!"
echo "creando configuracion de autoscaling.."
aws autoscaling create-launch-configuration --launch-configuration-name launch-config-$id --image-id $ami  --instance-type t2.micro --security-groups sg-c171d4b4 --key-name alucloud35-keypair --associate-public-ip-address
echo "creando balanceador de carga.."
aws elbv2 create-load-balancer --name lb-$id --subnets subnet-2bfb6c4f subnet-c2f25afd --scheme internet-facing --security-groups sg-c171d4b4
lb=$(aws elbv2 describe-load-balancers --names lb-$id --query 'LoadBalancers[*].[LoadBalancerArn]' --output text)
echo "creando target group..."
tg=$(aws elbv2 create-target-group --name lb-$id-tg --protocol HTTP --port 8080 --vpc-id vpc-83a213fb --query 'TargetGroups[*].[TargetGroupArn]' --output text)
#registramos las isntancias
echo "Register target group..."
aws elbv2 register-targets --target-group-arn $tg --targets Id=$id
#asignamos tg a lb
echo "creando listener de balanceador de carga..."
aws elbv2 create-listener --load-balancer-arn "$lb" --protocol HTTP --port 8080 --default-actions Type=forward,TargetGroupArn="$tg"
echo "creando grupo de autoescalado..."
aws autoscaling create-auto-scaling-group --auto-scaling-group-name as-group-$id --launch-configuration-name launch-config-$id --min-size 1 --max-size 2 --default-cooldown 120 --target-group-arns $tg --vpc-zone-identifier "subnet-2bfb6c4f,subnet-c2f25afd"
link=$(aws elbv2 describe-load-balancers --names lb-$id --query 'LoadBalancers[*].[DNSName]' --output text)
echo "conectar a: www.$link:8080"