#!/bin/bash

echo ''
echo "=============================================="
echo "Configure Firewalld ...                       "
echo "=============================================="
echo ''

Zone=public
# worker nodes
sudo firewall-cmd --zone=$Zone --add-port 10250/tcp --add-port 30000-32767/tcp --permanent
# master nodes
sudo firewall-cmd --zone=$Zone --add-port 6443/tcp --add-port 2379-2380/tcp --add-port 10250-10252/tcp --add-port 10255/tcp --add-port 8472/udp --permanent
# weave net
sudo firewall-cmd --zone=$Zone --add-port 6783-6784/udp --add-port 6781-6783/tcp --permanent
# general
sudo firewall-cmd --add-masquerade --permanent
sudo firewall-cmd --zone=$Zone --permanent --add-service=dns
sudo firewall-cmd --zone=$Zone --permanent --add-service=dhcp
sudo firewall-cmd --zone=$Zone --permanent --add-service=https
sudo firewall-cmd --reload

echo ''
echo "=============================================="
echo "Done: Configure Firewalld.                    "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Check Firewalld ...                           "
echo "=============================================="
echo ''

sudo firewall-cmd --list-ports

echo ''
echo "==============================================" 
echo "Done: Check Firewalld.                        "
echo "=============================================="
echo ''

sleep 5

clear
