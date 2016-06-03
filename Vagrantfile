# -*- mode: ruby -*-
# vi: set ft=ruby :

hostname   = ENV['HOSTNAME'] ? ENV['HOSTNAME'] : 'st2vagrant'
box        = ENV['BOX'] ? ENV['BOX'] : 'ubuntu/trusty64'
st2passwd  = ENV['ST2PASSWD'] ? ENV['ST2PASSWD'] : 'Ch@ngeMe'

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
    st2.vm.network :private_network, ip: "192.168.0.10"

    # Start shell provisioning
    # config.vm.provision :shell, :inline => "sudo apt-get install nfs-common portmap"
    st2.vm.provision :shell, :inline => "curl -sSL https://stackstorm.com/packages/install.sh | bash -s -- --user=st2admin --password=#{st2passwd}"
  end

end
