# awg-manager

AmneziaWG manager allow initialize AmneziaWG server and manage users.

You can start the AmneziaWG server with one command, and then create (and delete) users.


```bash
Usage: ./awg-manager.sh [<options>] [command [arg]]
Options:
 -i : Init (Create server keys and configs)
 -c : Create new user
 -d : Delete user
 -L : Lock user
 -U : Unlock user
 -p : Print user config
 -u <user> : User identifier (uniq field for vpn account)
 -s <server> : Server host for user connection
 -I : Interface (default auto)
 -h : Usage
 ```

## Quick start

Run server (bare-metal or VPS) with Ubuntu 20.02, 22.02

### Install AmneziaWG

```bash
apt update && apt upgrade -y
apt install build-essential curl git wget -y

#install Golang
mkdir -p /opt/go
cd /opt/go
wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile
source $HOME/.profile
# if the go version does not show, then update the session

#Install amnezia-go
git clone https://github.com/amnezia-vpn/amneziawg-go.git /opt/amnezia-go
cd /opt/amnezia-go
make
#copy to amneziawg-go
cp /opt/amnezia-go/amneziawg-go /usr/bin

#Install amnezia-tools
git clone https://github.com/amnezia-vpn/amneziawg-tools.git /opt/amnezia-tools
cd /opt/amnezia-tools/src
make
make install
```

### Setup

 - Download this script [wg-manager.sh](https://danuk.github.io/wg-manager/wg-manager.sh) from GitHub
 - Initialize WireGuard server: `./wg-manager.sh -i -s YOUR_SERVER_IP`
 - Add your user: `./wg-manager.sh -c -u my_user -p > wg-client.conf`
 - Install WireGuard on the client
 - Start client with config `wg-client.conf`


