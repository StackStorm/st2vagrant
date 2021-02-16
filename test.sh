#!/bin/bash

E_PARAM_ERR=98
E_ASSERT_FAILED=99

# http://tldp.org/LDP/abs/html/debugging.html#ASSERT
#######################################################################
assert ()                 #  If condition false,
{                         #+ exit from script
                          #+ with appropriate error message.

  set -eux

  if [ -z "$2" ]          #  Not enough parameters passed
  then                    #+ to assert() function.
    return $E_PARAM_ERR   #  No damage done.
  fi

  lineno=$2

  if [ ! $1 ]
  then
    echo "Assertion failed:"
    echo "\"$1\""
    echo "File \"$0\", line $lineno"    # Give name of file and line number.
    exit $E_ASSERT_FAILED
  # else
  #   return
  #   and continue executing the script.
  fi

  set +eux
} # Insert a similar assert() function into a script you need to debug.
#######################################################################



echo '================ Testing  COMMUNITY VERSION ================'

echo '---------------- Test: default options ---------------------'

# Default options
vagrant up

sleep 10

# Check the OS
DEFAULT_ETC_ISSUE_VALUE=$(vagrant ssh --command "printf \"\$(sed 's| \\\\l||' /etc/issue)\"" | tr -d '\r')
assert "$? -eq 0" $LINENO
assert "$DEFAULT_ETC_ISSUE_VALUE = Ubuntu 16.04*" $LINENO

# Check the hostname
DEFAULT_HOSTNAME_VALUE=$(vagrant ssh --command "hostname" | tr -d '\r\n')
assert "$? -eq 0" $LINENO
assert "$DEFAULT_HOSTNAME_VALUE = st2vagrant" $LINENO

# Check the IP
vagrant ssh --command "ifconfig | grep -q 'inet addr:192.168.16.20  Bcast:192.168.16.255  Mask:255.255.255.0'"
assert "$? -eq 0" $LINENO

# Check the username and password
DEFAULT_USER_LOGIN=$(vagrant ssh --command "st2 login st2admin --password 'Ch@ngeMe'")
assert "$? -eq 0" $LINENO

DEFAULT_USER_VALUE=$(vagrant ssh --command "st2 whoami | grep -q 'Currently logged in as \"st2admin\"'")
assert "$? -eq 0" $LINENO
assert "$DEFAULT_USER_VALUE = st2admin" $LINENO

# Check the Packagecloud community repository
vagrant ssh --command 'grep -qE "^deb https://packagecloud.io/StackStorm/unstable/ubuntu/ xenial main$" /etc/apt/sources.list.d/StackStorm*stable.list'
assert "$? -eq 0" $LINENO

# Check that installed packages are for the unstable (dev-) community version
vagrant ssh --command "apt search ^st2 2>/dev/null | grep -qE '^st2.*[[:digit:]]*\.[[:digit:]]*dev\-[[:digit:]]*.*\[.*installed.*\]\$'"
assert "$? -eq 0" $LINENO

vagrant destroy --force


echo '---------------- Test: custom vm options -------------------'

# Custom options for booting the box and setting up the st2 user
BOX=ubuntu/trusty64 \
HOSTNAME=st2vagrant-trusty \
VM_IP=192.168.16.40 \
ST2USER=st2customuser \
ST2PASSWORD=st2passwd \
vagrant up

sleep 10

# Check the OS
CUSTOM_VM_ETC_ISSUE_VALUE=$(\
BOX=ubuntu/trusty64 \
HOSTNAME=st2vagrant-trusty \
VM_IP=192.168.16.40 \
ST2USER=st2customuser \
ST2PASSWORD=st2passwd \
vagrant ssh --command "printf \"\$(sed 's| \\\\l||' /etc/issue)\"" | tr -d '\r')
assert "$? -eq 0" $LINENO
assert "$CUSTOM_VM_ETC_ISSUE_VALUE = Ubuntu 14.04*" $LINENO

# Check the hostname
CUSTOM_VM_HOSTNAME_VALUE=$(\
BOX=ubuntu/trusty64 \
HOSTNAME=st2vagrant-trusty \
VM_IP=192.168.16.40 \
ST2USER=st2customuser \
ST2PASSWORD=st2passwd \
vagrant ssh --command "hostname" | tr -d '\r\n')
assert "$? -eq 0" $LINENO
echo $CUSTOM_VM_HOSTNAME_VALUE
assert "$CUSTOM_VM_HOSTNAME_VALUE = st2vagrant-trusty" $LINENO

# Check the IP
BOX=ubuntu/trusty64 \
HOSTNAME=st2vagrant-trusty \
VM_IP=192.168.16.40 \
ST2USER=st2customuser \
ST2PASSWORD=st2passwd \
vagrant ssh --command "ifconfig | grep -q 'inet addr:192.168.16.40  Bcast:192.168.16.255  Mask:255.255.255.0'"
assert "$? -eq 0" $LINENO

# Check the username and password
CUSTOM_VM_USER_VALUE=$(\
BOX=ubuntu/trusty64 \
HOSTNAME=st2vagrant-trusty \
VM_IP=192.168.16.40 \
ST2USER=st2customuser \
ST2PASSWORD=st2passwd \
vagrant ssh --command "st2 login st2customuser --password 'st2passwd'; st2 whoami | grep -q 'Currently logged in as \"st2customuser\".'")
assert "$? -eq 0" $LINENO
assert "$CUSTOM_VM_USER_VALUE = st2customuser" $LINENO

BOX=ubuntu/trusty64 \
HOSTNAME=st2vagrant-trusty \
VM_IP=192.168.16.40 \
ST2USER=st2customuser \
ST2PASSWORD=st2passwd \
vagrant destroy --force


echo '---------------- Test: installation options ----------------'

# Repository
REPO_TYPE=staging \
RELEASE=stable \
vagrant up

sleep 10

# Check the Packagecloud community repository
REPO_TYPE=staging \
RELEASE=stable \
vagrant ssh --command 'grep -qE "^deb https://packagecloud.io/StackStorm/staging-stable/ubuntu/ xenial main$" </etc/apt/sources.list.d/StackStorm*stable.list'
assert "$? -eq 0" $LINENO

# Check that installed packages are for the stable (non dev-) community version
REPO_TYPE=staging \
RELEASE=stable \
vagrant ssh --command "apt search ^st2 2>/dev/null | grep -qE '^st2.*[[:digit:]]*\.[[:digit:]]*\-[[:digit:]]*.*\[.*installed.*\]\$'"
assert "$? -eq 0" $LINENO

REPO_TYPE=staging \
RELEASE=stable \
vagrant destroy --force
