#!/bin/bash

# Update hosts file
echo "[TASK 1] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
172.42.42.101 node1
172.42.42.102 node2
172.42.42.103 node3
172.42.42.104 node4
EOF

# Enable ssh password authentication
echo "[TASK 2] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Enable root ssh login
echo "[TASK 3] Enable ssh root login"
sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

systemctl reload sshd

# Set Root password
echo "[TASK 4] Set root password"
echo root:kubeadmin | chpasswd


