#!/bin/bash

# wget -4 --timeout=10 --tries=5 --retry-connrefused
# ENV_REMOTE_SOFTETHER_PACKAGE="https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.38-9760-rtm/softether-vpnserver-v4.38-9760-rtm-2021.08.17-linux-x64-64bit.tar.gz"
VAR_LOCAL_ENV_OS=Debian
VAR_LOCAL_ENV_CODENAME=bullseye
VAR_LOCAL_ENV_PLATFORM=x86_64
check_environment() {

  if [ "`lsb_release -si`" = "$VAR_LOCAL_ENV_OS" ] && \
   [ "`lsb_release -cs`" = "$VAR_LOCAL_ENV_CODENAME" ] && \
   [ "`uname -m`" = "$VAR_LOCAL_ENV_PLATFORM" ]; then 
    print_color cyan Debian bullseye x86-64
    return
  else
    print_color red debug 해당 되지 않음
  fi

  return 1

}

install_dependencies () {

  run_without_print apt-get update -y
  if (( $? )); then
    print_color red APT 저장소 업데이트에 실패했어요.
    exit 1
  fi

  run_without_print apt-get install -y "build-essential" net-tools wget net-tools tar iproute2
  if (( $? )); then
    print_color red APT 필수 의존성 설치에 실패했어요.
    exit 1
  fi

}

check_iptables () {
  return
}

check_selinux () {
  return
}

disable_selinux () {
  return
}

install_dhcp_server () {
  #run_without_print apt-get install -y isc-dhcp-server
  true
  if (( $? )); then
    print_color red DHCP 서버 설치에 실패했어요
    exit 1
  fi
}

install_dhcp6_server () {
  # IPv6
  return
}

check_firewall () {
  return
}

append_firewall () {
  return
}

install_sevpn () {
  return
}

install_iptables () {
  return
}

install_service () {
  return
}
