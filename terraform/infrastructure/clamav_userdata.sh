#!/bin/bash

server_ip=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)

aws ssm put-parameter --name 	/Environment/global/CLAMAV_SERVER_ADDRESS --value $server_ip --type SecureString --overwrite --region eu-west-2
aws ssm put-parameter --name /Environment/global/CLAMAV_SERVER_IP --value $server_ip --type SecureString --overwrite --region eu-west-2

sudo systemctl enable clamd@scan.service
sudo systemctl start clamd@scan.service
