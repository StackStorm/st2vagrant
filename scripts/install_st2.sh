#!/bin/bash

set -e

echo "$@"

while getopts "u:p:r:t:d:b:k:v:" option; do
  case "${option}" in
    u) ST2_USER=${OPTARG};;
    p) ST2_PASSWORD=${OPTARG};;
    r) RELEASE=${OPTARG};;
    t) REPO_TYPE=${OPTARG};;
    d) DEV="--dev=${OPTARG}";;
    b) BRANCH=${OPTARG};;
    v) VERSION=${OPTARG};;
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

if [[ -n "$VERSION" ]]; then
  VERSION_FLAG="--version=${VERSION}"

  # If BRANCH isn't specified
  # But VERSION is a specified *released* version
  if [[ -z "$BRANCH" && "$VERSION" =~ ^[[:digit:]]{1,}\.[[:digit:]]{1,}\.[[:digit:]]{1,} ]]; then
    # Default the st2-packages branch to the version branch
    BRANCH="v$(echo $VERSION | sed 's/^\([[:digit:]]*\.[[:digit:]]*\).*/\1/')"
  fi
fi

# Default BRANCH to master
BRANCH="${BRANCH:-master}"

BRANCH_FLAG="--force-branch=$BRANCH"


echo "*** Let's install some net tools ***"

DEBTEST=$(lsb_release -a 2> /dev/null | grep Distributor | awk '{print $3}')  # Ubuntu
DEBCODENAME=$(lsb_release -a 2> /dev/null | grep Codename | awk '{print $2}')  # xenial|bionic
RHTEST=''

echo $DEBTEST
echo $DEBCODENAME
# For ST2 v3.4 on Ubuntu Xenial
if [[ "$DEBTEST" == "Ubuntu" && "$DEBCODENAME" == "xenial" ]]; then
  if [[ -z "$VERSION" || "$VERSION" == 3.4* ]]; then
    # Add a flag to automatically install and use the Python 3 repository from the deadsnakes PPA
    XENIAL_ST2_3_4_PYTHON3_FLAG="--u16-add-insecure-py3-ppa"
  fi
fi

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
  sudo yum install -y epel-release
  sudo yum install -y python3
  sudo yum install -y python3-pip git
elif [[ -n "$DEBTEST" ]]; then
  sudo apt-get install -y python3 python3-pip git
fi

echo "*** Let's install some python tools ***"
sudo -H pip3 install --upgrade pip\<21
sudo -H pip3 install --upgrade virtualenv==16.6.0

echo "*** Let's install StackStorm  ***"

echo "--user=$ST2_USER --password=$ST2_PASSWORD $DEV $BRANCH_FLAG $RELEASE_FLAG $VERSION_FLAG $XENIAL_ST2_3_4_PYTHON3_FLAG"
curl -sSL https://raw.githubusercontent.com/StackStorm/st2-packages/$BRANCH/scripts/st2_bootstrap.sh | bash -s -- --user=$ST2_USER --password=$ST2_PASSWORD $DEV $BRANCH_FLAG $RELEASE_FLAG $REPO_TYPE $VERSION_FLAG $XENIAL_ST2_3_4_PYTHON3_FLAG
