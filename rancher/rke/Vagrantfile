# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "bootstrap.sh"

  NodeCount = 3

  # Kubernetes Nodes
  (1..NodeCount).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.box = "bento/ubuntu-20.04"
      node.vm.hostname = "node#{i}.example.com"
      node.vm.network "private_network", ip: "172.16.16.10#{i}"
      node.vm.provider "virtualbox" do |v|
        v.name = "node#{i}"
        v.memory = 2048
        v.cpus = 2
      end
    end
  end

end
