#!/bin/bash
source ./envadapter/debian11_amd64.bash
VAR_LOCAL_ENV_OS=Ubuntu
VAR_LOCAL_ENV_CODENAME=impish
VAR_LOCAL_ENV_PLATFORM=x86_64
VAR_LOCAL_ENV_DHCPD_SERVICE=isc-dhcp-server
check_firewall () {
  check=`ufw status | grep ': active' | wc -l`
  if [ "$check" -ne 0 ]; then
    print_color red UFW 방화벽이 활성화 되어 있습니다.
  fi
}
append_allow_firewall_on_interface_script () {
  check=`ufw status | grep ': active' | wc -l`
  if [ "$check" -ne 0 ]; then
    print_color red UFW 방화벽이 활성화 되어 있습니다.
  
    print_color cyan VPN 서버 실행시 UFW 방화벽이 허용되도록 설정합니다.
    print_color cyan - 허용되는 포트는 $VAR_LOCAL_SEVPN_TCP_BASE_PORT/tcp, $VAR_LOCAL_SEVPN_OPENVPN_UDP_PORT/udp 입니다.
    cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<_EOF
ufw allow $VAR_LOCAL_SEVPN_TCP_BASE_PORT/tcp
ufw allow $VAR_LOCAL_SEVPN_OPENVPN_UDP_PORT/udp
_EOF
    cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.down.bash <<_EOF
ufw delete allow $VAR_LOCAL_SEVPN_TCP_BASE_PORT/tcp
ufw delete allow $VAR_LOCAL_SEVPN_OPENVPN_UDP_PORT/udp
_EOF

    if [ ! -z "$VAR_LOCAL_SEVPN_L2TPIPSEC" ]; then
      print_color cyan - 허용되는 포트는 500/udp, 1701/udp, 4500/udp 입니다.
      cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<_EOF
ufw allow 500/udp
ufw allow 1701/udp
ufw allow 4500/udp
_EOF
      cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.down.bash <<_EOF
ufw delete allow 500/udp
ufw delete allow 1701/udp
ufw delete allow 4500/udp
_EOF
    fi

    if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_ENABLE" ] && [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP" ]; then
      print_color cyan - 허용되는 포트는 68/udp 입니다.
      cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<_EOF
ufw allow 68/udp
_EOF
      cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.down.bash <<_EOF
ufw delete allow 68/udp
_EOF
    fi

  fi

}