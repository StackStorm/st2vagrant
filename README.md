##Introduction

This repo was created as a quick install of the StackStorm automation platform.  It will get you up and running with a single VM running all St2 components, as well as Mistral.

####Hardware and OS requirements


**Host**

You can use any one of the following to deploy stackstorm:
 * Bare metal server with supported Linux OS installed.
 * VM with supported Linux OS.
 * Your laptop/server using Vagrant and VirtualBox.

**Supported OS**
 * Ubuntu 14.04
 * Red Hat 6/CentOS6
 * Red Hat 7/CentOS7

***NOTE: Installation using Nested VMs is not recommended***

####Purpose of Installation

1. For experimenting with Stackstorm before deployment
2. To develop Packs: https://docs.stackstorm.com/latest/packs.html

##Install Guide

####Installation On a Dedicated Host (w/o Vagrant)
 For details refer: https://docs.stackstorm.com/latest/install/index.html

 - **Hardware requirements:**

   A bare metal server or a VM with supported Linux OS.

 - **Steps to install:**
   1. Using following Curl command:

     ``curl -sSL https://stackstorm.com/packages/install.sh | bash -s -- --user=st2admin --password=<CHANGEME>``

      _Don't forget to change the password at \<CHANGEME\>_

      **NOTE:** The script will detect the flavor of Linux OS and install everything for you

   2. Custom configuration:

       For custom installation use following doc:
       https://docs.stackstorm.com/latest/install/index.html

####VM based installation(Vagrant and VirtualBox)

 - **Hardware requirements:**

   A bare metal server or your laptop with Vagrant and VirtualBox installed.

 - **Steps to install:**

      - Vagrant Installation:
         - Download and Install: https://www.vagrantup.com/docs/installation/

     - VirtualBox Installation:
         - Download and Install: https://www.virtualbox.org/wiki/Downloads
         - Also install Extension Pack for VirtualBox: http://download.virtualbox.org/virtualbox/5.0.20/Oracle_VM_VirtualBox_Extension_Pack-5.0.20-106931.vbox-extpack

Either `git clone` this repo or create a folder and copy `VagrantFile` in it and follow these steps::

To provision the environment run:

    vagrant up

There will be some red messages but that is fine.  One the vm is up, connect to it via:

    vagrant ssh st2express

You can see the action list via:

    st2 action list

The supervisor script to start,stop,restart,reload, and, clean st2 is run like so:

    st2ctl start|stop|status|restart|reload|clean

### Environment Variables
Environment variables can be used to enable or disable certain features of the StackStorm deployment.

* WEBUI - Set to 0 to skip ui installation.
    * DEFAULT: 1
* ST2VER - The version of St2 to install.
    * DEFAULT: 0.8.0
* HOSTNAME - the hostname to give the VM.
    * DEFAULT: st2express
* BOX - the Vagrant base box
    * DEFAULT: ubuntu/trusty64

#### Usage

`HOSTNAME=st2test ST2VER=0.8.0 WEBUI=0 vagrant up`

If the hostname has been specified during `vagrant up` then it either needs to be exported or specified for all future vagrant commands related to that VM.

Example:
If the following was used to provision the VM:
`HOSTNAME=st2test vagrant up`

then status would need to be run like so:
`HOSTNAME=st2test vagrant status`

and destroy:
`HOSTNAME=st2test vagrant destroy`

The alternative is to simply `export HOSTNAME=st2test`

### Logging
This installation makes use of the syslog logging configuration files for each of the St2 components.  You will find the logs in:

    /var/log/st2

All actionrunner processes will be using a combined log under st2actions.log and st2actions.audit.log
