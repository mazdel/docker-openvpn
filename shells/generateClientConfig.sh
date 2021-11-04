#!/bin/bash

# First argument: Client identifier

KEY_DIR=${OVPN_CLIENT_DIR}/keys
OUTPUT_DIR=${OVPN_CLIENT_DIR}/files
BASE_CONFIG=${OVPN_CLIENT_DIR}/base.conf
CLIENT_NAME=${1:-$OVPN_CLIENT_NAME}

/opt/easyrsa/easyrsa build-client-full "$CLIENT_NAME" nopass 
cp "${EASYRSA_PKI}/ca.crt" "${EASYRSA_PKI}/ta.key" "${EASYRSA_PKI}/issued/$CLIENT_NAME.crt" "${EASYRSA_PKI}/private/$CLIENT_NAME.key" "$OVPN_CLIENT_DIR/keys"

for cnameCert in ${KEY_DIR}/*.crt
do
    clientCert=`basename ${cnameCert}`
    if [ ${clientCert} != 'ca.crt' ]
    then
        clientCname=`basename -s .crt ${clientCert}`;
        cat ${BASE_CONFIG} \
            <(echo -e '<ca>') \
            ${KEY_DIR}/ca.crt \
            <(echo -e '</ca>\n<cert>') \
            ${KEY_DIR}/${clientCname}.crt \
            <(echo -e '</cert>\n<key>') \
            ${KEY_DIR}/${clientCname}.key \
            <(echo -e '</key>\n<tls-auth>') \
            ${KEY_DIR}/ta.key \
            <(echo -e '</tls-auth>') \
            > ${OUTPUT_DIR}/${clientCname}.ovpn
    fi
done
