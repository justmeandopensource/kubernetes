#!/bin/bash
#
#    Copyright 2015-2021 Gilbert Standen
#    This file is part of Orabuntu-LXC.

#    Orabuntu-LXC is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    Orabuntu-LXC is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Orabuntu-LXC.  If not, see <http://www.gnu.org/licenses/>.

#    v2.4 		GLS 20151224
#    v2.8 		GLS 20151231
#    v3.0 		GLS 20160710 Updates for Ubuntu 16.04
#    v4.0 		GLS 20161025 DNS DHCP services moved into an LXC container
#    v5.0 		GLS 20170909 Orabuntu-LXC Multi-Host
#    v6.0-AMIDE-beta	GLS 20180106 Orabuntu-LXC AmazonS3 Multi-Host Docker Enterprise Edition (AMIDE)
#    v7.0-ELENA-beta    GLS 20210428 Enterprise LXD Edition New AMIDE

#    Note that this software builds a containerized DNS DHCP solution (bind9 / isc-dhcp-server).
#    The nameserver should NOT be the name of an EXISTING nameserver but an arbitrary name because this software is CREATING a new LXC-containerized nameserver.
#    The domain names can be arbitrary fictional names or they can be a domain that you actually own and operate.
#    There are two domains and two networks because the "seed" LXC containers are on a separate network from the production LXC containers.
#    If the domain is an actual domain, you will need to change the subnet using the subnets feature of Orabuntu-LXC

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
scp ubuntu@10.209.53.1:/home/ubuntu/Downloads/orabuntu-lxc-master/rpmstage/python-six-1.9.0-2.el7.noarch.rpm .
rpm -ivh python-six-1.9.0-2.el7.noarch.rpm 
rpm -ivh openvswitch-*.rpm
cd /usr/local/etc
mkdir openvswitch
ovsdb-tool create /usr/local/etc/openvswitch/conf.db
systemctl enable openvswitch.service
systemctl start  openvswitch.service
ls -l /usr/local/etc/openvswitch/conf.db

