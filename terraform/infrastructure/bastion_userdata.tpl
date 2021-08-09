#!/bin/sh

# Add Ciphers to SSHD config and restart
echo Ciphers ${ssh_ciphers} | sudo tee -a /etc/ssh/sshd_config
sudo service sshd restart