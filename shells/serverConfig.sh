#!/bin/bash
AUTHPAM_PLUGIN=`find /usr/lib -name "*openvpn-plugin-auth-pam.so"`;

bash generateServerCertificate.sh

echo "port 1194
proto ${OVPN_PROTOCOL}
dev tun
ca ${OVPN_DIR}/ca.crt
cert ${OVPN_DIR}/${OVPN_SERVER_NAME}.crt
key ${OVPN_DIR}/${OVPN_SERVER_NAME}.key
dh ${OVPN_DIR}/dh.pem

topology subnet
server ${OVPN_SERVER_NETWORK}
ifconfig ${OVPN_SERVER_IPV4}
ifconfig-pool-persist /var/log/openvpn/ipp.txt
config ${OVPN_DIR}/route.conf
push \"dhcp-option DNS ${OVPN_SERVER_DNS}\"

client-config-dir ${OVPN_CLIENT_CCD}
client-to-client
keepalive 10 60
tls-auth ${OVPN_DIR}/ta.key 0 # This file is secret
cipher AES-256-CBC
auth SHA256
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log-append  /var/log/openvpn/openvpn.log
verb 6" > "${OVPN_DIR}"/server.conf 

# TODO :    buat pilihan untuk konfigurasi auth dan tls-auth

if [[ "${OVPN_CLIENT_UNIQUE}" == 'false' ]]
then
    echo "duplicate-cn" >> "${OVPN_DIR}"/server.conf
fi

if [[ "${OVPN_SERVER_AS_GATEWAY}" == 'true' ]]
then
    echo "push \"redirect-gateway def1 bypass-dhcp\"" >> "${OVPN_DIR}"/server.conf 
fi


if [[ "${OVPN_PROTOCOL}" == 'tcp' ]]
then
    echo "explicit-exit-notify 0" >> "${OVPN_DIR}"/server.conf 
fi

if [[ ${OVPN_CLIENT_MODE} == "userpass" ]]
then
    echo -e "plugin ${AUTHPAM_PLUGIN} login\n
    client-cert-not-required\n
    username-as-common-name\n
    " >> "${OVPN_DIR}"/server.conf
    
    groupadd openvpn
fi


echo "
push \"route 192.168.3.0 255.255.255.0\"
push \"route 192.168.7.0 255.255.255.0\"
push \"route 172.17.0.0 255.255.0.0\"
push \"topology subnet\"
" > "${OVPN_DIR}"/route.conf

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo "server configuration ready"