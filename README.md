# st2vagrant

Setup [StackStorm](https://www.stackstorm.com/product) (`st2`) on your laptop with Vagrant and
VirtualBox, so you can play with it locally and develop integration and automation
[packs](https://docs.stackstorm.com/latest/packs.html).

If you are fluent with [Vagrant](https://www.vagrantup.com/docs/getting-started), you know where to
look and what to do. If you are new to Vagrant, just follow along with step-by-step instructions
below.


## Pre-requisites
* [Install git](https://git-scm.com/downloads) (duh!). You may not have it if you're on Windows.

* Install recent version of [Vagrant](https://www.vagrantup.com/docs/installation/)
(v1.8.1 at the time of writing). For those unfortunate Windows users: [How to use Vagrant on Windows](http://tech.osteel.me/posts/2015/01/25/how-to-use-vagrant-on-windows.html) may help.

* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (version 5.0 and up), and
VirtualBox Extension packs ([follow instructions for Extension packs
here](https://www.virtualbox.org/manual/ch01.html#intro-installing)).


## Simple installation

Clone the st2vagrant repo, and start up Vagrant:

```bash
git clone https://github.com/StackStorm/st2vagrant.git
cd st2vagrant
vagrant up
```

This command will download a vagrant box, create a virtual machine, and start a script to provision
the most recent stable version of StackStorm. You will see a lot of text, some of that may be red,
but not to worry, it's normal. After a while, you should see a large `ST2 OK`, which means that
installation successful and a VM with StackStorm is ready to play. Log in to VM, and fire some st2
commands:

```bash
vagrant ssh
st2 --version
st2 action list
```

The WebUI is available at https://192.168.16.20. The default st2admin user credentials are in
[Vagrantfile](Vagrantfile), usually `st2admin:Ch@ngeMe`.

You are in business! Go to [QuickStart](https://docs.stackstorm.com/start.html) and follow along.

To configure ChatOps, review and edit `/opt/stackstorm/chatops/st2chatops.env` configuration file
to point to Chat Service you are using. See details in "Setup ChatOps" section in installation
docs for your OS (e.g, [here is one for Ubuntu](https://docs.stackstorm.com/install/rhel7.html#setup-chatops)).

The Brocade Workflow Composer bits are not yet installed; to add them and get Workflow Designer, RBAC, and LDAP,
follow these [instructions to obtain a license key and
install BWC](https://docs.stackstorm.com/install/bwc.html).

If something went wrong, jump to [Troubleshooting](https://github.com/StackStorm/st2vagrant#common-problems-and-solutions) section below.


## Customize your st2 installation

Environment variables can be used to enable or disable certain features of the StackStorm installation:

* `RELEASE` - `stable` for the latest stable release, or `unstable` for a current version from dev trunk. DEFAULT: `stable`
* `HOSTNAME` - the hostname to give the VM. DEFAULT: `st2vagrant`
* `BOX` - the Vagrant base box to use. DEFAULT: `ubuntu/bionic64`
* `ST2USER` - Username for st2. DEFAULT: st2admin
* `ST2PASSWORD` - Password for st2. DEFAULT: `Ch@ngeMe`
* `VERSION` - the version of StackStorm to install: `3.2`

Set the variables by pre-pending them to `vagrant up` command. In the example below, it will install
a version of st2 from development trunc, and set password to `secret`:

```RELEASE="unstable" ST2PASSWORD="secret" vagrant up```

To evaluate StackStorm on supported OS flavors, consider using the boxes we use
[for testing `st2`](https://github.com/StackStorm/st2-test-ground/blob/master/Vagrantfile)
for best results:

* ubuntu/focal64 for Ubuntu 20.04
* ubuntu/bionic64 for Ubuntu 18.04 (default)
* ubuntu/xenial64 for Ubuntu 16.04
* ubuntu/trusty64 for Ubuntu 14.04
* bento/centos-8  for CentOS 8
* bento/centos-7.2 for CentOS 7.2
* bento/centos-6.7 for CentOS 6.7

Examples:

```bash
BOX="bento/centos-7.2" vagrant up
```

```bash
BOX=bento/centos-7.6 RELEASE=stable vagrant up
```

Or use your favorite vagrant box. **Note that StackStorm installs from native Linux packages, which
are built for following OSes only. Make make sure the OS flavor of your box is one of the
following:**

* Ubuntu 20.04 (Focal Fossa)
* **Ubuntu 18.04 (Bionic Beaver)** (default)
* Ubuntu 16.04 (Xenial Xerus)
* Ubuntu 14.04 (Trusty Tahr)

* CentOS 7.2 / RHEL 7.2
* CentOS 6.7 / RHEL 6.7

### Synced folders

**Warning:**

If you mount the above synced folder prior to ST2 installation, the installation may fail due to
synced folders not supporting ownership and/or permissions changes by default.
Also, notice that if you enable the above synced folder, it will *hide* the vagrant box's local
/opt/stackstorm/packs folder. You will need to move the core packages here for ST2 to run properly.

By the time you read this hint, your VM is most likely already up and running. Not to worry: just
uncomment the above mentioned line in your `Vagrantfile` and run `vagrant reload --no-provision`.
This will restart the VM and apply the new config without running the provision part, so you won't
reinstall st2. Vagrant will however ask you for your laptop password to sync the folders.

For details on NFS refer: https://www.vagrantup.com/docs/synced-folders/nfs.html

To learn about packs and how to work with them, see
[StackStorm documentation on packs!](https://docs.stackstorm.com/latest/packs.html)

#### Using the vmware_desktop provider

If you wish to startup a VM with the VMWare Workstation or VMWare Fusionproviders,
eg: vmware_desktop , you will need to specify `SYNCED_FOLDER_OPTIONS=vmware` when
running `vagrant up`.

```
SYNCED_FOLDER_OPTIONS=vmware BOX=bento/centos-7.6 RELEASE=stable vagrant up
```

If you have multiple providers installed, to force the vmwware_desktop provider:

```bash
VAGRANT_DEFAULT_PROVIDER=vmware_desktop SYNCED_FOLDER_OPTIONS=vmware BOX=bento/centos-7.6 RELEASE=stable vagrant up
```

Only the bento/centos-7.6 has been tested. This vagrant box reliably ships with VMWare
tools installed for synced folders.

The options to `synced_folder` are the following for the VM provider:

| Provider             | Synced folder options                         |
| -------------------- | --------------------------------------------- |
| VMWare               | `**{}` (no options)                           |
| Virtualbox (default) | `**{nfs: true, mount_options: ["nfsvers=3"]}` |

#### Using the libvirt provider (KVM)

If you want to run the the VM with KVM/libvirt simply do:

``` bash
BOX=generic/ubuntu1804 vagrant up --provider libvirt
BOX=centos/7 vagrant up --provider libvirt
BOX=centos/8 vagrant up --provider libvirt
```

#### Common synced folders for Pack development

Playing with StackStorm ranges from creating rules and workflows, to turning your scripts into
actions, to writing custom sensors. And all of that involves working with files under
`/opt/stackstorm/packs` on `st2vagrant` VM. One can do it via SSH, but with all your favorite tools
already set up on your laptop, it's convenient to hack files and work with `git` there on the host.

You can create your pack directories under `st2vagrant/` on your host. Vagrant automatically maps
it's host directory to `/vagrant` directory on the VM, where you can symlink files and dirs to
desired locations.

Alternatively, you can specify a comma-separated list of common synced folders in the the
`SYNCED_FOLDERS` environment variable to mount them in the guest VM.

```bash
SYNCED_FOLDERS=packs,datastore_load vagrant up
```

Available common synced folders are:

| Host folder        | Guest folder                     |
| ------------------ | -------------------------------- |
| `.`                | `/vagrant`                       |
| `./config`         | `/opt/stackstorm/config`         |
| `./packs`          | `/opt/stackstorm/packs`          |
| `./packs_dev`      | `/opt/stackstorm/packs_dev`      |
| `./datastore_load` | `/opt/stackstorm/datastore_load` |

#### Custom synced folders

If you would like to use synced folders that are not one of the common synced folders, you can
specify a comma-separated list of custom folders to sync in the `CUSTOM_SYNCED_FOLDERS`
environment variable.

There are different ways to specify synced folders. You can specify just the host folder, which
will be mounted to `/home/vagrant/{folder}` within the guest, using the mount settings specified
with `SYNCED_FOLDER_OPTIONS`.

```bash
CUSTOM_SYNCED_FOLDERS=../st2client.js,../hubot-stackstorm vagrant up
```

will mean `../st2client.js` and `../hubot-stackstorm` will be mounted into
`/home/vagrant/st2client.js` and `/home/vagrant/hubot-stackstorm`, respectively, in the guest.

You can also specify the host folder as well as the guest folder, by separating them with a `:`:

```bash
CUSTOM_SYNCED_FOLDERS=../st2client.js:/custom/dir/st2client.js,../hubot-stackstorm:/custom/dir/hubot-stackstorm vagrant up
```

This will mount the directories into `/custom/dir/st2client.js` and `/custom/dir/hubot-stackstorm`,
respectively, using the default mount settings specified with `SYNCED_FOLDER_OPTIONS`.

Finally, you can specify mount options individually for each synced folder by adding them after
another `:`:

```bash
CUSTOM_SYNCED_FOLDERS=../st2client.js:/custom/dir/st2client.js:{disabled:true},../hubot-stackstorm:/custom/dir/hubot-stackstorm:{custom_option:["nfsvers=3"]} vagrant up
```

The options will be `eval()`ed (as a Ruby snippet) within the `Vagrantfile`, then used in a double
splat argument. This means that you can specify all options to the `vm.synced_folder` function
in these options.

#### Advanced Pack Development Synced Folder Workflow Strategy

One of the common use cases is pack development. In order to streamline a persistent local
development environment, the following approach could be used:

**Warning**

Syncing the config directory before ST2 install will cause the installation to fail due to permissions. There is
probably a workaround -> if you know it open an issue and let us know.  

1. Synced folders you may wish to utilize to speed up setup of Vagrant box:
    
    * `config`          --> synced to `/opt/stackstorm/config`
    * `datastore_load`  --> synced to `/opt/stackstorm/datastore_load`
    * `packs_dev`       --> synced to `/opt/stackstorm/packs_dev`

2. Folder usage:

    * `config` folder: You can persist pack configs such as `aws.yaml` or `jira.yaml` in this folder and they will be
    present after vagrant up
    * `datastore_load`: Use this folder to store a json file that you would import to the datastore using 
    `st2 key load /opt/stackstorm/datastore_load/mykeystoredata.json`
    * `packs_dev`: Use this folder to iterate on packs you are developing. After you commit your changes you can install
     the pack in your Vagrant box:
         - `cd /opt/stackstorm/packs_dev/YOUR_PACK_DIRECTORY`
         - `st2 pack install file:///$PWD [--python3]` 
         
 3. Additional information
 
    * This repo includes .gitignore entries for the 3 directories described above.
    * This approach remove any installation conflicts, and prevents confusion of installing dev packs into ST2, since
    the `st2 pack install` command will create a clone of the pack in `/opt/stackstorm/packs` directory.

See the `NFS Advanced Pack Dev Approach` and `VMWARE HGFS Advanced Pack Dev Approach` in the Vagrantfile for synced 
folder configs that follow this strategy.


## Manual installation

To master StackStorm and understand how things are wired together, we strongly encourage you to
[eventually] install StackStorm manually, following
[installation instructions](https://docs.stackstorm.com/install/). You can still
benefit from this Vagrantfile to get the Linux VM up and running: follow instructions to
install Vagrant & VirtualBox to get a Linux VM, and simply comment out the
`st2.vm.provision "shell"...` section in your `Vagrantfile` before running `vagrant up`.


## Common problems and solutions

#### IP Conflicts

In the event you receive an error related to IP conflict, Edit the `private_neworks` address in `Vagrantfile`, and adjust the third octet to a non-conflicting value. For example:

```
    # Configure a private network
    st2.vm.network :private_network, ip: "192.168.16.20"
```


#### Mounts

Sometimes after editing or adding NFS mounts via `config.vm.synced_folder`,and firing `vagrant up` or `vagrant reload`, you may see this:

```
==> st2express: Exporting NFS shared folders...
NFS is reporting that your exports file is invalid. Vagrant does
this check before making any changes to the file. Please correct
the issues below and execute "vagrant reload":

exports:3: path contains non-directory or non-existent components: /Volumes/Repo/st2
exports:3: path contains non-directory or non-existent components: /Volumes/Repo/st2contrib
exports:3: path contains non-directory or non-existent components: /Volumes/Repo/st2incubator
exports:3: no usable directories in export entry
exports:3: using fallback (marked offline): /Volumes/Repo
```
FIX: Remove residuals from `/etc/exports` file on the host machine, and do `vagrant reload` again.


## Using st2vagrant for release testing

Creates a box from a specific development version of code:

``` bash
BOX=centos/7 RELEASE=unstable VERSION=3.1dev vagrant up
```

## Support

Please follow [guidelines](https://docs.stackstorm.com/troubleshooting/ask_for_support.html) for support if none of the [self troubleshooting guides](https://docs.stackstorm.com/troubleshooting/index.html) do not help! Ask community on Slack at stackstorm-community.slack.com channel ([register here first](https://stackstorm.com/community-signup)).
