#!/bin/bash
AUTHPAM_PLUGIN=`find /usr/lib -name "*openvpn-plugin-auth-pam.so"`;

bash generateServerCertificate.sh

if [[ "${OVPN_PROTOCOL}" == 'tcp' ]]
then 
    OVPN_PORT=1194
else
    OVPN_PORT=1149
fi

echo "port ${OVPN_PORT}
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
cipher AES-256-CBC
auth ${OVPN_SERVER_AUTH:-SHA256}
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log-append  /var/log/openvpn/openvpn.log
verb 6" > "${OVPN_DIR}"/server.conf 

# TODO :    buat pilihan untuk konfigurasi auth dan tls-auth
if [[ "${OVPN_SERVER_USETLS}" == 'true' ]]
then
    echo "tls-auth ${OVPN_DIR}/ta.key 0 #" >> "${OVPN_DIR}"/server.conf
fi

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
    echo -e "plugin ${AUTHPAM_PLUGIN} login
client-cert-not-required
username-as-common-name
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
iptables-save > /etc/iptables/rules.v4

echo "server configuration ready"