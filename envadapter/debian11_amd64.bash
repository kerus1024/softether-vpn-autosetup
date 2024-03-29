#!/bin/bash
VAR_LOCAL_ENV_OS=Debian
VAR_LOCAL_ENV_CODENAME=bullseye
VAR_LOCAL_ENV_PLATFORM=x86_64
VAR_LOCAL_ENV_DHCPD_SERVICE=isc-dhcp-server
check_environment() {

  if [ "`lsb_release -si`" = "$VAR_LOCAL_ENV_OS" ] && \
   [ "`lsb_release -cs`" = "$VAR_LOCAL_ENV_CODENAME" ] && \
   [ "`uname -m`" = "$VAR_LOCAL_ENV_PLATFORM" ]; then 
    print_color cyan $VAR_LOCAL_ENV_OS $VAR_LOCAL_ENV_CODENAME $VAR_LOCAL_ENV_PLATFORM
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

  run_without_print apt-get install -y "build-essential" net-tools wget tar iproute2
  if (( $? )); then
    print_color red APT 필수 의존성 설치에 실패했어요.
    exit 1
  fi

}

check_selinux () {
  return
}

disable_selinux () {
  return
}

install_dhcp_server () {
  run_without_print apt-get install -y isc-dhcp-server
  if (( $? )); then
    print_color red DHCP 서버 설치에 실패했어요
    exit 1
  fi
  # ISC DHCP Server 패키지는 설치 후 자동으로 load된다.
  run_without_print systemctl stop isc-dhcp-server
}

# configure_dhcp_server <ACTIVATE_INTERFACE>
# /etc/init.d/isc-dhcp-server
configure_dhcp_server () {
  print_color cyan DHCP 서버를 구성합니다.
  cat > /etc/default/isc-dhcp-server <<_EOF
INTERFACESv4="tap_${VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME}"  
_EOF
  cat > /etc/dhcp/dhcpd.conf << _EOF
subnet ${VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NETWORK} netmask ${VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NETMASK} {
  authoritative;
  range ${VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP_START} ${VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP_END};
  option domain-name-servers ${VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP_DNS1},${VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP_DNS2};
  option domain-name "${VAR_LOCAL_SEVPN_ALTERNATIVE_HOSTNAME}.vpn";
  option routers ${VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_LOCALADDRESS};
  default-lease-time 7200;
  max-lease-time 86400;
}
_EOF
}

restart_dhcp_server () {
  run_without_print systemctl stop isc-dhcp-server
  run_without_print systemctl start isc-dhcp-server
  if (( $? )); then
    print_color red DHCP 서버 실행 완료
  else
    print_color red DHCP 서버 실행 실패
  fi
}

append_run_dhcp_on_interface_script () {
  if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_ENABLE" ] && [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP" ]; then
    print_color white debug DHCP 자동시작 스크립트를 추가합니다.
    print_color white debug DHCP 서버 자동시작 스크립트를 추가합니다.
    cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<_EOF
systemctl stop isc-dhcp-server > /dev/null 2>&1
systemctl start isc-dhcp-server
_EOF
  fi

  if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_ENABLE" ] && [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_RADVD" ]; then
    print_color white debug RADVD 자동시작 스크립트를 추가합니다.
    cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<_EOF
systemctl stop radvd > /dev/null 2>&1
systemctl start radvd
_EOF
  fi
}

install_dhcp6_server () {
  run_without_print apt-get install -y radvd
  if (( $? )); then
    print_color red RADVD 서버 설치에 실패했어요
    exit 1
  fi
}

configure_dhcp6_server () {
  print_color cyan RADVD 서버를 구성합니다.
  cat > /etc/radvd.conf <<_EOF
interface tap_${VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME}
{
	AdvSendAdvert on;
	prefix $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NETWORK/$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_MASKBIT {};
	route $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_LOCALADDRESS/64 {};
	RDNSS $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_RADVD_DNS1 {};
	RDNSS $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_RADVD_DNS2 {};
};
_EOF
}

restart_dhcp6_server () {
  run_without_print systemctl stop radvd
  run_without_print systemctl start radvd
  if (( $? )); then
    print_color red RADVD 서버 실행 완료
  else
    print_color red RADVD 서버 실행 실패
  fi
}
check_firewall () {
  return
}

append_allow_firewall_on_interface_script () {
  return
}

install_iptables () {
  run_without_print apt-get install -y iptables
  if (( $? )); then
    print_color red iptables 도구 설치에 실패했어요.
    exit 1
  fi
  return
}