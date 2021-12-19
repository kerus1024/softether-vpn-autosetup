#!/bin/bash

# wget -4 --timeout=10 --tries=5 --retry-connrefused
ENV_REMOTE_SOFTETHER_PACKAGE="https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.38-9760-rtm/softether-vpnserver-v4.38-9760-rtm-2021.08.17-linux-x64-64bit.tar.gz"

install_dependencies () {
  apt update -y
  apt install -y "build-essential"
  apt install -y wget net-tools isc-dhcp-server iptables-persistent tar iproute2
}

check_iptables () {
  echo "iptables이 없습니다."
  exit 1
}

check_selinux () {

}

disable_selinux () {

}

install_dhcp_server () {

}

install_dhcp6_server () {
  # IPv6
}

check_firewall () {
  
}

append_firewall () {

}

install_sevpn () {

}

install_iptables () {

}

install_service () {

}
