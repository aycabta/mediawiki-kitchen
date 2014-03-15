# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

env_config = YAML.load_file 'config.yml'

VAGRANTFILE_API_VERSION = "2"

#Vagrant::Config.run do |config|
Vagrant::configure("2") do |config|
  case env_config['vagrant']['provider'].to_sym
  when :lxc
    config.vm.box = "lxc-raring"

    config.vm.provider :lxc do |lxc|
      lxc.customize "network.ipv4", "10.0.3.33"
    end
  when :virtualbox
    config.vm.box = "Ubuntu1304"
    config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/raring/current/raring-server-cloudimg-i386-vagrant-disk1.box"
    config.vm.network :private_network, ip: "192.168.3.33"
    config.vm.hostname = "googologolo"
  end
  #config.vm.box = "base"
end

