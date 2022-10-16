FROM debian:buster
LABEL maintainer="delyachmad@gmail.com"
WORKDIR /root

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install nano openvpn wget htop net-tools iptables iptables-persistent


ENV OVPN_DIR="/opt/openvpn" \
	OVPN_SERVER_NAME="server" \
	OVPN_SERVER_NETWORK="175.43.21.0 255.255.255.0" \
	OVPN_SERVER_IPV4="175.43.21.1 255.255.255.0" \
	OVPN_SERVER_DNS="8.8.8.8" \
	OVPN_SERVER_CIPHER="AES-256-CBC"\
	OVPN_SERVER_AUTH="SHA256"\
	OVPN_SERVER_USETLS="true"\
	OVPN_SERVER_AS_GATEWAY="false" \
	OVPN_CLIENT_NAME="ovpnclient" \
	OVPN_CLIENT_PASS="nopass"

ENV OVPN_CLIENT_DIR="${OVPN_DIR}/client"

ENV	OVPN_CLIENT_CCD="${OVPN_CLIENT_DIR}/config" \
	OVPN_PROTOCOL="tcp" \
  	OVPN_REMOTE_ADDRESS="192.168.1.1" \
  	OVPN_REMOTE_PORT="1194" \
	OVPN_CLIENT_UNIQUE="false" \
	OVPN_CLIENT_COMPRESS="true" \
	OVPN_CLIENT_MODE="onlycert" 
#	or you can choose
#	OVPN_CLIENT_MODE="userpass"
#	OVPN_CLIENT_MODE="userpasswithcert"

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

COPY shells/* ./

RUN chmod +x *.sh

EXPOSE 1149/udp
EXPOSE 1194/tcp

VOLUME [ "$OVPN_DIR" ]

ENTRYPOINT ["./init-openvpn.sh"]

CMD ["bash"]



#TODO : complete this
