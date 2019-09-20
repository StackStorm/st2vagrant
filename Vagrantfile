# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# To force a specific provider set the VAGRANT_DEFAULT_PROVIDER environment variable.
# Vagrant defaults to virtual box if you have it installed
# eg: VAGRANT_DEFAULT_PROVIDER=vmware_deskop
# eg: VAGRANT_DEFAULT_PROVIDER=virtualbox

# The OS to spin up
# Default: ubuntu/xenial64
# Examples:
# BOX=ubuntu/trusty64
# BOX=ubuntu/xenial64
# BOX=ubuntu/bionic64
# BOX=centos/6
# BOX=centos/7
# # Below box tested with vmware_fusion provider, vmware tools installed properly
# BOX=bento/centos-7.6
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
# Default: (empty string, eg: not staging)
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

# A comma-separated list of synced folder options, specified as key/value pairs
# Option values are interpreted as Ruby code
# Default: (empty)
# Examples:
# SYNCED_FOLDER_OPTIONS=vmware  # -> {} (no options)
# SYNCED_FOLDER_OPTIONS=''      # -> {nfs:true,mount_options:["nfsvers=3"]} (Virtualbox)
default_sf_options = {}
all_sf_options = ENV['SYNCED_FOLDER_OPTIONS'] == 'vmware' ? [] : ['nfs:true', 'mount_options:["nfsvers=3"]']
all_sf_options.each do |opt|
  opt_name, opt_value = opt.split(':')
  opt_value = eval(opt_value)
  default_sf_options[opt_name.to_sym] = opt_value
end

# A comma-separated list of common folders to sync
# Available common folders:
#   config            /opt/stackstorm/config
#   packs_dev         /opt/stackstorm/packs_dev
#   packs             /opt/stackstorm/packs
#   datastore_load    /opt/stackstorm/datastore_load
#
# Note that . is always mounted to /vagrant
#
# Default: ''
# Examples:
# SYNCED_FOLDERS='config'
# SYNCED_FOLDERS='config,packs_dev,packs,datastore_load'
vm_synced_folders = []
all_synced_folders = ENV['SYNCED_FOLDERS'] ? ENV['SYNCED_FOLDERS'].split(',') : []
all_synced_folders_map = {
  'config'=>         ['/opt/stackstorm/config', {}],
  'packs_dev'=>      ['/opt/stackstorm/packs_dev', {}],
  'packs'=>          ['/opt/stackstorm/packs', {}],
  'datastore_load'=> ['/opt/stackstorm/datastore_load', {}],
}
all_synced_folders.each do |sf|
  vm_synced_folder = all_synced_folders_map.fetch(sf, nil)
  next if not vm_synced_folder

  vm_synced_folders.push [sf, vm_synced_folder[0], default_sf_options.merge(vm_synced_folder[1])]
end

# A comma-separated list of folder pairs/triples to sync
# Each folder pair is specified as host_folder:guest_folder
# Each folder triple is specified as host_folder:guest_folder:shared_folder_options
# Relative host folders are specified relative to this Vagrantfile
# Shared folder options are evaluated as Ruby code
# Default: ''
# Examples:
# CUSTOM_SYNCED_FOLDERS='../st2client.js,../hubot-stackstorm,../st2chatops'
# CUSTOM_SYNCED_FOLDERS='../st2client.js:/home/vagrant/st2client.js,'\
#                       '../hubot-stackstorm:/home/vagrant/hubot-stackstorm,'\
#                       '../st2chatops:/home/vagrant/st2chatops,'\
#                       '../exchange:/home/vagrant/exchange,'\
#                       '../st2tests:/home/vagrant/st2tests'\
#                       '../st2tests:/home/vagrant/st2web'
# CUSTOM_SYNCED_FOLDERS='../st2client.js:/home/vagrant/st2client.js:'\
#                       '../hubot-stackstorm:/home/vagrant/hubot-stackstorm,'
all_custom_synced_folders = ENV['CUSTOM_SYNCED_FOLDERS'] ? ENV['CUSTOM_SYNCED_FOLDERS'].scan(/([^:,]+)(?::([^:,]+))?(?::(?:((?:\{[^:}]+?\})|(?:\[[^:\]]+?\]))))?/) : []
all_custom_synced_folders.each do |sfpair|
  host_folder, guest_folder, sf_options = sfpair
  guest_folder = guest_folder ? guest_folder : "/home/vagrant/#{File.basename(host_folder)}"
  sf_options = sf_options ? eval(sf_options) : {}

  vm_synced_folders.push [host_folder, guest_folder, default_sf_options.merge(sf_options)]
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
# Minimum Vagrant Version
Vagrant.require_version ">= 2.2.0"
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "#{vm_hostname}" do |st2|
    # Global Box details
    st2.vm.box = "#{vm_box}"
    st2.vm.hostname = "#{vm_hostname}"

    # Box Specifications
    # VirtualBox
    st2.vm.provider :virtualbox do |vb|
      vb.gui = false      # Change to true to launch console
      vb.name = "#{vm_hostname}"
      vb.memory = 4096
      vb.cpus = 2
    end

    # VMWare Desktop (fusion/workstation)
    ["vmware_fusion", "vmware_workstation"].each do |provider|
      st2.vm.provider provider do |vmw, override|
        vmw.gui = false   # Change to true to launch console
        vmw.vmx["ethernet0.virtualDev"] = "vmxnet3"
        vmw.vmx["memsize"] = 4096
        vmw.vmx["numvcpus"] = 2
        # Do not overwrite pci-slot number (https://www.vagrantup.com/docs/vmware/boxes.html#making-compatible-boxes)
        config.vm.provider provider do |vmware|
          vmware.whitelist_verified = true
        end
      end
    end

    vm_synced_folders.each do |host_folder, guest_folder, sf_options|
      st2.vm.synced_folder(host_folder, guest_folder, **sf_options)
    end

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
