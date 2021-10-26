lxc storage create containerd dir
lxc storage volume create containerd kmaster
lxc storage volume create containerd kworker1
lxc storage volume create containerd kworker2
lxc config device add kmaster  containerd disk pool=containerd source=kmaster  path=/var/lib/containerd
lxc config device add kworker1 containerd disk pool=containerd source=kworker1 path=/var/lib/containerd
lxc config device add kworker2 containerd disk pool=containerd source=kworker2 path=/var/lib/containerd

lxc storage create kubelet dir
lxc storage volume create kubelet kmaster
lxc storage volume create kubelet kworker1
lxc storage volume create kubelet kworker2
lxc config device add kmaster  kubelet disk pool=kubelet source=kmaster  path=/var/lib/kubelet
lxc config device add kworker1 kubelet disk pool=kubelet source=kworker1 path=/var/lib/kubelet
lxc config device add kworker2 kubelet disk pool=kubelet source=kworker2 path=/var/lib/kubelet

lxc storage create docker dir
lxc storage volume create docker kmaster
lxc storage volume create docker kworker1
lxc storage volume create docker kworker2
lxc config device add kmaster  docker disk pool=docker source=kmaster  path=/var/lib/docker
lxc config device add kworker1 docker disk pool=docker source=kworker1 path=/var/lib/docker
lxc config device add kworker2 docker disk pool=docker source=kworker2 path=/var/lib/docker

