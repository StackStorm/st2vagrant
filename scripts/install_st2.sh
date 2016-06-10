#!/bin/bash

# Select between recent stable (e.g. 1.4) or recent unstable (e.g. 1.5dev)
if [[ $# > 2 ]]; then
  if [[ $3 == "stable" ]] || [[ $3 == "unstable" ]]
  then
    RELEASE_FLAG="--$3"
  else
    echo -e "Use 'stable' for recent stable release, or 'unstable' to live on the edge."
    exit 2
  fi
fi

DEBTEST=`lsb_release -a 2> /dev/null | grep Distributor | awk '{print $3}'`
RHTEST=`cat /etc/redhat-release 2> /dev/null | sed -e "s~\(.*\)release.*~\1~g"`

if [[ -n "$RHTEST" ]]; then
  echo "*** Detected Distro is ${RHTEST} ***"
  hash curl 2>/dev/null || { sudo yum install -y curl; sudo yum install -y nss; }
  sudo yum update -y curl nss
elif [[ -n "$DEBTEST" ]]; then
  echo "*** Detected Distro is ${DEBTEST} ***"
  sudo apt-get install -y curl
else
  echo "Unknown Operating System."
  echo "See list of supported OSes: https://github.com/StackStorm/st2vagrant/blob/master/README.md."
  exit 2
fi

curl -sSL https://stackstorm.com/packages/install.sh | bash -s -- --user=$1 --password=$2 $RELEASE_FLAG
