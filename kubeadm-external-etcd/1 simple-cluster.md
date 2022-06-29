
## On all etcd nodes

> Perform all commands logged in as **root** user or prefix each command with **sudo** as appropriate

##### Download etcd & etcdctl binaries from Github
```
{
  ETCD_VER=v3.5.1
  wget -q --show-progress "https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz"
  tar zxf etcd-v3.5.1-linux-amd64.tar.gz
  mv etcd-v3.5.1-linux-amd64/etcd* /usr/local/bin/
  rm -rf etcd*
}
```

##### Create systemd unit file for etcd service
> Set NODE_IP to the correct IP of the machine where you are running this
```
NODE_IP="172.16.16.221"

ETCD_NAME=$(hostname -s)

ETCD1_IP="172.16.16.221"
ETCD2_IP="172.16.16.222"
ETCD3_IP="172.16.16.223"


cat <<EOF >/etc/systemd/system/etcd.service
[Unit]
Description=etcd

[Service]
Type=exec
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --initial-advertise-peer-urls http://${NODE_IP}:2380 \\
  --listen-peer-urls http://${NODE_IP}:2380 \\
  --advertise-client-urls http://${NODE_IP}:2379 \\
  --listen-client-urls http://${NODE_IP}:2379,http://127.0.0.1:2379 \\
  --initial-cluster-token etcd-cluster-1 \\
  --initial-cluster etcd1=http://${ETCD1_IP}:2380,etcd2=http://${ETCD2_IP}:2380,etcd3=http://${ETCD3_IP}:2380 \\
  --initial-cluster-state new
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

##### Enable and Start etcd service
```
{
  systemctl daemon-reload
  systemctl enable --now etcd
}
```

##### Verify Etcd cluster status
> In any one of the etcd nodes
```
ETCDCTL_API=3 etcdctl --endpoints=http://127.0.0.1:2379 member list
```
