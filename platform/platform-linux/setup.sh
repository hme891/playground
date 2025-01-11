#!/bin/bash
#configure the PPA on local machine and install ansible
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done; sudo apt-get clean
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done; sudo apt-get install -y software-properties-common
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done; sudo apt-add-repository -y ppa:ansible/ansible
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done; sudo apt-get update -y
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done; sudo apt-get install -y ansible
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done; sudo apt-get install -y openssl
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done; sudo apt-get install -y nginx
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done; sudo apt-get install -y net-tools
