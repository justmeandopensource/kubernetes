### Setting up K8s Cluster using LXC/LXD 
> **Note:** For development purpose and not recommended for Production use

#### In case you want to use an AWS EC2 instance
Create an EC2 instance of type t2.medium size which will be sufficient for running 3 lxc containers each with 2 CPUs and 2Gi of memory.

#### Installing the LXC on Ubuntu 
```
$ sudo apt-get update && sudo apt-get install lxc -y
$ sudo systemctl status lxc
$ lxd init
```
**Provide default option for all except this:**

Name of the storage backend to use (btrfs, dir, lvm) [default=btrfs]: dir

#### Let's create profile for k8s cluster
Make sure to clone this repo and run these commands moving into lxd-provisioning directory
```
$ lxc profile create k8s
$ cat k8s-profile-config | lxc profile edit k8s
$ lxc profile list
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
$ lxc launch ubuntu:20.04 kmaster --profile k8s
Creating kmaster
Starting kmaster

$ lxc launch ubuntu:20.04 kworker1 --profile k8s
Creating kworker1
Starting kworker1

$ lxc launch ubuntu:20.04 kworker2 --profile k8s
Creating kworker2
Starting kworker2
```
> **Note:** The naming convention is k8s master node name has to have **master** keyword in the name and for k8s worker nodes **worker** keyword in the name.
```
$ lxc list
+-----------+---------+-----------------------+----------------------------------------------+------------+-----------+
|   NAME    |  STATE  |         IPV4          |                     IPV6                     |    TYPE    | SNAPSHOTS |
+-----------+---------+-----------------------+----------------------------------------------+------------+-----------+
| kmaster   | RUNNING | 10.127.221.187 (eth0) | fd42:d04d:d3e7:433:216:3eff:fe61:e128 (eth0) | PERSISTENT | 0         |
+-----------+---------+-----------------------+----------------------------------------------+------------+-----------+
| kworker1  | RUNNING | 10.127.221.49 (eth0)  | fd42:d04d:d3e7:433:216:3eff:fef8:af2d (eth0) | PERSISTENT | 0         |
+-----------+---------+-----------------------+----------------------------------------------+------------+-----------+
| kworker2  | RUNNING | 10.127.221.151 (eth0) | fd42:d04d:d3e7:433:216:3eff:fe28:77dc (eth0) | PERSISTENT | 0         |
+-----------+---------+-----------------------+----------------------------------------------+------------+-----------+
```
#### Now, run bootstrap script on all node.
It is mandatory to run this bootstrap script on master node first.
```
$ cat bootstrap-kube.sh | lxc exec kmaster bash
$ cat bootstrap-kube.sh | lxc exec kworker1 bash
$ cat bootstrap-kube.sh | lxc exec kworker2 bash

$ lxc list
+-----------+---------+------------------------+----------------------------------------------+------------+-----------+
|   NAME    |  STATE  |          IPV4          |                     IPV6                     |    TYPE    | SNAPSHOTS |
+-----------+---------+------------------------+----------------------------------------------+------------+-----------+
| kmaster   | RUNNING | 172.17.0.1 (docker0)   | fd42:d04d:d3e7:433:216:3eff:fe61:e128 (eth0) | PERSISTENT | 0         |
|           |         | 10.244.0.1 (cni0)      |                                              |            |           |
|           |         | 10.244.0.0 (flannel.1) |                                              |            |           |
|           |         | 10.127.221.187 (eth0)  |                                              |            |           |
+-----------+---------+------------------------+----------------------------------------------+------------+-----------+
| kworker1  | RUNNING | 172.17.0.1 (docker0)   | fd42:d04d:d3e7:433:216:3eff:fef8:af2d (eth0) | PERSISTENT | 0         |
|           |         | 10.244.1.0 (flannel.1) |                                              |            |           |
|           |         | 10.127.221.49 (eth0)   |                                              |            |           |
+-----------+---------+------------------------+----------------------------------------------+------------+-----------+
| kworker2  | RUNNING | 172.17.0.1 (docker0)   | fd42:d04d:d3e7:433:216:3eff:fe28:77dc (eth0) | PERSISTENT | 0         |
|           |         | 10.244.2.0 (flannel.1) |                                              |            |           |
|           |         | 10.127.221.151 (eth0)  |                                              |            |           |
+-----------+---------+------------------------+----------------------------------------------+------------+-----------+
```
The bootstrap script will deploy flannel for networking.

#### Verify
##### Exec into kmaster node
```
$ lxc exec kmaster bash
```
#### Verifying Nodes
```
$ kubectl get nodes
NAME        STATUS   ROLES    AGE     VERSION
kmaster     Ready    master   8m53s   v1.19.2
kworker1   Ready    <none>   5m35s   v1.19.2
kworker2   Ready    <none>   3m39s   v1.19.2
```

#### Verifying cluster version
```
$ kubectl cluster-info
Kubernetes master is running at https://10.127.221.187:6443
KubeDNS is running at https://10.127.221.187:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

#### Let's deploy sample nginx 
```
$ kubectl create deploy nginx --image nginx
deployment.apps/nginx created

$ kubectl get all
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
$ kubectl expose deploy nginx --port 80 --type NodePort
service/nginx exposed

$ kubectl get service
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1     <none>        443/TCP        11m
nginx        NodePort    10.96.21.25   <none>        80:30310/TCP   4s
```

#### Exit out from kmaster node
```
$ exit
```
#### Try accessing Nginx through any of the worker node's IP address
```
$ curl -I 10.127.221.49:30310
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
$ which kubectl
/usr/bin/kubectl
```
##### Create .kube directory
```
$ mkdir ~/.kube
```
##### copy config from kmaster into .kube directory
```
$ lxc file pull kmaster/etc/kubernetes/admin.conf ~/.kube/config
$ ls -l ~/.kube
total 8
-rw------- 1 root root 5570 Oct 12 08:05 config
```
##### Try to access k8s cluster without execing into kmaster node.
```
$ kubectl get nodes
NAME        STATUS   ROLES    AGE   VERSION
kmaster     Ready    master   23m   v1.19.2
kworker01   Ready    <none>   19m   v1.19.2
kworker02   Ready    <none>   17m   v1.19.2
```
