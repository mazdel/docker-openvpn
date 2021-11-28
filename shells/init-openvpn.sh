#!/bin/bash


mkdir -p -v /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
echo "device created"

if [ ! -f ${EASYRSA_PKI}/ca.crt ]
then 
    bash serverConfig.sh
    bash baseClientConfig.sh
    bash generateClient.sh    
    ln -s `pwd`/generateClient.sh /usr/bin/
fi

iptables-restore < /etc/iptables/rules.v4
openvpn --config ${OVPN_DIR}/server.conf

exec "$@"
#commit message "change generateClientConfig.sh -> generateClient.sh so it would be shorter and ez to remember it"