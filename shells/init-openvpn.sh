#!/bin/bash


mkdir -p -v /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
echo "device created"

if [ ! -f ${EASYRSA_PKI}/ca.crt ]
then 
    bash serverConfig.sh
    bash baseClientConfig.sh
    bash generateClientConfig.sh    
    ln -s `pwd`/generateClientConfig.sh /usr/bin/
fi

# TODO :    buat ketika server openvpn belum jalan maka jalankan iptables dibawah ini dulu
iptables-restore < /etc/iptables/rules.v4
openvpn --config ${OVPN_DIR}/server.conf

exec "$@"

#commit message "fix iptables got reset each container restarted"