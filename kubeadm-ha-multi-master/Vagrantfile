# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "bootstrap.sh"

  # Load Balancer Node
  config.vm.define "loadbalancer" do |lb|
    lb.vm.box = "bento/ubuntu-20.04"
    lb.vm.hostname = "loadbalancer.example.com"
    lb.vm.network "private_network", ip: "172.16.16.100"
    lb.vm.provider "virtualbox" do |v|
      v.name = "loadbalancer"
      v.memory = 1024
      v.cpus = 1
    end
  end

  MasterCount = 2

  # Kubernetes Master Nodes
  (1..MasterCount).each do |i|
    config.vm.define "kmaster#{i}" do |masternode|
      masternode.vm.box = "bento/ubuntu-20.04"
      masternode.vm.hostname = "kmaster#{i}.example.com"
      masternode.vm.network "private_network", ip: "172.16.16.10#{i}"
      masternode.vm.provider "virtualbox" do |v|
        v.name = "kmaster#{i}"
        v.memory = 2048
        v.cpus = 2
      end
    end
  end

  NodeCount = 1

  # Kubernetes Worker Nodes
  (1..NodeCount).each do |i|
    config.vm.define "kworker#{i}" do |workernode|
      workernode.vm.box = "bento/ubuntu-20.04"
      workernode.vm.hostname = "kworker#{i}.example.com"
      workernode.vm.network "private_network", ip: "172.16.16.20#{i}"
      workernode.vm.provider "virtualbox" do |v|
        v.name = "kworker#{i}"
        v.memory = 1024
        v.cpus = 1
      end
    end
  end

end
