# -*- mode: ruby -*-
# vi: set ft=ruby :

# The OS to spin up
# Default: ubuntu/xenial64
# Examples:
# BOX=ubuntu/trusty64
# BOX=ubuntu/xenial64
# BOX=ubuntu/bionic64
# BOX=centos/6
# BOX=centos/7
vm_box         = ENV['BOX'] ? ENV['BOX'] : 'ubuntu/xenial64'

# The hostname of the Vagrant VM
# Default: st2vagrant
# Examples:
# HOSTNAME=st2vagrant-rhel7
# HOSTNAME=rhel7-testing
vm_hostname    = ENV['HOSTNAME'] ? ENV['HOSTNAME'] : 'st2vagrant'

# The IP address to assign to the VM
# Default: 192.168.16.20
# Examples:
# VM_IP=192.168.1.4
vm_ip       = ENV['VM_IP'] ? ENV['VM_IP'] : '192.168.16.20'

# The ST2 user
# Default: st2admin
# Example:
# ST2USER=st2user
st2user     = ENV['ST2USER'] ? '-u "' + ENV['ST2USER'] + '"': '-u "st2admin"'

# The ST2 user password
# Default: Ch@ngeMe
# Example: ST2PASSWORD=secret-tunnel/secret-tunnel/through-the-mountain/secret-secret-tunnel
st2passwd   = ENV['ST2PASSWORD'] ? '-p "' + ENV['ST2PASSWORD'] + '"' : '-p "Ch@ngeMe"'

# Which release channel (stable or unstable to use)
# Default: unstable
# RELEASE=stable
# RELEASE=unstable
release     = ENV['RELEASE'] ? '-r "' + ENV['RELEASE'] + '"' : '-r unstable'

# Which release channel (staging or not to use)
# Default: not staging
# REPO_TYPE=staging
repo_type   = ENV['REPO_TYPE'] ? '-t ' + ENV['REPO_TYPE'] : ''

# Build source - used to install packages from a specific CircleCI build
# Default: Packagecloud
# Examples:
# DEV=st2/5017
# DEV=mistral/1012
# DEV=st2-packages/3021
dev         = ENV['DEV'] ? '-d ' + ENV['DEV'] : ''

# The branch of st2-packages or bwc-installer to pull and use
# NOTE: If the branch name just happens to be 48 hex characters, it will be
#       interpreted as a license key - see the ENTERPRISE option below
# Default: master
# Examples:
# BRANCH=master
# BRANCH=yum-exclude-nginx
branch      = ENV['BRANCH'] ? '-b "' + ENV['BRANCH'] + '"' : '-b "master"'

# The Packagecloud.io key for enterprise packages
# If unspecified, only community packages will be installed
# Example:
# LICENSE_KEY=0123456789abcdef0123456789abcdef0123456789abcdef
license_key = ENV['LICENSE_KEY'] ? '-k ' + ENV['LICENSE_KEY'] : ''

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "#{vm_hostname}" do |st2|
    # Box details
    st2.vm.box = "#{vm_box}"
    st2.vm.hostname = "#{vm_hostname}"

    # Box Specifications
    st2.vm.provider :virtualbox do |vb|
      vb.name = "#{vm_hostname}"
      vb.memory = 4096
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
      s.args   = "#{st2user} #{st2passwd} #{release} #{repo_type} #{dev} #{branch} #{license_key}"
      s.privileged = false
    end
  end
end
