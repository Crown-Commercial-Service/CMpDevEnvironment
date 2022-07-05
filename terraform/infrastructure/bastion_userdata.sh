#!/bin/sh

# Update ssh ciphers and restart ssh service
echo Ciphers ${ssh_ciphers} | sudo tee -a /etc/ssh/sshd_config
systemctl restart sshd

# Associate elastic ip to instance
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
allocation_id=eipalloc-0baf119ca82747098
region=eu-west-2

aws ec2 associate-address --instance-id $instance_id --allocation-id $allocation_id --allow-reassociation --region $region
