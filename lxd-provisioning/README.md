### Setting up K8s Cluster using LXC/LXD 
This is not a recommended way to create k8s cluster, but for learning and testing purpose we can use this.

```
For running LXC, Create a EC2 instance of t2.medium size which will sufficient for running LXC with 3 nodes, each of 2 CPU's and 2Gi of memory.
```
#### Installing the LXC on Ubuntu 
```
➤ ➤ ADIL ~  sudo apt-get update && apt-get install lxc -y
➤ ➤ ADIL ~  systemctl status lxc
➤ ➤ ADIL ~  lxd init
Provide default option for all excepy these two line:
Name of the storage backend to use (btrfs, dir, lvm) [default=btrfs]: dir
Would you like LXD to be available over the network? (yes/no) [default=no]: yes
```
#### Let's create profile for k8s cluster
```
➤ ➤ ADIL ~  lxc profile copy default k8s
➤ ➤ ADIL ~  lxc profile edit k8s
Copy the config line from file k8s-profile-config and paste
config:
  limits.cpu: "2"
  limits.memory: 2GB
  limits.memory.swap: "false"
  linux.kernel_modules: ip_tables,ip6_tables,netlink_diag,nf_nat,overlay
  raw.lxc: "lxc.apparmor.profile=unconfined\nlxc.cap.drop= \nlxc.cgroup.devices.allow=a\nlxc.mount.auto=proc:rw
    sys:rw"
  security.nesting: "true"
  security.privileged: "true"
➤ ➤ ADIL kubernetes-lxc git:(master)  lxc profile list
+---------+---------+
|  NAME   | USED BY |
+---------+---------+
| default | 0       |
+---------+---------+
| k8s     | 0       |
+---------+---------+
```
#### It's time to create node for k8s cluster
```
➤ ➤ ADIL ~  lxc launch images:centos/7 kmaster --profile k8s
Creating kmaster
Starting kmaster
➤ ➤ ADIL ~  lxc launch images:centos/7 kworker01 --profile k8s
Creating kworker01
Starting kworker01
➤ ➤ ADIL ~  lxc launch images:centos/7 kworker02 --profile k8s
Creating kworker02
Starting kworker02

Note: The naming convention is k8s master node name has to be MASTER keyword in the name and for k8s worker node name  has to be WORKER keyword in the name.
List the node:
➤ ➤ ADIL ~  lxc list
+-----------+---------+-----------------------+----------------------------------------------+------------+-----------+
|   NAME    |  STATE  |         IPV4          |                     IPV6                     |    TYPE    | SNAPSHOTS |
+-----------+---------+-----------------------+----------------------------------------------+------------+-----------+
| kmaster   | RUNNING | 10.127.221.187 (eth0) | fd42:d04d:d3e7:433:216:3eff:fe61:e128 (eth0) | PERSISTENT | 0         |
+-----------+---------+-----------------------+----------------------------------------------+------------+-----------+
| kworker01 | RUNNING | 10.127.221.49 (eth0)  | fd42:d04d:d3e7:433:216:3eff:fef8:af2d (eth0) | PERSISTENT | 0         |
+-----------+---------+-----------------------+----------------------------------------------+------------+-----------+
| kworker02 | RUNNING | 10.127.221.151 (eth0) | fd42:d04d:d3e7:433:216:3eff:fe28:77dc (eth0) | PERSISTENT | 0         |
+-----------+---------+-----------------------+----------------------------------------------+------------+-----------+
```
#### Now, run bootstrap script on all node.
```
It is mandatory on run this bootstrap script on master node first.
➤ ➤ ADIL kubernetes-lxc git:(master)  cat bootstrap-kube.sh | lxc exec kmaster bash
➤ ➤ ADIL kubernetes-lxc git:(master)  cat bootstrap-kube.sh | lxc exec kworker01 bash
➤ ➤ ADIL kubernetes-lxc git:(master)  cat bootstrap-kube.sh | lxc exec kworker02 bash
This will take some time... Just Relax :)

➤ ➤ ADIL kubernetes-lxc git:(master)  lxc list
+-----------+---------+------------------------+----------------------------------------------+------------+-----------+
|   NAME    |  STATE  |          IPV4          |                     IPV6                     |    TYPE    | SNAPSHOTS |
+-----------+---------+------------------------+----------------------------------------------+------------+-----------+
| kmaster   | RUNNING | 172.17.0.1 (docker0)   | fd42:d04d:d3e7:433:216:3eff:fe61:e128 (eth0) | PERSISTENT | 0         |
|           |         | 10.244.0.1 (cni0)      |                                              |            |           |
|           |         | 10.244.0.0 (flannel.1) |                                              |            |           |
|           |         | 10.127.221.187 (eth0)  |                                              |            |           |
+-----------+---------+------------------------+----------------------------------------------+------------+-----------+
| kworker01 | RUNNING | 172.17.0.1 (docker0)   | fd42:d04d:d3e7:433:216:3eff:fef8:af2d (eth0) | PERSISTENT | 0         |
|           |         | 10.244.1.0 (flannel.1) |                                              |            |           |
|           |         | 10.127.221.49 (eth0)   |                                              |            |           |
+-----------+---------+------------------------+----------------------------------------------+------------+-----------+
| kworker02 | RUNNING | 172.17.0.1 (docker0)   | fd42:d04d:d3e7:433:216:3eff:fe28:77dc (eth0) | PERSISTENT | 0         |
|           |         | 10.244.2.0 (flannel.1) |                                              |            |           |
|           |         | 10.127.221.151 (eth0)  |                                              |            |           |
+-----------+---------+------------------------+----------------------------------------------+------------+-----------+
The bootstrap script will deploy flannel for networking.
```
#### Verify the work
##### Exec into kmaster node
```
➤ ➤ ADIL kubernetes-lxc git:(master)  lxc exec kmaster bash
```
#### Verifying Nodes
```
[root@kmaster ~]# kubectl get no
NAME        STATUS   ROLES    AGE     VERSION
kmaster     Ready    master   8m53s   v1.19.2
kworker01   Ready    <none>   5m35s   v1.19.2
kworker02   Ready    <none>   3m39s   v1.19.2
```

#### Verifying cluster version
```
[root@kmaster ~]# kubectl cluster-info
Kubernetes master is running at https://10.127.221.187:6443
KubeDNS is running at https://10.127.221.187:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

#### Let's deploy sample nginx 
```
[root@kmaster ~]# kubectl create deploy nginx --image nginx
deployment.apps/nginx created


[root@kmaster ~]# kubectl get all
NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-6799fc88d8-ng7f8   1/1     Running   0          10s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   10m

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   1/1     1            1           10s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-6799fc88d8   1         1         1       10s
```

#### Creating Service for deployment nginx
```
[root@kmaster ~]# kubectl expose deploy nginx --port 80 --type NodePort
service/nginx exposed

[root@kmaster ~]# kubectl get svc
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1     <none>        443/TCP        11m
nginx        NodePort    10.96.21.25   <none>        80:30310/TCP   4s
```

#### Exec out from kmaster node
```
[root@kmaster ~]# exit
exit

Take any worker node IP's
➤ ➤ ADIL kubernetes-lxc git:(master)  curl -I 10.127.221.49:30310
HTTP/1.1 200 OK
Server: nginx/1.19.3
Date: Mon, 12 Oct 2020 07:56:50 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 29 Sep 2020 14:12:31 GMT
Connection: keep-alive
ETag: "5f7340cf-264"
Accept-Ranges: bytes
```
##### We can access nginx.. !!!

#### To access k8s cluster without execing into kmaster node

##### Download the kubectl command into your local, I have already present..!
```
➤ ➤ ADIL kubernetes-lxc git:(master)  which kubectl
/usr/bin/kubectl
```
##### Create .kube directory
```
➤ ➤ ADIL kubernetes-lxc git:(master)  mkdir ~/.kube
```
##### copy config from kmaster into .kube directory
```
➤ ➤ ADIL kubernetes-lxc git:(master)  lxc file pull kmaster/etc/kubernetes/admin.conf ~/.kube/config
➤ ➤ ADIL .kube  ll ~/.kube
total 8
-rw------- 1 root root 5570 Oct 12 08:05 config
```
##### Try to access k8s cluster without execing into kmaster node.
```
➤ ➤ ADIL .kube  kubectl get no
NAME        STATUS   ROLES    AGE   VERSION
kmaster     Ready    master   23m   v1.19.2
kworker01   Ready    <none>   19m   v1.19.2
kworker02   Ready    <none>   17m   v1.19.2
```
