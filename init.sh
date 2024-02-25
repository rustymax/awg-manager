#!/bin/bash

DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install build-essential curl make git wget -y

mkdir -p /opt/go
cd /opt/go
wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile
sleep 2
source /etc/profile
# if the go version does not show, then update the session

#Install amnezia-go
git clone https://github.com/amnezia-vpn/amneziawg-go.git /opt/amnezia-go
cd /opt/amnezia-go
sleep 1
source /etc/profile
sleep 1
make
#copy to amneziawg-go
cp /opt/amnezia-go/amneziawg-go /usr/bin/amneziawg-go

#Install amnezia-tools
git clone https://github.com/amnezia-vpn/amneziawg-tools.git /opt/amnezia-tools
cd /opt/amnezia-tools/src
make
make install
