
#!/bin/bash
VAR_LOCAL_ENV_OS=AlmaLinux
VAR_LOCAL_ENV_CODENAME=9
VAR_LOCAL_ENV_PLATFORM=x86_64
VAR_LOCAL_ENV_DHCPD_SERVICE=dhcpd
check_environment() {
  if [ -f "/etc/os-release" ]; then
    source /etc/os-release

    baseid=`echo $VAR_LOCAL_ENV_OS | tr '[:upper:]' '[:lower:]'`
    targetid=`echo $ID | tr '[:upper:]' '[:lower:]'`

    if [ "$baseid" = "$targetid" ] && \
       [[ "$VERSION_ID" =~ ^$VAR_LOCAL_ENV_CODENAME ]] && \
       [ `uname -m` = "$VAR_LOCAL_ENV_PLATFORM" ]; then
      print_color cyan $VAR_LOCAL_ENV_OS $VAR_LOCAL_ENV_CODENAME $VAR_LOCAL_ENV_PLATFORM
      return
    fi

  else
    return 1
  fi
  return 1
}

install_dependencies () {
  run_without_print dnf update -y
  if (( $? )); then
    print_color red YUM 저장소 업데이트에 실패했어요.
    exit 1
  fi

  run_without_print dnf group install -y "Developmet Tools"
  if (( $? )); then
    print_color red YUM 필수 의존성 설치에 실패했어요.
    exit 1
  fi

  run_without_print dnf install -y wget net-tools dhcp-server tar iproute
  if (( $? )); then
    print_color red YUM 필수 의존성 설치에 실패했어요.
    exit 1
  fi
}

check_selinux () {

  # Alma 9
  selinux_path=/etc/sysconfig/selinux

  sestatus=`sestatus | head -n 1 | awk '{print $3}'`

  if [ "$sestatus" = "enabled" ]; then
    if [ ! -z "$VAR_LOCAL_SELINUX_DONT_DISABLE_SELINUX" ]; then
      print_color red SELinux가 활성화 되어 있어요.
      exit 1
    fi

    print_color cyan SELinux를 비활성화 합니다.
    disable_selinux
  fi

}

disable_selinux () {

  if `/sbin/setenforce 0`; then
    print_color green SELinux를 Permissive 모드로 변경에 성공했어요.
  else
    print_color red SELinux를 Permissive 모드로 변경에 실패했어요.
  fi

  print_color purple SELinux 설정 파일을 변경합니다.

  sed -i 's/^SELINUX=.*/SELINUX=disabled/' $selinux_path

  sestatus=`sestatus | head -n 1 | awk '{print $3}'`

  if [ "$sestatus" = "Enforcing" ]; then
    print_color red SELinux 모드 변경에 실패 했습니다.
  fi

}

install_dhcp_server () {
  run_without_print dnf install -y dhcp
  if (( $? )); then
    print_color red DHCP 서버 설치에 실패했어요
    exit 1
  fi
}

configure_dhcp_server () {
  print_color cyan DHCP 서버를 구성합니다.
  cp -f /usr/lib/systemd/system/dhcpd.service /etc/systemd/system/dhcpd.service
  if (( $? )); then
    print_color red 서비스 파일 복제에 실패했어요.
    exit 1
  fi

  print_color cyan debug "DHCP 서버 인터페이스 구성 변경 (sed)"
  sed -i -e "s/^ExecStart=.*/ExecStart=\/usr\/sbin\/dhcpd -f -cf \/etc\/dhcp\/dhcpd.conf -user dhcpd -group dhcpd --no-pid tap_${VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME}/" /etc/systemd/system/dhcpd.service

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
  run_without_print systemctl stop dhcpd
  run_without_print systemctl start dhcpd
  if (( $? )); then
    print_color red DHCP 서버 실행 완료
  else
    print_color red DHCP 서버 실행 실패
  fi
}

append_run_dhcp_on_interface_script () {
  if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_ENABLE" ] && [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP" ]; then
    print_color white debug DHCP 자동시작 스크립트를 추가합니다.
    cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<_EOF
systemctl stop dhcpd > /dev/null 2>&1
systemctl start dhcpd
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
  run_without_print dnf install -y radvd
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
  # Centos
  if `systemctl is-active firewalld >/dev/null 2>&1`; then
    print_color red firewalld가 실행중이에요.
  fi
}

append_allow_firewall_on_interface_script () {
  if `systemctl is-active firewalld >/dev/null 2>&1`; then
    print_color red firewalld가 실행중이에요.

    print_color cyan VPN 서버 실행시 firewalld 방화벽이 허용되도록 설정합니다.
    print_color cyan - 허용되는 포트는 $VAR_LOCAL_SEVPN_TCP_BASE_PORT/tcp, $VAR_LOCAL_SEVPN_OPENVPN_UDP_PORT/udp 입니다.
    cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<_EOF
firewall-cmd --zone=public --add-port=$VAR_LOCAL_SEVPN_TCP_BASE_PORT/tcp
firewall-cmd --zone=public --add-port=$VAR_LOCAL_SEVPN_OPENVPN_UDP_PORT/udp
_EOF
    cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.down.bash <<_EOF
firewall-cmd --zone=public --remove-port=$VAR_LOCAL_SEVPN_TCP_BASE_PORT/tcp
firewall-cmd --zone=public --remove-port=$VAR_LOCAL_SEVPN_OPENVPN_UDP_PORT/udp
_EOF

    if [ ! -z "$VAR_LOCAL_SEVPN_L2TPIPSEC" ]; then
      print_color cyan - 허용되는 포트는 500/udp, 1701/udp, 4500/udp 입니다.
      cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<_EOF
firewall-cmd --zone=public --add-port=500/udp
firewall-cmd --zone=public --add-port=1701/udp
firewall-cmd --zone=public --add-port=4500/udp
_EOF
      cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.down.bash <<_EOF
firewall-cmd --zone=public --remove-port=500/udp
firewall-cmd --zone=public --remove-port=1701/udp
firewall-cmd --zone=public --remove-port=4500/udp
_EOF
    fi

    if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP" ]; then
      print_color cyan - 허용되는 포트는 68/udp 입니다.
      cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<_EOF
firewall-cmd --add-service=dhcp
_EOF
      cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.down.bash <<_EOF
firewall-cmd --remove-service=dhcp
_EOF
    fi

    if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT" ]; then
print_color white - firewalld 를 위한 nat 허용 스크립트를 추가합니다.
      cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<_EOF
firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -s $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NETWORK/$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_MASKBIT -o $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT_MASQUERADE_OUTINTERFACE -j MASQUERADE
firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i \$1 -o $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT_MASQUERADE_OUTINTERFACE -j ACCEPT
firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i \$1 -o $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT_MASQUERADE_OUTINTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
_EOF
    fi

    if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT" ]; then
print_color white - firewalld 를 위한 nat v6 허용 스크립트를 추가합니다.
      cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<_EOF
firewall-cmd --direct --add-rule ipv6 nat POSTROUTING 0 -s $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NETWORK/$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_MASKBIT -o $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT_MASQUERADE_OUTINTERFACE -j MASQUERADE
firewall-cmd --direct --add-rule ipv6 filter FORWARD 0 -i \$1 -o $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT_MASQUERADE_OUTINTERFACE -j ACCEPT
firewall-cmd --direct --add-rule ipv6 filter FORWARD 0 -i \$1 -o $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT_MASQUERADE_OUTINTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
_EOF
    fi

  fi

}

install_iptables () {
  run_without_print dnf install -y iptables
  if (( $? )); then
    print_color red iptables 도구 설치에 실패했어요.
    exit 1
  fi
  return
}
