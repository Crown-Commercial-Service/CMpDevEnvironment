#!/bin/sh
# Update ssh ciphers and restart ssh service
echo Ciphers ${ssh_ciphers} | tee -a /etc/ssh/sshd_config
echo KexAlgorithms ${ssh_keyexchange_algorithms} | tee -a /etc/ssh/sshd_config
echo MACs ${ssh_mac_algorithms} | tee -a /etc/ssh/sshd_config
systemctl restart sshd
