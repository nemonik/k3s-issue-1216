# -*- mode: ruby -*-
# vi: set ft=ruby :

$VERBOSE = nil

# Copyright (C) 2019 Michael Joseph Walsh - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the the license.
#
# You should have received a copy of the license with
# this file. If not, please email <mjwalsh@nemonik.com>

# Vagrant will start at your current path and then move upward looking
# for a Vagrant file.  The following will provide the path for the found
# Vagrantfile, so you can execute `vagrant` commands on the command-line
# anywhere in the project a Vagrantfile doesn't already exist.

# Used to hold all the ANSIBLE_EXTRA_VARS and provide convienance methods
require File.join(File.dirname(__FILE__), 'ansible_extra_vars.rb')

Vagrant.configure('2') do |config|

  # use the default insecure key
  config.ssh.insert_key = false

  ## Provision the k3s server vagrant
  config.vm.define 'server' do |server|
    server.vm.box = 'centos/7'
    server.vm.network :private_network, ip: '192.168.0.11'
    server.vm.hostname = 'server'
    server.vm.synced_folder '.', '/vagrant', type: 'virtualbox', owner: "vagrant", group: "vagrant", mount_options: ["dmode=775,fmode=664"]
    server.vm.provider :virtualbox do |virtualbox|
      virtualbox.name = 'k3s server'
      virtualbox.customize ['guestproperty', 'set', :id, '/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold', 10]
      virtualbox.memory = 4096
      virtualbox.cpus = 4
      virtualbox.gui = false
    end

    ansible_extra_vars_string = AnsibleExtraVars::as_string()

    # Needed to install Ansible locally vice using Vagrant ansible_local provisioner

    # run as root
    config.vm.provision "shell", inline: <<-SHELL
      yum install -y epel-release
      yum install -y python-pip
      pip install --upgrade pip
    SHELL

    # run as vagrant user
    config.vm.provision "shell", privileged: false, inline: <<-SHELL
      pip install --user ansible==#{AnsibleExtraVars::ANSIBLE_EXTRA_VARS[:ansible_version]} paramiko
    SHELL

    # Configure the rest via Ansible

    server.vm.provision "shell", privileged: false, reset: true, inline: <<-SHELL
      echo Configuring k3s server...
      echo "cd /vagrant && PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true /home/vagrant/.local/bin/ansible-playbook -e 'ansible_python_interpreter=/usr/bin/python' --limit="servers" --inventory-file=hosts --extra-vars=#{ansible_extra_vars_string} -vvvv ansible/server-playbook.yml"
      cd /vagrant && PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true /home/vagrant/.local/bin/ansible-playbook -e 'ansible_python_interpreter=/usr/bin/python' --limit="servers" --inventory-file=hosts --extra-vars=#{ansible_extra_vars_string} -vvvv ansible/server-playbook.yml
    SHELL

  end

  ## Provision k3s agent vagrant
  config.vm.define "agent" do |agent|
    agent.vm.box = 'centos/7'
    agent.vm.network :private_network, ip: '192.168.0.10'
    agent.vm.hostname = 'agent'
    agent.vm.synced_folder '.', '/vagrant', type: 'virtualbox', owner: "vagrant", group: "vagrant", mount_options: ["dmode=775,fmode=664"]
    agent.vm.provider :virtualbox do |virtualbox|
      virtualbox.name = 'k3s agent'
      virtualbox.customize ['guestproperty', 'set', :id, '/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold', 10]
      virtualbox.memory = 2048
      virtualbox.cpus = 2
      virtualbox.gui = false
    end

    ssh_insecure_key = File.read("#{Dir.home}/.vagrant.d/insecure_private_key")

    ansible_extra_vars_string = AnsibleExtraVars::as_string()

    # Needed to install Ansible locally vice using Vagrant ansible_local provisioner

    # run as root
    config.vm.provision "shell", inline: <<-SHELL
      yum install -y epel-release
      yum install -y python-pip
      pip install --upgrade pip
    SHELL

    # run as vagrant user
    config.vm.provision "shell", privileged: false, inline: <<-SHELL
      pip install --user ansible==#{AnsibleExtraVars::ANSIBLE_EXTRA_VARS[:ansible_version]} paramiko
    SHELL

    # Configure the rest via Ansible after installing the insecure key

    agent.vm.provision "shell", privileged: false, reset: true, inline: <<-SHELL
      echo Copy insecure key to /home/vagrant/.ssh/id_rsa...
      rm -Rf /home/vagrant/.ssh/id_rsa
      echo "#{ssh_insecure_key}" > /home/vagrant/.ssh/id_rsa
      chown vagrant /home/vagrant/.ssh/id_rsa
      chmod 400 /home/vagrant/.ssh/id_rsa

      echo Configuring k3s agent...
      echo "cd /vagrant && PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true /home/vagrant/.local/bin/ansible-playbook --limit="agents" --inventory-file=hosts --extra-vars=#{ansible_extra_vars_string} -vvvv ansible/agent-playbook.yml"
      cd /vagrant && PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true /home/vagrant/.local/bin/ansible-playbook --limit="agents" --inventory-file=hosts --extra-vars=#{ansible_extra_vars_string} -vvvv ansible/agent-playbook.yml
    SHELL

  end
end
