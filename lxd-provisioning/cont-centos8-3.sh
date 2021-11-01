#!/bin/bash

echo ''
echo "==============================================" 
echo "Enable Docker ...                             "
echo "=============================================="
echo ''

systemctl daemon-reload
systemctl enable docker --now

echo ''
echo "==============================================" 
echo "Done: Enable Docker.                          "
echo "=============================================="
echo ''

sleep 5

clear
