#!/bin/bash

# First argument: Client identifier

KEY_DIR=${OVPN_CLIENT_DIR}/keys
OUTPUT_DIR=${OVPN_CLIENT_DIR}/files
BASE_CONFIG=${OVPN_CLIENT_DIR}/base.conf
CLIENT_NAME=${1:-$OVPN_CLIENT_NAME}
CLIENT_PASS=${2:-$OVPN_CLIENT_PASS}

cp "${EASYRSA_PKI}/ca.crt" "${EASYRSA_PKI}/ta.key" "$OVPN_CLIENT_DIR/keys"

if getent passwd "${CLIENT_NAME}" > /dev/null
then
    echo ">>> user ${CLIENT_NAME} already exist, can't create new user <<<"
else
    echo "${CLIENT_NAME}:${CLIENT_PASS}::openvpn:::/bin/false" | newusers
    echo "done creating ${CLIENT_NAME} as new user"
fi

# references, noob here is giving thanks to the authors
# https://www.tecmint.com/create-multiple-user-accounts-in-linux/
# https://www.cyberciti.biz/tips/linux-how-to-create-multiple-users-accounts-in-batch.html
# https://stackoverflow.com/questions/714915/using-the-passwd-command-from-within-a-shell-script
# https://ccm.net/faq/790-changing-password-via-a-script

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<tls-auth>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/${CLIENT_NAME}.ovpn

echo "client ${CLIENT_NAME}.ovpn is ready"
echo "client config generated"