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

echo ''
echo "=============================================="
echo "Build kubernetes v1.23 from source...         "
echo "Takes quite awhile ... patience ... wait ...  "
echo "=============================================="
echo ''

git clone https://github.com/kubernetes/kubernetes
cd kubernetes
make quick-release

echo ''
echo "=============================================="
echo "Done: Build kubernetes v1.23 from source.     "
echo "=============================================="
echo ''

sleep 300
