#!/bin/bash

mkdir -p -v /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
echo "device created"

bash serverConfig.sh
bash baseClientConfig.sh
bash generateClientConfig.sh

ln -s `pwd`/generateClientConfig.sh /usr/bin/

openvpn --config ${OVPN_DIR}/server.conf

#this line prevent docker to stop immediately
exec "$@"
#while getopts 
