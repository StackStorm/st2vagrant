# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

hostname    = ENV['HOSTNAME'] ? ENV['HOSTNAME'] : 'st2vagrant'
box         = ENV['BOX'] ? ENV['BOX'] : 'ubuntu/xenial64'

# VM's IP address
vm_ip       = ENV['VM_IP'] ? ENV['VM_IP'] : '192.168.16.40'

# Release type: 'stable' or the default 'unstable'
release     = ENV['RELEASE'] ? ENV['RELEASE'] : 'unstable'

# Non-empty license key implies enterprise
license_key = ENV['LICENSE_KEY'] ? '-k ' + ENV['LICENSE_KEY'] : ''

# 'staging' or the default empty string
repo_type   = ENV['REPO_TYPE'] ? '-t ' + ENV['REPO_TYPE'] : ''

st2user     = ENV['ST2USER'] ? ENV['ST2USER']: 'st2admin'
st2passwd   = ENV['ST2PASSWORD'] ? ENV['ST2PASSWORD'] : 'Ch@ngeMe'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "#{hostname}" do |st2|
    # Box details
    st2.vm.box = "#{box}"
    st2.vm.hostname = "#{hostname}"

    # Box Specifications
    st2.vm.provider :virtualbox do |vb|
      vb.name = "#{hostname}"
      vb.memory = 2048
      vb.cpus = 2
    end

    # NFS-synced directory for pack development
    # Change "/path/to/directory/on/host" to point to existing directory on your laptop/host and uncomment:
    # config.vm.synced_folder "/path/to/directory/on/host", "/opt/stackstorm/packs", :nfs => true, :mount_options => ['nfsvers=3']

    # Configure a private network
    st2.vm.network :private_network, ip: "#{vm_ip}"

    # Public (bridged) network may come handy for external access to VM (e.g. sensor development)
    # See https://www.vagrantup.com/docs/networking/public_network.html
    # st2.vm.network "public_network", bridge: 'en0: Wi-Fi (AirPort)'

    # Start shell provisioning.
    st2.vm.provision "shell" do |s|
      s.path = "scripts/install_st2.sh"
      s.args   = "-u #{st2user} -p #{st2passwd} -r #{release} #{license_key} #{repo_type}"
      s.privileged = false
    end
  end

end
