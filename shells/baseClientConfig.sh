#!/bin/bash
echo "creating user base config"

mkdir -p -v "$OVPN_CLIENT_DIR/keys" "$OVPN_CLIENT_DIR/files" "${OVPN_CLIENT_CCD}"

echo "client
dev tun
proto ${OVPN_PROTOCOL}
remote ${OVPN_REMOTE_ADDRESS} ${OVPN_REMOTE_PORT}
resolv-retry infinite
nobind
user nobody
group nogroup
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
comp-lzo
verb 6
key-direction 1
">${OVPN_CLIENT_DIR}/base.conf

if [[ ${OVPN_CLIENT_MODE} == "userpass" ]]
then
  echo -e "auth-user-pass\n" >> ${OVPN_CLIENT_DIR}/base.conf
fi
echo "client base config done"