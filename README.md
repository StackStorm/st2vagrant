# st2vagrant

A [Vagrant](https://www.vagrantup.com/about.html) based installer for StackStorm automation platform (st2). 

#### Purpose of st2vagrant

1. To experiment with StackStorm before production deployment.
2. To develop StackStorm Packs - https://docs.stackstorm.com/latest/packs.html.

#### Hardware and OS requirements

**Host**

Your laptop/server with Vagrant and VirtualBox installed!

   ***NOTE: Installation using Nested VMs is not recommended***

**OS**
 
* Ubuntu 14.04 (trusty tahr)
* CentOS 6.7 / RHEL 6.7
* CentOS 7.2 / RHEL 7.2

Note that you can use a bare metal server but we recommend using a virtual machine for your own safety. 


#### Pre-requisites

If you do not have vagrant and virtualbox installed, follow the steps below. 
Otherwise, skip to next section.

* [Install Vagrant](https://www.vagrantup.com/docs/installation/)

* [Install Virtualbox and extension pack](https://www.virtualbox.org/wiki/Downloads)
 
 
#### Install stackstorm inside the VM

 * Clone the st2vagrant repo
    ```git clone https://github.com/StackStorm/st2vagrant.git```

 * Install st2. (This is simply a vagrant provision step. Usually safe to ignore all red messages.)

     ```vagrant up```

 * Play with st2 by connecting to the VM!

     ```vagrant ssh```

#### Playing with st2

You can see the action list via:

```st2 action list```

A supervisor script named ```st2ctl``` is available to start, stop, restart, reload and clean st2.

#### Custom st2 installation

Environment variables can be used to enable or disable certain features of the StackStorm installation.

* HOSTNAME - the hostname to give the VM. DEFAULT: st2vagrant
* BOX - the Vagrant base box to use. DEFAULT: bento/ubuntu-14.04
* ST2USER - Username for st2. DEFAULT: st2admin
* ST2PASSWORD - Password for st2. DEFAULT: Ch@ngeMe

To evaluate StackStorm on other supported OS flavors, you can use the following options for BOX:

* bento/centos-7.2
* bento/centos-6.7

Example: 

```BOX="bento/centos-7.2" vagrant up```

#### I am ready to write a new pack!


To learn about packs and how to work with them, see [StackStorm documentation on packs!](https://docs.stackstorm.com/latest/packs.html)


#### NFS Mount Option for Pack development

If you want to develop StackStorm pack on your host server and share the code inside the VM where StackStorm is running, you can use NFS. 

In the Vagrantfile we are using following line for enabling ***NFS synced folder***:

```config.vm.synced_folder "path/to/folder/on/host", "/opt/stackstorm/packs", :nfs => true, :mount_options => ['nfsvers=3']```

To use this option you can uncomment the line and change the location of the folder based on your host machine. During ```vagrant up``` it will ask you for your host password to sync the folders.

For details on NFS refer: https://www.vagrantup.com/docs/synced-folders/nfs.html


#### I need help!

Please follow [guidelines](https://docs.stackstorm.com/troubleshooting/ask_for_support.html) for support if none of the [self troubleshooting guides](https://docs.stackstorm.com/troubleshooting/index.html) do not help!
