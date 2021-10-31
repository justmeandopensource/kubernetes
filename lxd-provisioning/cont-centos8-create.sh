lxc profile create k8s-weavenet
cat k8s-profile-config-weavenet | lxc profile edit k8s-weavenet

lxc init images:centos/8/amd64 kmaster --profile k8s-weavenet
lxc start kmaster
lxc stop  kmaster
cp ifcfg-eth0-kmaster ifcfg-eth0
lxc file push ifcfg-eth0 kmaster/etc/sysconfig/network-scripts/
lxc start kmaster

lxc init images:centos/8/amd64 kworker1 --profile k8s-weavenet
lxc start kworker1
lxc stop  kworker1
cp ifcfg-eth0-kworker1 ifcfg-eth0
lxc file push ifcfg-eth0 kworker1/etc/sysconfig/network-scripts/
lxc start kworker1

lxc init images:centos/8/amd64 kworker2 --profile k8s-weavenet
lxc start kworker2
lxc stop  kworker2
cp ifcfg-eth0-kworker2 ifcfg-eth0
lxc file push ifcfg-eth0 kworker2/etc/sysconfig/network-scripts/
lxc start kworker2

sleep 15

lxc exec kmaster --  dnf -y install openssh-server net-tools bind-utils
lxc exec kworker1 -- dnf -y install openssh-server net-tools bind-utils
lxc exec kworker2 -- dnf -y install openssh-server net-tools bind-utils

lxc exec kmaster --  systemctl enable sshd
lxc exec kworker1 -- systemctl enable sshd
lxc exec kworker2 -- systemctl enable sshd

lxc exec kmaster --  service sshd start
lxc exec kworker1 -- service sshd start
lxc exec kworker2 -- service sshd start

lxc exec kmaster  -- usermod --password `perl -e "print crypt('root','root');"` root
lxc exec kworker1 -- usermod --password `perl -e "print crypt('root','root');"` root
lxc exec kworker2 -- usermod --password `perl -e "print crypt('root','root');"` root
