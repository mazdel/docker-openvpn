#!/bin/bash

# First argument: Client identifier

KEY_DIR=${OVPN_CLIENT_DIR}/keys
OUTPUT_DIR=${OVPN_CLIENT_DIR}/files
BASE_CONFIG=${OVPN_CLIENT_DIR}/base.conf
CLIENT_NAME=${1:-$OVPN_CLIENT_NAME}

/opt/easyrsa/easyrsa build-client-full "$CLIENT_NAME" nopass 
cp "${EASYRSA_PKI}/ca.crt" "${EASYRSA_PKI}/ta.key" "${EASYRSA_PKI}/issued/$CLIENT_NAME.crt" "${EASYRSA_PKI}/private/$CLIENT_NAME.key" "$OVPN_CLIENT_DIR/keys"

/usr/bin/openssl x509 -in "$OVPN_CLIENT_DIR/keys/$CLIENT_NAME.crt" -out "$OVPN_CLIENT_DIR/keys/$CLIENT_NAME.crt.pem" -outform PEM
/usr/bin/openssl rsa -in "$OVPN_CLIENT_DIR/keys/$CLIENT_NAME.key" -text > "$OVPN_CLIENT_DIR/keys/$CLIENT_NAME.key.pem"

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
            <(echo -e '</key>')\
            > ${OUTPUT_DIR}/${clientCname}.ovpn
            
        if [[ "${OVPN_SERVER_USETLS}" == 'true' ]]
        then
            cat <(echo -e '<tls-auth>') \
                ${KEY_DIR}/ta.key \
                <(echo -e '</tls-auth>') \
                >> ${OUTPUT_DIR}/${clientCname}.ovpn
        fi
    fi
done

echo "client ${CLIENT_NAME}.ovpn is ready"
echo "client config generated"