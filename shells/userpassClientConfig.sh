#!/bin/bash

# First argument: Client identifier

KEY_DIR=${OVPN_CLIENT_DIR}/keys
OUTPUT_DIR=${OVPN_CLIENT_DIR}/files
BASE_CONFIG=${OVPN_CLIENT_DIR}/base.conf
CLIENT_NAME=${1:-$OVPN_CLIENT_NAME}
CLIENT_PASS=${2:-$OVPN_CLIENT_PASS}

cp "${EASYRSA_PKI}/ca.crt" "${EASYRSA_PKI}/ta.key" "$OVPN_CLIENT_DIR/keys"

#check if user exist or create login new user
if getent passwd "${OVPN_CLIENT_NAME}" > /dev/null
then
    echo "user already exist, can't create new user"
else
    echo "${OVPN_CLIENT_NAME}:${OVPN_CLIENT_PASS}::openvpn:::/bin/false" | newusers
    echo "done creating ${OVPN_CLIENT_NAME} as new user"
fi
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