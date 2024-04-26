#!/bin/bash

# Enable Password Authentication by uncommenting and setting it to 'yes'
sed -i '/^#PasswordAuthentication yes/s/^#//g' /etc/ssh/sshd_config && \
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \

# Allow Root Login with password by uncommenting any PermitRootLogin and setting it to 'yes'
sed -i 's/^#PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
sed -i 's/^PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config && \

# Restart SSH service to apply changes
service ssh restart && \

# Display the current settings for PasswordAuthentication and PermitRootLogin
grep -E 'PasswordAuthentication|PermitRootLogin' /etc/ssh/sshd_config && \

# Verification of SSH Daemon
which sshd && \

# Checking and Managing SSH Service
service ssh status && \

# Check if ports are listening on the system, particularly looking for port 22
ss -tuln | grep 22
