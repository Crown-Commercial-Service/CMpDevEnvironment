#!/bin/sh

echo Ciphers ${ssh_ciphers} | sudo tee -a /etc/ssh/sshd_config
sudo service sshd restart