#!/bin/bash

USER="$1"
PASSWORD="$2"

# Select between recent stable (e.g. 1.4) or recent unstable (e.g. 1.5dev)
RELEASE_FLAG=""
if [[ "$3" == "staging"* ]]; then
  RELEASE_FLAG+=" --staging"
fi
if [[ "$3" == *"stable" ]]; then
  RELEASE_FLAG+=" --stable"
fi
if [[ "$3" == *"unstable" ]]; then
  RELEASE_FLAG+=" --unstable"
fi

DEV=""
if [[ -n "$4" && "$4" == "st2/"* ]]; then
  DEV="--dev=$4"
  shift
fi

FORCE_BRANCH=""
# This assumes that branch names will not be 48 hex digits, which is a pretty
# reasonable assumption
if [[ "$5" =~ ^[0-9a-fA-F]{48}$ ]]; then
  FORCE_BRANCH="--force-branch=$4"
  BRANCH="$4"
  shift
elif [[ -n "$4" ]]; then
  FORCE_BRANCH="--force-branch=$4"
  BRANCH="$4"
  shift
fi

LICENSE_KEY=""
if [[ -n "$4" ]]; then
  LICENSE_KEY="$4"
fi
if [[ -z "$RELEASE_FLAG" ]]; then
  echo -e "Use 'stable' for recent stable release, or 'unstable' to live on the edge."
  exit 2
fi

echo "*** Let's install some net tools ***"

DEBTEST=`lsb_release -a 2> /dev/null | grep Distributor | awk '{print $3}'`
RHTEST=`cat /etc/redhat-release 2> /dev/null | sed -e "s~\(.*\)release.*~\1~g"`

if [[ -n "$RHTEST" ]]; then
  echo "*** Detected Distro is ${RHTEST} ***"
  hash curl 2>/dev/null || { sudo yum install -y curl; sudo yum install -y nss; }
  sudo yum update -y curl nss
elif [[ -n "$DEBTEST" ]]; then
  echo "*** Detected Distro is ${DEBTEST} ***"
  sudo apt-get update
  sudo apt-get install -y curl
else
  echo "Unknown Operating System."
  echo "See list of supported OSes: https://github.com/StackStorm/st2vagrant/blob/master/README.md"
  exit 2
fi

RHMAJVER=`cat /etc/redhat-release | sed 's/[^0-9.]*\([0-9.]\).*/\1/'`

echo "*** Let's install some dev tools ***"

if [[ -n "$RHTEST" ]]; then
  if [[ "$RHMAJVER" == '6' ]]; then
    sudo yum install -y centos-release-SCL
    sudo yum install -y python27
    echo "LD_LIBRARY_PATH=/opt/rh/python27/root/usr/lib64:$LD_LIBRARY_PATH" | sudo tee -a /etc/environment
    sudo ln -s /opt/rh/python27/root/usr/bin/python /usr/local/bin/python
    sudo ln -s /opt/rh/python27/root/usr/bin/pip /usr/local/bin/pip
    source /etc/environment
  elif [[ "$RHMAJVER" == '7' ]]; then
    sudo yum install -y epel-release
    sudo yum install -y python
  fi
  sudo yum install -y python-pip git
elif [[ -n "$DEBTEST" ]]; then
  sudo apt-get install -y python2.7 python-pip git
fi

echo "*** Let's install some python tools ***"
sudo -H pip install --upgrade pip
sudo -H pip install virtualenv

echo "*** Let's install StackStorm  ***"

if [[ -n "$LICENSE_KEY" ]]; then
  curl -sSL https://raw.githubusercontent.com/StackStorm/bwc-installer/$BRANCH/scripts/bwc-installer.sh | bash -s -- --user=$USER --password=$PASSWORD $DEV $FORCE_BRANCH --license=$LICENSE_KEY $RELEASE_FLAG
else
  curl -sSL https://raw.githubusercontent.com/StackStorm/st2-packages/$BRANCH/scripts/st2_bootstrap.sh | bash -s -- --user=$USER --password=$PASSWORD $DEV $FORCE_BRANCH $RELEASE_FLAG
fi
