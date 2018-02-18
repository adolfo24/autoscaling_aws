#!/bin/bash
id=i-014d53ba18f9e1425
ami=$(aws ec2 create-image --instance-id $id --name "ICP_AMI_API_$id" --description "API nodejs" --output text)
echo $ami
while true; do
        code=$(aws ec2 describe-images --image-ids $ami --query 'Images[*].[State]' --output text)
        echo $code
        if [ "$code" = "available" ]; then
                break
        fi
        sleep 5
done
echo "ami creada!!"
