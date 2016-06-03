##Introduction

To install StackStorm automation platform using Vagrant. It will get you up and running with a single VM running all St2 components, as well as Mistral.

####Hardware and OS requirements

**Host**

Your laptop/server with Vagrant and VirtualBox installed.

***NOTE: Installation using Nested VMs is not recommended***

####Purpose of Installation

1. To experiment with Stackstorm before deployment
2. To develop Packs: https://docs.stackstorm.com/latest/packs.html

####Installation Steps

 - **Hardware requirements:**

    A bare metal server or your laptop with Vagrant and VirtualBox installed.
      
         ***NOTE: Installation using Nested VMs is not recommended***

          - **Steps to install:**

                - Vagrant Installation:
                         - Download and Install: https://www.vagrantup.com/docs/installation/

                               - VirtualBox Installation:
                                        - Download and Install: https://www.virtualbox.org/wiki/Downloads
                                                 - Also install Extension Pack for VirtualBox: http://download.virtualbox.org/virtualbox/5.0.20/Oracle_VM_VirtualBox_Extension_Pack-5.0.20-106931.vbox-extpack

                                                 *Either `git clone` this repo or create a folder and copy `VagrantFile` in it and follow these steps::*

                                                 To provision the environment run:

                                                     vagrant up

                                                     There will be some red messages but that is fine.  Once the vm is up, connect to it via:

                                                         vagrant ssh

                                                         In the vm create environment variable for auth token:

                                                             export ST2_AUTH_TOKEN=`st2 auth st2admin -p Ch@ngeMe -t`

                                                             NOTE: This token expires after 24 hours.You will have to re-enter this command for st2 to work.

                                                             You can see the action list via:

                                                                 st2 action list

                                                                 The supervisor script to start,stop,restart,reload, and, clean st2 is run like so:

                                                                     st2ctl start|stop|status|restart|reload|clean

####Environment Variables for Vagrantfile
Environment variables can be used to enable or disable certain features of the StackStorm deployment.

* HOSTNAME - the hostname to give the VM.
    * DEFAULT: st2vagrant
    * BOX - the Vagrant base box
        * DEFAULT: ubuntu/trusty64
        * ST2PASSWORD - Password for the st2
            * DEFAULT: Ch@ngeMe

            Other options for BOX are:
              * centos/7

              **NOTE:** If you are using box other than mentioned above, the install script might not work because of various OS related nuances. Based on the OS you may have to install/update `cURL` and/or update `nss` and run the cURL command again from the VM.

####Usage

`HOSTNAME=st2test ST2PASSWORD=pass vagrant up`

If the hostname has been specified during `vagrant up` then it either needs to be exported or specified for all future vagrant commands related to that VM.

Example:
If the following was used to provision the VM:
`HOSTNAME=st2test vagrant up`

then status would need to be run like so:
`HOSTNAME=st2test vagrant status`

and destroy:
`HOSTNAME=st2test vagrant destroy`

The alternative is to simply `export HOSTNAME=st2test`

####NFS Mount Option for Pack development

https://docs.stackstorm.com/latest/packs.html

In the Vagrantfile we are using following line for enabling ***NFS synced folder***:

`config.vm.synced_folder "path/to/folder/on/host", "/opt/stackstorm/packs", :nfs => true, :mount_options => ['nfsvers=3']`

To use this option you can uncomment the line and change the location of the folder based on your host machine. During `vagrant up` it will ask you for your host password to sync the folders.

For details on NFS refer: https://www.vagrantup.com/docs/synced-folders/nfs.html
