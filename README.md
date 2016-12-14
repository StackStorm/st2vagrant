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

The Enterprise bits are not yet installed; to add them and get Workflow Designer, RBAC, and LDAP,
follow these [instructions to obtain a license key and
install StackStorm Enterprise](https://docs.stackstorm.com/install/enterprise.html)

If something went wrong, jump to [Troubleshooting](https://github.com/StackStorm/st2vagrant#common-problems-and-solutions) section below.


## Customize your st2 installation

Environment variables can be used to enable or disable certain features of the StackStorm installation:

* `RELEASE` - `stable` for the latest stable release, or `unstable` for a current version from dev trunk. DEFAULT: `stable`
* `HOSTNAME` - the hostname to give the VM. DEFAULT: `st2vagrant`
* `BOX` - the Vagrant base box to use. DEFAULT: `ubuntu/trusty64`
* `ST2USER` - Username for st2. DEFAULT: st2admin
* `ST2PASSWORD` - Password for st2. DEFAULT: `Ch@ngeMe`

Set the variables by pre-pending them to `vagrant up` command. In the example below, it will install
a version of st2 from development trunc, and set password to `secret`:

```RELEASE="unstable" ST2PASSWORD="secret" vagrant up```

To evaluate StackStorm on supported OS flavors, consider using the boxes we use
[for testing `st2`](https://github.com/StackStorm/st2-test-ground/blob/master/Vagrantfile)
for best results:

* ubuntu/trusty64 for Ubuntu 14.04 (default)
* ubuntu/xenial64 for Ubuntu 16.04
* bento/centos-7.2 for CentOS 7.2
* bento/centos-6.7 for CentOS 6.7

Example:

```BOX="bento/centos-7.2" vagrant up```

Or use your favorite vagrant box. **Note that StackStorm installs from native Linux packages, which
are built for following OSes only. Make make sure the OS flavor of your box is one of the
following:**

* Ubuntu 16.04 (Xenial Xerus)
* **Ubuntu 14.04 (Trusty Tahr)**
* CentOS 6.7 / RHEL 6.7
* CentOS 7.2 / RHEL 7.2

#### NFS mount option for Pack development

Playing with StackStorm ranges from creating rules and workflows, to turning your scripts into
actions, to writing custom sensors. And all of that involves working with files under
`/opt/stackstorm/packs` on `st2vagrant` VM. One can do it via ssh, but with all your favorite tools
already set up on your laptop, it's convenient to hack files and work with `git` there on the host.

You can create your pack directories under `st2vagrant/` on your host. Vagrant automatically maps
it's host directory to `/vagrant` directory on the VM, where you can symlink files and dirs to
desired locations.

Better yet, create a custom NFS mount to mount a directory on your laptop to `/opt/stackstorm/packs`
on the VM. In the Vagrantfile we are using following line for enabling ***NFS synced folder***:

```config.vm.synced_folder "path/to/folder/on/host", "/opt/stackstorm/packs", :nfs => true, :mount_options => ['nfsvers=3']```

To use this option, uncomment the line and change the location of `"path/to/folder/on/host"` to an
existing directory on your laptop.

By the time you read this hint, your VM is most likely already up and running. Not to worry: just
uncomment the above mentioned line in your `Vagrantfile` and run `vagrant reload --no-provision`.
This will restart
the VM and apply the new config without running the provision part, so you won't reinstall st2.
Vagrant will however ask you for your laptop password to sync the folders.

For details on NFS refer: https://www.vagrantup.com/docs/synced-folders/nfs.html

To learn about packs and how to work with them, see
[StackStorm documentation on packs!](https://docs.stackstorm.com/latest/packs.html)

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

## Support

Please follow [guidelines](https://docs.stackstorm.com/troubleshooting/ask_for_support.html) for support if none of the [self troubleshooting guides](https://docs.stackstorm.com/troubleshooting/index.html) do not help! Ask community on Slack at stackstorm-community.slack.com channel ([register here first](https://stackstorm.com/community-signup)).
