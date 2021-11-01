#!/bin/bash

echo ''
echo "==============================================" 
echo "List Firewalld Zone ...                       "
echo "=============================================="
echo ''

sudo firewall-cmd --list-all-zones | grep -A10 public

echo ''
echo "==============================================" 
echo "Done: List Firewalld Zone.                    "
echo "=============================================="
echo ''

sleep 5

clear
