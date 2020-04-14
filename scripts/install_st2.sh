#!/bin/bash

set -e

echo "$@"

while getopts "u:p:r:t:d:b:k:" option; do
  case "${option}" in
    u) ST2_USER=${OPTARG};;
    p) ST2_PASSWORD=${OPTARG};;
    r) RELEASE=${OPTARG};;
    t) REPO_TYPE=${OPTARG};;
    d) DEV="--dev=${OPTARG}";;
    b) BRANCH=${OPTARG};;
    k) LICENSE_KEY=${OPTARG};;
  esac
done


# Select between recent stable (e.g. 1.4) or recent unstable (e.g. 1.5dev)
if [[ "$RELEASE" == "stable" || "$RELEASE" == "unstable" ]]; then
  RELEASE_FLAG="--${RELEASE}"
else
  echo "Use 'stable' for recent stable release, or 'unstable' to live on the edge, not '$RELEASE'."
  exit 2
fi

if [[ "$REPO_TYPE" == "staging" ]]; then
  REPO_TYPE="--staging"
fi

BRANCH_FLAG="--force-branch=$BRANCH"


echo "*** Let's install some net tools ***"

DEBTEST=$(lsb_release -a 2> /dev/null | grep Distributor | awk '{print $3}')
DEBCODENAME=$(lsb_release -a 2> /dev/null | grep Codename | awk '{print $2}')
RHTEST=''
if [[ -e /etc/redhat-release ]]; then
  RHTEST=$(cat /etc/redhat-release 2> /dev/null | sed -e "s~\(.*\)release.*~\1~g")
  RHMAJVER=$(cat /etc/redhat-release | sed 's/[^0-9.]*\([0-9.]\).*/\1/')
fi

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

echo "*** Let's install some dev tools ***"

if [[ -n "$RHTEST" ]]; then
  if [[ "$RHMAJVER" == '6' ]]; then
    sudo yum install -y centos-release-SCL
    sudo yum install -y python27
    echo "LD_LIBRARY_PATH=/opt/rh/python27/root/usr/lib64:$LD_LIBRARY_PATH" | sudo tee -a /etc/environment
    sudo ln -s /opt/rh/python27/root/usr/bin/python /usr/local/bin/python
    sudo ln -s /opt/rh/python27/root/usr/bin/pip /usr/local/bin/pip
    source /etc/environment
    sudo yum install -y python-pip git
  elif [[ "$RHMAJVER" == '7' ]]; then
    sudo yum install -y epel-release
    sudo yum install -y python
    sudo yum install -y python-pip git
  else
    sudo yum install -y epel-release
    sudo yum install -y python3
    sudo yum install -y python3-pip git
  fi
elif [[ -n "$DEBTEST" ]]; then
  if [[ "$DEBCODENAME" == "xenial" ]]; then
    sudo apt-get install -y python2.7 python-pip git
  else
    sudo apt-get install -y python3 python3-pip git
  fi
fi

echo "*** Let's install some python tools ***"
if [[ "$RHMAJVER" == '6' || "$RHMAJVER" == '7' || "$DEBCODENAME" == 'xenial' ]]; then
  sudo -H pip install --upgrade pip
  sudo -H pip install virtualenv
else
  sudo -H pip3 install --upgrade pip
  sudo -H pip3 install virtualenv
fi

echo "*** Let's install StackStorm  ***"

if [[ -n "$LICENSE_KEY" ]]; then
  echo "--user=$ST2_USER --password=$ST2_PASSWORD $DEV $BRANCH_FLAG $RELEASE_FLAG --license=$LICENSE_KEY"
  curl -sSL https://raw.githubusercontent.com/StackStorm/bwc-installer/$BRANCH/scripts/bwc-installer.sh | bash -s -- --user=$ST2_USER --password=$ST2_PASSWORD $DEV $BRANCH_FLAG $RELEASE_FLAG $REPO_TYPE --license=$LICENSE_KEY
else
  echo "--user=$ST2_USER --password=$ST2_PASSWORD $DEV $BRANCH_FLAG $RELEASE_FLAG"
  curl -sSL https://raw.githubusercontent.com/StackStorm/st2-packages/$BRANCH/scripts/st2_bootstrap.sh | bash -s -- --user=$ST2_USER --password=$ST2_PASSWORD $DEV $BRANCH_FLAG $RELEASE_FLAG $REPO_TYPE
fi
