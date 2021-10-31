yum-config-manager --set-enabled powertools
yum -y install checkpolicy selinux-policy-devel unbound-devel
yum -y install python3-sphinx
yum -y install gcc-c++ groff libcap-ng-devel python3-devel unbound
yum -y install network-scripts libreswan
yum -y install python
dnf -y install python3
dnf -y install python3-sphinx
yum -y install python-six
yum -y install yum-utils
yum -y install scl-utils
yum -y install centos-release-scl
yum -y install python27
scp ubuntu@10.207.39.1:/home/ubuntu/Downloads/orabuntu-lxc-master/rpmstage/python-six-1.9.0-2.el7.noarch.rpm .
rpm -ivh python-six-1.9.0-2.el7.noarch.rpm 
rpm -ivh openvswitch-*.rpm
cd /usr/local/etc
mkdir openvswitch
ovsdb-tool create /usr/local/etc/openvswitch/conf.db
systemctl enable openvswitch.service
systemctl start  openvswitch.service
ls -l /usr/local/etc/openvswitch/conf.db

