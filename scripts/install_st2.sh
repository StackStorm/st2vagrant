#!/bin/bash

DEBTEST=`lsb_release -a 2> /dev/null | grep Distributor | awk '{print $3}'`
RHTEST=`cat /etc/redhat-release 2> /dev/null | sed -e "s~\(.*\)release.*~\1~g"`

if [[ -n "$RHTEST" ]]; then
  echo "*** Detected Distro is ${RHTEST} ***"
  hash curl 2>/dev/null || { sudo yum install -y curl; sudo yum install -y nss; }
  sudo yum update -y curl nss
  curl -sSL https://stackstorm.com/packages/install.sh | bash -s -- --user=$1 --password=$2
elif [[ -n "$DEBTEST" ]]; then
  echo "*** Detected Distro is ${DEBTEST} ***"
  sudo apt-get install -y curl
  curl -sSL https://stackstorm.com/packages/install.sh | bash -s -- --user=$1 --password=$2
else
  echo "Unknown Operating System."
  echo "See list of supported OSes: https://github.com/StackStorm/st2vagrant/blob/master/README.md."
  exit 2
fi
