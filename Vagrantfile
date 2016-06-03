# -*- mode: ruby -*-
# vi: set ft=ruby :

hostname   = ENV['HOSTNAME'] ? ENV['HOSTNAME'] : 'st2vagrant'
box        = ENV['BOX'] ? ENV['BOX'] : 'bento/ubuntu-14.04'
st2user    = ENV['ST2USER'] ? ENV['ST2USER']: 'st2admin'
st2passwd  = ENV['ST2PASSWORD'] ? ENV['ST2PASSWORD'] : 'Ch@ngeMe'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "st2" do |st2|
    # Box details
    st2.vm.box = "#{box}"
    st2.vm.hostname = "#{hostname}"

    # Box Specifications
    st2.vm.provider :virtualbox do |vb|
      vb.name = "#{hostname}"
      vb.memory = 2048
      vb.cpus = 2
    end

    # NFS synced folder for pack development
    # You can change the location of your local folder "/path/to/folder/on/host".
    # config.vm.synced_folder "/path/to/folder/on/host", "/opt/stackstorm/packs", :nfs => true, :mount_options => ['nfsvers=3']

    # Configure a private network
    st2.vm.network :private_network, ip: "192.168.20.20"

    # Start shell provisioning
    st2.vm.provision "shell" do |s|
      s.path = "scripts/install_st2.sh"
      s.args   = "#{st2user} #{st2passwd}"
      s.privileged = false
    end
  end

end
