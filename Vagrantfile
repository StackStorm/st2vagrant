# -*- mode: ruby -*-
# vi: set ft=ruby :

st2ver       = ENV['ST2VER'] ? ENV['ST2VER'] : 'stable'
hostname     = ENV['HOSTNAME'] ? ENV['HOSTNAME'] : 'st2express'
box          = ENV['BOX'] ? ENV['BOX'] : 'ubuntu/trusty64'
st2passwd  = ENV['ST2PASSWD'] ? ENV['ST2PASSWD'] : 'Ch@ngeMe'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box = "#{box}"
    config.vm.hostname = "#{hostname}"

    # Using NFS: It is used for sharing folders between host and guest machines.
    # config.vm.synced_folder "v-root", "/vagrant", :nfs => true

    config.vm.provider :virtualbox do |vb|
      vb.name = "#{hostname}"
      vb.memory = 2048
      vb.cpus = 2
    end

    # Configure a private network
    config.vm.network :private_network, ip: "192.168.0.10"

    # Start shell provisioning
    config.vm.provision :shell, :inline => "sudo apt-get install nfs-common portmap"
    config.vm.provision :shell, :inline => "curl -sSL https://stackstorm.com/packages/install.sh | bash -s -- --user=st2admin --password=#{st2passwd}"
    # config.vm.provision :shell, :inline => "INSTALL_WEBUI=#{webui} bash -c '. st2_deploy.sh #{st2ver}'"
    # config.vm.provision :shell, :path => "rsyslog.sh"
    # config.vm.provision :shell, :path => "sensu_server.sh"
    # config.vm.provision :shell, :path => "sensu_client.sh"
    # config.vm.provision :shell, :inline => "INSTALL_WEBUI=#{webui} bash -c '/vagrant/validate.sh'"
end
