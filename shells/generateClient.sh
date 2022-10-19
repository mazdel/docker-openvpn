#!/bin/bash
echo $(date +"%F %T")" > begin generating client config with mode << ${OVPN_CLIENT_MODE} >>"

CLIENT_NAME=${1:-$OVPN_CLIENT_NAME}
CLIENT_PASS=${2:-$OVPN_CLIENT_PASS}

LAST_PWD=`pwd`;

cd /opt
if [[ ${OVPN_CLIENT_MODE} == "onlycert" ]]
then
    echo "using certificate only"
    bash certClientConfig.sh ${CLIENT_NAME}
fi

if [[ ${OVPN_CLIENT_MODE} == "userpass" ]]
then
    echo "using auth pam"
    bash userpassClientConfig.sh ${CLIENT_NAME} ${CLIENT_PASS}
fi

if [[ ${OVPN_CLIENT_MODE} == "userpasswithcert" ]]
then
    echo "using auth pam"
    bash userpassCertClientConfig.sh ${CLIENT_NAME} ${CLIENT_PASS}
fi


if [[ "${OVPN_CLIENT_UNIQUE}" == 'true' ]]
then
    echo "" > ${OVPN_CLIENT_CCD}/${CLIENT_NAME}
    echo $(date +"%F %T")" > config \"`ls ${OVPN_CLIENT_CCD}/${CLIENT_NAME}`\" created"
fi

cd ${LAST_PWD}