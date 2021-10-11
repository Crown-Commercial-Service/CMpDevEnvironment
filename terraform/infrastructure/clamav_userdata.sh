#!/bin/bash

server_ip=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)

aws ssm put-parameter --name /Environment/ccs/cmp-legacy/CLAMAV_SERVER_ADDRESS --value $server_ip --type String --overwrite --region eu-west-2
aws ssm put-parameter --name /Environment/ccs/cmp-legacy/CLAMAV_SERVER_IP --value $server_ip --type String --overwrite --region eu-west-2
aws ssm put-parameter --name /Environment/ccs/cmp/CLAMAV_SERVER_ADDRESS --value $server_ip --type String --overwrite --region eu-west-2
aws ssm put-parameter --name /Environment/ccs/cmp/CLAMAV_SERVER_IP --value $server_ip --type String --overwrite --region eu-west-2

sudo systemctl enable clamd@scan.service
sudo systemctl start clamd@scan.service
