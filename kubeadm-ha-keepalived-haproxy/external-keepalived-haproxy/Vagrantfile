# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "bootstrap.sh"

  # Load Balancer Nodes
  LoadBalancerCount = 2

  (1..LoadBalancerCount).each do |i|

    config.vm.define "loadbalancer#{i}" do |lb|

      lb.vm.box               = "generic/ubuntu2004"
      lb.vm.box_check_update  = false
      lb.vm.box_version       = "3.3.0"
      lb.vm.hostname          = "loadbalancer#{i}.example.com"

      lb.vm.network "private_network", ip: "172.16.16.5#{i}"

      lb.vm.provider :virtualbox do |v|
        v.name   = "loadbalancer#{i}"
        v.memory = 512
        v.cpus   = 1
      end

      lb.vm.provider :libvirt do |v|
        v.memory  = 512
        v.cpus    = 1
      end

    end

  end


  # Kubernetes Master Nodes
  MasterCount = 3

  (1..MasterCount).each do |i|

    config.vm.define "kmaster#{i}" do |masternode|

      masternode.vm.box               = "generic/ubuntu2004"
      masternode.vm.box_check_update  = false
      masternode.vm.box_version       = "3.3.0"
      masternode.vm.hostname          = "kmaster#{i}.example.com"

      masternode.vm.network "private_network", ip: "172.16.16.10#{i}"

      masternode.vm.provider :virtualbox do |v|
        v.name   = "kmaster#{i}"
        v.memory = 2048
        v.cpus   = 2
      end
    
      masternode.vm.provider :libvirt do |v|
        v.nested  = true
        v.memory  = 2048
        v.cpus    = 2
      end

    end

  end


  # Kubernetes Worker Nodes
  WorkerCount = 1

  (1..WorkerCount).each do |i|

    config.vm.define "kworker#{i}" do |workernode|

      workernode.vm.box               = "generic/ubuntu2004"
      workernode.vm.box_check_update  = false
      workernode.vm.box_version       = "3.3.0"
      workernode.vm.hostname          = "kworker#{i}.example.com"

      workernode.vm.network "private_network", ip: "172.16.16.20#{i}"

      workernode.vm.provider :virtualbox do |v|
        v.name   = "kworker#{i}"
        v.memory = 2048
        v.cpus   = 2
      end

      workernode.vm.provider :libvirt do |v|
        v.nested  = true
        v.memory  = 2048
        v.cpus    = 2
      end

    end

  end

end
