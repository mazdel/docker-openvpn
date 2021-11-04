FROM debian:buster
LABEL maintainer="delyachmad@gmail.com"
WORKDIR /root

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install nano openvpn wget htop net-tools iptables iptables-persistent


ENV OVPN_DIR="/opt/openvpn" \
	OVPN_SERVER_NAME="server" \
	OVPN_SERVER_NETWORK="33.22.11.0 255.255.255.0" \
	OVPN_SERVER_IPV4="33.22.11.1 255.255.255.0" \
	OVPN_SERVER_DNS="8.8.8.8" \
	OVPN_SERVER_AS_GATEWAY="false" \
	OVPN_CLIENT_NAME="client1" 
ENV OVPN_CLIENT_DIR="${OVPN_DIR}/client"
ENV	OVPN_CLIENT_CCD="${OVPN_CLIENT_DIR}/config" \
	OVPN_PROTOCOL="tcp" \
    OVPN_REMOTE_ADDRESS="192.168.1.1" \
    OVPN_REMOTE_PORT="1194"

ENV EASYRSA_REQ_COUNTRY="ID" \
	EASYRSA_REQ_PROVINCE="Jawa Timur" \
	EASYRSA_REQ_CITY="Surabaya" \
	EASYRSA_REQ_ORG="AkTro" \
	EASYRSA_REQ_EMAIL="personal@gmail.com" \
	EASYRSA_REQ_OU="Invis Personal Unit"  \
	EASYRSA_PKI="/opt/easyrsa/pki"

WORKDIR /opt

RUN wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.6/EasyRSA-unix-v3.0.6.tgz\
	&& tar xvf EasyRSA-unix-v3.0.6.tgz \
	&& mv -v EasyRSA-v3.0.6 "/opt/easyrsa" \
	&& rm EasyRSA-unix-v3.0.6.tgz

# # create certificate
# RUN /opt/easyrsa/easyrsa init-pki \
#     && /opt/easyrsa/easyrsa --batch build-ca nopass \
#     && /opt/easyrsa/easyrsa build-server-full "$OVPN_SERVER_NAME" nopass \
#     && /opt/easyrsa/easyrsa gen-dh \
#     && openvpn --genkey --secret "$EASYRSA_PKI/ta.key" \
#     && mkdir -p -v "${OVPN_DIR}" \
#     && cp "${EASYRSA_PKI}/ca.crt" "${EASYRSA_PKI}/dh.pem" "${EASYRSA_PKI}/ta.key" "${EASYRSA_PKI}/issued/${OVPN_SERVER_NAME}.crt" "${EASYRSA_PKI}/private/${OVPN_SERVER_NAME}.key" "${OVPN_DIR}" \
#     && echo "certificate ready"

COPY shells/* ./

RUN chmod +x init-openvpn.sh

EXPOSE 1149/udp
EXPOSE 1194/tcp

VOLUME [ "$OVPN_DIR" ]

ENTRYPOINT ["./init-openvpn.sh"]

CMD ["bash"]



#TODO : complete this
