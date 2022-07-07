#!/bin/sh

# Install jq
yum install jq -y

# Update ssh ciphers and restart ssh service
echo Ciphers ${ssh_ciphers} | sudo tee -a /etc/ssh/sshd_config
systemctl restart sshd

# Associate elastic ip to instance
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
region=eu-west-2
allocation_id=$(aws ssm get-parameter --name /eip/allocation-id --region $region | jq -r '.Parameter.Value')

aws ec2 associate-address --instance-id $instance_id --allocation-id $allocation_id --allow-reassociation --region $region
