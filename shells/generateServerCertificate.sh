#!/bin/bash

# tar xvf EasyRSA-unix-v3.0.6.tgz 
# mv -v EasyRSA-v3.0.6 "/opt/easyrsa" 
# rm EasyRSA-unix-v3.0.6.tgz

/opt/easyrsa/easyrsa init-pki
/opt/easyrsa/easyrsa --batch build-ca nopass 
/opt/easyrsa/easyrsa build-server-full "$OVPN_SERVER_NAME" nopass 
/opt/easyrsa/easyrsa gen-dh 
openvpn --genkey --secret "$EASYRSA_PKI/ta.key" 
mkdir -p -v "/opt" 
cp "${EASYRSA_PKI}/ca.crt" "${EASYRSA_PKI}/dh.pem" "${EASYRSA_PKI}/ta.key" "${EASYRSA_PKI}/issued/${OVPN_SERVER_NAME}.crt" "${EASYRSA_PKI}/private/${OVPN_SERVER_NAME}.key" "${OVPN_DIR}" 

echo "server certificate ready"