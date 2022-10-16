#!/bin/bash

# First argument: Client identifier

KEY_DIR=${OVPN_CLIENT_DIR}/keys
OUTPUT_DIR=${OVPN_CLIENT_DIR}/files
BASE_CONFIG=${OVPN_CLIENT_DIR}/base.conf
CLIENT_NAME=${1:-$OVPN_CLIENT_NAME}
CLIENT_PASS=${2:-$OVPN_CLIENT_PASS}


if getent passwd "${CLIENT_NAME}" > /dev/null
then
    echo ">>> user ${CLIENT_NAME} already exist, can't create new user <<<"
else

    /opt/easyrsa/easyrsa build-client-full "$CLIENT_NAME" nopass 
    cp "${EASYRSA_PKI}/ca.crt" "${EASYRSA_PKI}/ta.key" "${EASYRSA_PKI}/issued/$CLIENT_NAME.crt" "${EASYRSA_PKI}/private/$CLIENT_NAME.key" "$OVPN_CLIENT_DIR/keys"
    /usr/bin/openssl x509 -in "$OVPN_CLIENT_DIR/keys/$CLIENT_NAME.crt" -out "$OVPN_CLIENT_DIR/keys/$CLIENT_NAME.crt.pem" -outform PEM
    /usr/bin/openssl rsa -in "$OVPN_CLIENT_DIR/keys/$CLIENT_NAME.key" -text > "$OVPN_CLIENT_DIR/keys/$CLIENT_NAME.key.pem"

    echo "${CLIENT_NAME}:${CLIENT_PASS}::openvpn:::/bin/false" | newusers
    echo "done creating ${CLIENT_NAME} as new user"

    cat ${BASE_CONFIG} \
            <(echo -e '<ca>') \
            ${KEY_DIR}/ca.crt \
            <(echo -e '</ca>\n<cert>') \
            ${KEY_DIR}/${CLIENT_NAME}.crt \
            <(echo -e '</cert>\n<key>') \
            ${KEY_DIR}/${CLIENT_NAME}.key \
            <(echo -e '</key>')\
            > ${OUTPUT_DIR}/${CLIENT_NAME}.ovpn
            
    if [[ "${OVPN_SERVER_USETLS}" == 'true' ]]
    then
        cat <(echo -e '<tls-auth>') \
            ${KEY_DIR}/ta.key \
            <(echo -e '</tls-auth>') \
            >> ${OUTPUT_DIR}/${CLIENT_NAME}.ovpn
    fi
    echo "done, client ${CLIENT_NAME}.ovpn is ready"
fi

echo "client config generated"