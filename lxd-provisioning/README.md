# K8s LXD-containerized CentOS 8 on Oracle Linux 8.4 UEK Host

The EXCELLENT guide here:

https://www.golinuxcloud.com/install-kubernetes-cluster-kubeadm-centos-8/

was my primary reference for this build on Oracle Linux 8.  The above guide uses VM/bare metal. I have adapted it for LXD containers.

The LXD HOST server information:

Linux o83sv3 5.4.17-2102.205.7.3.el8uek.x86_64 #2 SMP
Oracle Linux Server release 8.4

Note 1: The Oracle Linux 8 host server is "default install" "out-of-the-box" "vanilla" Oracle Linux 8 host using XFS for the root FS.

Note 2: As regards running the LXD containers on a host directory that uses XFS it is required that the XFS was created ftype=1:
```
[ubuntu@o83sv3 ]$  xfs_info / | grep ftype
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
```
Note 3: The fstype=1 is a requirement for docker to be able to use overlay2 (of the older overlay).

Step 0:  Prepare the LXD k8s containers using the scripts in my fork here:

https://github.com/gstanden/kubernetes/tree/master/lxd-provisioning

Get the master.zip or clone my fork and then use this script to push the required scripts to kmaster, kworker1, and kworker2.
```
[ubuntu@o83sv3 lxd-provisioning]$ cat cont-centos8-push.sh 
lxc file push cont-centos8-[0123456].sh kmaster/root/
lxc file push cont-centos8-[012346].sh kworker1/root/
lxc file push cont-centos8-[012346].sh kworker2/root/
```
The cont-centos8-0.sh file is shown below.
```
[ubuntu@o83sv3 lxd-provisioning]$ cat cont-centos8-0.sh
/root/cont-centos8-1.sh
/root/cont-centos8-2.sh
/root/cont-centos8-3.sh
/root/cont-centos8-4.sh
/root/cont-centos8-6.sh
```
The only script that is not run on each node is the cont-centos8-5.sh script which is the script that is used to run "kubeadm --init".  
Currently that is run manually one line at a time but it will be put into the orabuntu-lxc automation also.

A needed "secret sauce" is from this EXCELLENT post from Claudio Kuenzler (and shared on LinkedIn by Efstathios Efstathio TY both !! )

https://www.claudiokuenzler.com/blog/1106/unable-to-deploy-rancher-managed-kubernetes-cluster-lxc-lxd-nodes

So the kube-proxy containers will NOT run correctly on these newer kernels such as Oracle Linux UEK 5.x kernels unless you are using the kubernetes 1.23+ versions. Consequently the CoreDNS containers will remain stuck at "ContainerCreating" as well.  

A quick check of the kubernetes github shows that the code needed for the kube-proxy fix as discussed in the post by Claudio is only in master as of today (October 30, 2021).

Therefore I built the required kubernetes binaries from the kubernetes github source code as described here:

https://github.com/kubernetes/kubernetes

Step 1:  Install docker-ce on the LXD HOST server (in this example: Linux o83sv3 5.4.17-2102.205.7.3.el8uek.x86_64 #2 SMP)

Note 1:  This is all done so that the kubernetes binaries can be built from the cloned kubernetes github.

Note 2:  So this step is simply getting docker-ce installed on the LXD HOST server.

Note 3:  It would be far simpler to install docker from the Canonical snap. (note to self: try build using docker snap alternatively)
```
[ubuntu@o83sv3 ]$  sudo dnf -y install yum-utils device-mapper-persistent-data lvm2 
[ubuntu@o83sv3 ]$  sudo dnf -y install iproute-tc net-tools openssh-server perl
[ubuntu@o83sv3 ]$  sudo dnf -y remove runc
[ubuntu@o83sv3 ]$  sudo  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
[ubuntu@o83sv3 ]$  sudo dnf -y install containerd.io docker-ce docker-ce-cli
[ubuntu@o83sv3 ]$  sudo systemctl enable docker
[ubuntu@o83sv3 ]$  sudo service docker start
[ubuntu@o83sv3 ]$  sudo service docker status
```
Step 2:  Clone the kubernetes repo from github

Note 1:  Following the steps as described here: https://github.com/kubernetes/kubernetes

Note 2:  https://github.com/kubernetes/kubernetes > (scroll to) > To start developing K8s > (scroll to) > You have a working Docker environment.
```
git clone https://github.com/kubernetes/kubernetes
cd kubernetes
make quick-release
```
Note 3:  The "make quick-release" is actually not very quick on Lenovo P72 Mobile Workstation. I'd say it took 5 minutes or so, just a guess.

Note 4:  This Lenovo workstation has 128 GB RAM and Intel® Core™ i7-8750H CPU @ 2.20GHz × 12.

Note 5:  (note to self: try using "-j8" on it or other method to make it a bit faster). 

Step 3:  Find the newly-built kubernetes binaries that are needed

Note 1:  The binaries that are needed for the kubernete init are "kubeadm, kubectl, and kubelet").
```
lxc exec kmaster bash
cd /
[root@kmaster ~]# sudo find . -name kubeadm
[root@kmaster ~]# sudo find . -name kubelet
[root@kmaster ~]# sudo find . -name kubectl
```
These binaries which are of the 1.23 version level which have just been built above will be found in locations such as these:

(still in the "kubernetes" directory of the github clone)
```
mkdir orabuntu-lxc
cd orabuntu-lxc/
```
Note 2:  Now for example after finding the kubectl as described above, copy it to the orabuntu-lxc subdirectory.

Note 3:  This step is just so that all three required kubernetes binaries are in the same "staging directory"

Note 4:  The binaries are created in serveral subdirectories but are exactly the same binaries.  Verify using diff as shown below for example.

Note 5:  Then put the three needed version 1.23 kubernetes binaries in the "orabuntu-lxc" staging directory (or any other staging location)

```
[ubuntu@o83sv3 kubernetes]$ find . -name kubeadm
./cmd/kubeadm
./cmd/kubeadm/app/apis/kubeadm
./_output/dockerized/bin/linux/amd64/kubeadm
./_output/release-stage/node/linux-amd64/kubernetes/node/bin/kubeadm
./_output/release-stage/server/linux-amd64/kubernetes/server/bin/kubeadm
./orabuntu-lxc/kubeadm
[ubuntu@o83sv3 kubernetes]$ find . -name kubectl
./cmd/kubectl
./pkg/kubectl
./staging/src/k8s.io/kubectl
./staging/src/k8s.io/kubectl/pkg/util/i18n/translations/kubectl
./test/e2e/framework/kubectl
./test/e2e/kubectl
./test/e2e/testing-manifests/kubectl
./test/fixtures/pkg/kubectl
./vendor/k8s.io/kubectl
./_output/dockerized/bin/linux/amd64/kubectl
./_output/release-stage/client/linux-amd64/kubernetes/client/bin/kubectl
./_output/release-stage/node/linux-amd64/kubernetes/node/bin/kubectl
./_output/release-stage/server/linux-amd64/kubernetes/server/bin/kubectl
./_output/release-stage/test/kubernetes/test/e2e/testing-manifests/kubectl
./orabuntu-lxc/kubectl
[ubuntu@o83sv3 kubernetes]$ find . -name kubelet
./cmd/kubeadm/app/phases/kubelet
./cmd/kubelet
./pkg/kubelet
./staging/src/k8s.io/kubelet
./test/e2e/framework/kubelet
./test/instrumentation/testdata/pkg/kubelet
./test/integration/kubelet
./vendor/k8s.io/kubelet
./_output/dockerized/bin/linux/amd64/kubelet
./_output/release-stage/node/linux-amd64/kubernetes/node/bin/kubelet
./_output/release-stage/server/linux-amd64/kubernetes/server/bin/kubelet
./orabuntu-lxc/kubelet
[ubuntu@o83sv3 kubernetes]$ diff ./_output/release-stage/client/linux-amd64/kubernetes/client/bin/kubectl ./_output/release-stage/node/linux-amd64/kubernetes/node/bin/kubectl
[ubuntu@o83sv3 kubernetes]$ diff ./_output/release-stage/node/linux-amd64/kubernetes/node/bin/kubectl ./_output/release-stage/server/linux-amd64/kubernetes/server/bin/kubectl
[ubuntu@o83sv3 kubernetes]$ cd orabuntu-lxc
[ubuntu@o83sv3 orabuntu-lxc]$ cp -p .././_output/release-stage/node/linux-amd64/kubernetes/node/bin/kubectl .
[ubuntu@o83sv3 orabuntu-lxc]$ cp -p .././_output/release-stage/server/linux-amd64/kubernetes/server/bin/kubeadm .
[ubuntu@o83sv3 orabuntu-lxc]$ cp -p .././_output/release-stage/server/linux-amd64/kubernetes/server/bin/kubelet .
[ubuntu@o83sv3 orabuntu-lxc]$ 
```
All three required v1.23.x kubernetes binaries are now staged in the "orabuntu-lxc"directory.
```
[ubuntu@o83sv3 orabuntu-lxc]$ ls -lrt
total 206840
-rwxr-xr-x. 1 ubuntu ubuntu  45924352 Oct 30 09:54 kubectl
-rwxr-xr-x. 1 ubuntu ubuntu 121376192 Oct 30 09:55 kubelet
-rwxr-xr-x. 1 ubuntu ubuntu  44503040 Oct 30 09:55 kubeadm
```
Note: When running "kubeadm init" the correct version of the built kubernetes binaries needs to be passed explicitly to kubeadm.
```
[root@kmaster ~]# kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"23+", GitVersion:"v1.23.0-alpha.3.679+08bf54678e2bef", ... 
[root@kmaster ~]# 
```
A quick test shows that what is needed for the "kubeadm init" --kubernetes-version parameter is abbreviated version info as show below.
```
[root@kmaster ~]# kubeadm init --kubernetes-version=v1.23.0-alpha.3
```


### Setting up K8s Cluster using LXC/LXD 
> **Note:** For development purpose and not recommended for Production use

#### In case you want to use an AWS EC2 instance
Create an EC2 instance of type t2.medium size which will be sufficient for running 3 lxc containers each with 2 CPUs and 2Gi of memory.

#### Installing the LXC on Ubuntu 
```
$ sudo apt-get update && apt-get install lxc -y
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
$ lxc launch ubuntu:21.04 kmaster --profile k8s
Creating kmaster
Starting kmaster

$ lxc launch ubuntu:21.04 kworker1 --profile k8s
Creating kworker1
Starting kworker1

$ lxc launch ubuntu:21.04 kworker2 --profile k8s
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
