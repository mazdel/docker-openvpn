#!/bin/bash
echo "begin generating client config"

CLIENT_NAME=${1:-$OVPN_CLIENT_NAME}
CLIENT_PASS=${2:-$OVPN_CLIENT_PASS}

LAST_PWD=`pwd`;

cd /opt
if [[ ${OVPN_CLIENT_MODE} == "cert" ]]
then
    echo "using certificate"
    bash certClientConfig.sh ${CLIENT_NAME}
fi

if [[ ${OVPN_CLIENT_MODE} == "userpass" ]]
then
    echo "using auth pam"
    bash userpassClientConfig.sh ${CLIENT_NAME} ${CLIENT_PASS}
fi

if [[ "${OVPN_CLIENT_UNIQUE}" == 'true' ]]
then
    echo "" > ${OVPN_CLIENT_CCD}/${CLIENT_NAME}
    echo "config \"`ls ${OVPN_CLIENT_CCD}/${CLIENT_NAME}`\" created"
fi

cd ${LAST_PWD}