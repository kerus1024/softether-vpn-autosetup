#!/bin/bash
source ./lib/common.bash
print_clear

VAR_LOCAL_SEVPN_TCP_DEFAULT_PORT=5555
VAR_LOCAL_NAT4_MASQUERADE_OUTINTERFACE=
VAR_LOCAL_NAT6_MASQUERADE_OUTINTERFACE=
VAR_LOCAL_INCLUDE_ENV=
check_distro () {

  for iffile in ./envadapter/*.bash; do
    if [ -f "$iffile" ]; then
      print_color red debug run $iffile
      source $iffile
      if check_environment; then
        print_color red debug 찾았다!
        VAR_LOCAL_INCLUDE_ENV=$iffile
        return
      else
        continue
      fi
    else
      print_color red debug ?????
      echo ?????
      exit 1
    fi
  done

  return 1

}

check_listener () {

  # net-tools
  if ! `command -v netstat &> /dev/null`; then
    print_color red netstat 도구를 찾지 못했습니다.
    exit 1
  fi

  print_color red debug 사용중인 포트를 검사합니다.

  # SE가 기본적으로 5555 포트로 열리기 때문에 어쩔 수 없이 중단한다.
  tbase=`netstat -nl4t | grep ":$VAR_LOCAL_SEVPN_TCP_DEFAULT_PORT " 2>&1 | wc -l`
  if [ "$tbase" -gt "0" ]; then
    print_color red TCP 포트 [$VAR_LOCAL_SEVPN_TCP_DEFAULT_PORT] 는 사용중이기 때문에 중단합니다.
    exit 1
  fi

  tbase=`netstat -nl4t | grep ":$VAR_LOCAL_SEVPN_TCP_BASE_PORT " 2>&1 | wc -l`
  if [ "$tbase" -gt "0" ]; then
    print_color red TCP 포트 [$VAR_LOCAL_SEVPN_TCP_BASE_PORT] 는 사용중이기 때문에 중단합니다.
    exit 1
  fi

  for udpport in { $VAR_LOCAL_SEVPN_OPENVPN_UDP_PORT, 67, 500, 1701, 4500 }; do

    tuport=`netstat -nl4u | grep ":$udpport " 2>&1 | wc -l `

    if [ "$tuport" -gt "0" ]; then
      print_color red UDP 포트 [$udpport] 는 사용중입니다.
    fi

  done

  print_color red debug 포트 검사 완료

  return
}

VAR_LOCAL_IPTABLES_SYSTEM=
check_iptables () {
  if ! `command -v iptables &> /dev/null`; then
    print_color red iptables 도구를 찾지 못했습니다.
    install_iptables
  fi
  return
}

# NAT을 위한 기본 인터페이스 확인
check_interface () {
  default_mark='auto-detect'

  # NATv4 확인
  if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_ENABLE" ] && [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT" ]; then
    if [ "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT_MASQUERADE_OUTINTERFACE" = "$default_mark" ]; then 
      print_color cyan NATv4를 위한 기본 인터페이스를 찾습니다.
      default_interface4=`ip -4 route show | grep -Po -e '^default[^\^]+dev\s\K[^\s]+' 2>/dev/null`
      if (( $? )) || [ -z "$default_interface4" ]; then
        print_color red 기본 IPv4 라우트를 찾지 못했습니다.
        exit 1
      fi
      VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT_MASQUERADE_OUTINTERFACE=$default_interface4
    fi
  
    determine_ipaddress4=`ip -4 addr show $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT_MASQUERADE_OUTINTERFACE | grep 'scope global' | grep -Po '(?<=inet )[^\s\/]+' 2>/dev/null`
    if (( $? )) || [ -z "$determine_ipaddress4" ]; then
      print_color red 기본 IPv4 주소를 찾지 못했습니다.
      exit 1
    fi
    print_color white inline 감지한 인터페이스
    print_color cyan inline $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT_MASQUERADE_OUTINTERFACE
    print_color yellow inline $determine_ipaddress4
    echo
    sleep 1
  fi

  # NATv6 확인
  if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_ENABLE" ] && [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT" ]; then
    if [ "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT_MASQUERADE_OUTINTERFACE" = "$default_mark" ]; then 
      print_color cyan NATv6를 위한 기본 인터페이스를 찾습니다.
      default_interface6=`ip -6 route show | grep -Po -e '^default[^\^]+dev\s\K[^\s]+' 2>/dev/null`
      if (( $? )) || [ -z "$default_interface6" ]; then
        print_color red 기본 IPv6 라우트를 찾지 못했습니다.
        exit 1
      fi
      VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT_MASQUERADE_OUTINTERFACE=$default_interface6
    fi
  
    determine_ipaddress6=`ip -6 addr show $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT_MASQUERADE_OUTINTERFACE | grep 'scope global' | grep -Po '(?<=inet6 )[^\s\/]+' 2>/dev/null`
    if (( $? )) || [ -z "$determine_ipaddress6" ]; then
      print_color red 기본 IPv6 주소를 찾지 못했습니다.
      exit 1
    fi
    print_color white inline 감지한 인터페이스
    print_color cyan inline $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT_MASQUERADE_OUTINTERFACE
    print_color yellow inline $determine_ipaddress6
    echo
    sleep 1
  fi

}


echo '

        SOFTETHER VPN AUTO SETUP

'

# 응답파일 로드
if [ -f "./response.env" ]; then
  source ./response.env
else
  print_color red 응답 파일이 없어요.
  exit 1
fi 

if ! is_shell_safe_text $VAR_LOCAL_SEVPN_ADMINPASSWORD || ! is_shell_safe_text $VAR_LOCAL_SEVPN_FIRSTHUB_FIRSTVPNUSERPASSWORD; then
  print_color red 사용 불가능한 패스워드에요.
  exit 1
fi

# 리눅스 배포판 검사
if ! check_distro; then
  print_color red 지원하지 않는 배포판이에요.
  exit 1
fi

# 루트 권한 검사
if ! is_root; then
  print_color red Root 권한이 필요해요.
  exit 1
fi

# 임시 파일 생성
if ! `mkdir -p $VAR_LOCAL_TMP_BINDIR`; then
  print_color red 임시 디렉터리를 생성 할 수 없어요.
  exit 1
fi

# 배포판 설정파일 재로딩
source ./envadapter/_reference.bash
source $VAR_LOCAL_INCLUDE_ENV

# SELinux 검사 및 비활성화
print_color cyan SELinux를 확인합니다.
check_selinux

# Firewall 소프트웨어 검사
print_color cyan 시스템에 설치 된 방화벽을 확인합니다.
check_firewall

# Dependency 설치
print_color cyan 의존성 소프트웨어 설치를 시작합니다.
install_dependencies

# NAT을 위한 기본 인터페이스 확인
check_interface

# 사용 중인 TCP, UDP 포트 검사
print_color cyan 시스템에 사용 가능한 TCP, UDP 포트를 확인합니다.
check_listener

# iptables 검사
print_color cyan 시스템의 iptables 툴을 확인합니다.
check_iptables

# DHCP 서버 설치 및 DHCP4 서버 설정
if [ -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_ENABLE" ] && [ -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP" ]; then
  print_color cyan DHCP 서버 설치를 시작합니다.
  if [ -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP" ] || [ -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP_DNS" ] || [ -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT" ]; then
    print_color red 미지원: 현재 DHCP+NAT을 통한 설정만 지원합니다.
    exit 1
  fi
  install_dhcp_server
  configure_dhcp_server
  #restart_dhcp_server: 인터페이스 family 활성화 되기 전 까진 서비스가 fault됨.
fi

# DHCP6 (RADVD RA) 설치 및 서버 설정
if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_ENABLE" ] && [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_RADVD" ]; then
  print_color cyan RADVD 서버 설치를 시작합니다.

  if [ "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_MASKBIT" != "64" ]; then
    print_color red IPv6 64 비트 prefix만 지원합니다.
    exit 1
  fi

  install_dhcp6_server
  configure_dhcp6_server
  #restart_dhcp6_server: 인터페이스 family 활성화 되기 전 까진 서비스가 fault됨.
fi

# SEVPN 파일 내려받기
print_color cyan SEVPN 바이너리 파일을 내려받습니다.
set_remote_softether_package $VAR_LOCAL_ENV_PLATFORM
run_without_print wget -4 --timeout=10 --tries=5 --retry-connrefused -O $VAR_LOCAL_PACKAGE_PATH $ENV_REMOTE_SOFTETHER_PACKAGE

if (( $? )) || [ ! -f "$VAR_LOCAL_PACKAGE_PATH" ]; then
  print_color red SEVPN 바이너리 파일을 내려받지 못했습니다.
fi

print_color cyan SEVPN 바이너리 압축을 해제합니다.
run_without_print tar xzf $VAR_LOCAL_PACKAGE_PATH --strip 1 -C $VAR_LOCAL_TMP_BINDIR
if (( $? )); then
  print_color red SEVPN 바이너리 압축해제에 실패했어요.
fi
print_color white debug 압축해제 완료 $VAR_LOCAL_TMP_BINDIR

# SEVPN 빌드
print_color cyan SEVPN 바이너리 파일을 빌드합니다.
VAR_LOCAL_SCRIPT_WORKINGDIR=`pwd`
print_color white debug 쉘 현재 디렉터리 변경: "$VAR_LOCAL_SCRIPT_WORKINGDIR -> $VAR_LOCAL_TMP_BINDIR"
cd $VAR_LOCAL_TMP_BINDIR/
print_color white debug 현재 디렉터리 : `pwd`
# 언젠가 부터 make 시 라이선스 관련하여 묻는 프롬프트가 사라졌다.
run_without_print make
if (( $? )) || [ ! -f "$VAR_LOCAL_TMP_BINDIR/vpnserver" ]; then
  print_color red SEVPN 바이너리 파일 빌드에 실패했어요.
fi
print_color white debug 빌드완료

if [ -f "$VAR_LOCAL_WORKINGDIR/vpn_server.config" ]; then
  print_color red debug 기존 vpn_server.config 이 존재
  cp -f $VAR_LOCAL_WORKINGDIR/vpn_server.config /tmp/vpn_server.config.old
  #\rm -f $VAR_LOCAL_WORKINGDIR/vpn_server.config
  #rm -f $VAR_LOCAL_WORKINGDIR/vpn_server.config
fi

# 디렉터리 제거에 유의
if [ -d "$VAR_LOCAL_WORKINGDIR" ]; then
  print_color red 기존 VPN 서버 디렉터리를 제거합니다.
  rm -rf $VAR_LOCAL_WORKINGDIR
fi

# SEVPN 설치
if ! `mkdir -p $VAR_LOCAL_WORKINGDIR`; then 
  print_color red $VAR_LOCAL_WORKINGDIR 디렉터리 생성에 실패했어요.
  exit 1
fi

cp -f $VAR_LOCAL_TMP_BINDIR/vpnserver $VAR_LOCAL_WORKINGDIR/vpnserver
cp -f $VAR_LOCAL_TMP_BINDIR/vpncmd    $VAR_LOCAL_WORKINGDIR/vpncmd
cp -f $VAR_LOCAL_TMP_BINDIR/hamcore.se2 $VAR_LOCAL_WORKINGDIR/hamcore.se2

chmod 700 $VAR_LOCAL_WORKINGDIR/vpnserver
chmod 700 $VAR_LOCAL_WORKINGDIR/vpncmd
chmod 600 $VAR_LOCAL_WORKINGDIR/hamcore.se2

if [ ! -f "$VAR_LOCAL_WORKINGDIR/vpnserver" ]; then
  print_color red VPN서버 이동에 실패했어요.
  exit 1
fi

_vpnserver=$VAR_LOCAL_WORKINGDIR/vpnserver
__vpncmd=$VAR_LOCAL_WORKINGDIR/vpncmd

# SEVPN dryrun
print_color cyan 임시로 SEVPN 서버를 시작합니다.
run_without_print $_vpnserver start
if (( $? )); then 
  print_color red VPN 서버 시작에 실패했어요.
  exit 1
fi

# 기본 설정이 될 때 까지 대기한다.
print_color cyan SEVPN 서버 가동을 위해 잠시 대기 합니다.
sleep 3
print_color white debug dry-run...
_vpncmd="$__vpncmd /SERVER 127.0.0.1:$VAR_LOCAL_SEVPN_TCP_DEFAULT_PORT"
print_color green debug vpncmd: $_vpncmd
run_without_print $_vpncmd /cmd About
if (( $? )); then 
  print_color red 임시로 실행한 VPN서버에 연결이 실패했어요.
  exit 1
fi

# 관리 비밀번호 설정
run_without_print $_vpncmd /cmd ServerPasswordSet $VAR_LOCAL_SEVPN_ADMINPASSWORD
if (( $? )); then
  print_color red SEVPN 관리 패스워드 설정에 실패했어요.
  exit 1
fi

sleep 1

_vpncmd="$_vpncmd /PASSWORD:$VAR_LOCAL_SEVPN_ADMINPASSWORD"


# 기본 TCP 포트 제거 및 신규 포트 할당
print_color cyan SEVPN의 TCP 포트 리스너를 생성 후 기존 포트를 제거합니다.
exit_count=0
run_without_print $_vpncmd /cmd ListenerDelete 443 || (( exit_count++ ));
run_without_print $_vpncmd /cmd ListenerDelete 992 || (( exit_count++ ));
run_without_print $_vpncmd /cmd ListenerDelete 1194 || (( exit_count++ ));
if [ "$VAR_LOCAL_SEVPN_TCP_BASE_PORT" != "$VAR_LOCAL_SEVPN_TCP_DEFAULT_PORT" ]; then
  run_without_print $_vpncmd /cmd ListenerCreate $VAR_LOCAL_SEVPN_TCP_BASE_PORT || (( exit_count++ ));
  run_without_print $_vpncmd /cmd ListenerDelete 5555 || (( exit_count++ ));
fi

if (( $exit_count )); then
  print_color red 포트 리스너 생성과 제거에 문제가 생겼습니다.
  exit 1
fi

# 신규 포트로 재연결
print_color cyan SEVPN의 새로 생성한 TCP 서버에 연결을 시도합니다.
vpncmd="$__vpncmd /SERVER 127.0.0.1:$VAR_LOCAL_SEVPN_TCP_BASE_PORT /PASSWORD:$VAR_LOCAL_SEVPN_ADMINPASSWORD"
run_without_print $vpncmd /cmd About
if (( $? )); then
  print_color red 새로 생성한 TCP 서버에 연결이 실패했습니다.
  exit 1
fi

# 기본 Virtual Hub 제거
print_color cyan SEVPN의 기본 Virtual Hub를 제거합니다.
run_without_print $vpncmd /cmd HubDelete DEFAULT
if (( $? )); then
  print_color red 기본 Virtual Hub를 제거에 실패했어요.
  exit 1
fi

# 기본 설정
print_color cyan SEVPN의 서버 설정을 시작합니다.
exit_count=0
run_without_print $vpncmd /cmd HubCreate $VAR_LOCAL_SEVPN_FIRSTHUB_NAME /PASSWORD || (( exit_count++ ));
run_without_print $vpncmd /cmd BridgeCreate $VAR_LOCAL_SEVPN_FIRSTHUB_NAME /DEVICE:$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME /TAP:yes || (( exit_count++ ));
run_without_print $vpncmd /cmd ServerCipherSet $VAR_LOCAL_SEVPN_ENCRYPTION_CIPHER || (( exit_count++ ));
if [ ! -z "$VAR_LOCAL_SEVPN_SSTP" ]; then
  print_color white + MS-SSTP를 활성화 합니다.
  run_without_print $vpncmd /cmd SstpEnable yes || (( exit_count++ ));
fi

if [ ! -z "$VAR_LOCAL_SEVPN_L2TPIPSEC" ]; then
  print_color white + L2TP/IPSEC을 활성화 합니다.
  run_without_print $vpncmd /cmd IPsecEnable /L2TP:yes /L2TPRAW:no /ETHERIP:no /PSK:$VAR_LOCAL_SEVPN_L2TPIPSEC_PRESHAREDKEY /DEFAULTHUB:$VAR_LOCAL_SEVPN_FIRSTHUB_NAME || (( exit_count++ ));
fi
run_without_print $vpncmd /adminhub:$VAR_LOCAL_SEVPN_FIRSTHUB_NAME /cmd UserCreate $VAR_LOCAL_SEVPN_FIRSTHUB_FIRSTVPNUSER /GROUP:none /REALNAME:none /NOTE:none || (( exit_count++ ));
run_without_print $vpncmd /adminhub:$VAR_LOCAL_SEVPN_FIRSTHUB_NAME /cmd UserPasswordSet $VAR_LOCAL_SEVPN_FIRSTHUB_FIRSTVPNUSER /PASSWORD:$VAR_LOCAL_SEVPN_FIRSTHUB_FIRSTVPNUSERPASSWORD || (( exit_count++ ));

# 시큐리티 로그 주기 변경
run_without_print $vpncmd /adminhub:$VAR_LOCAL_SEVPN_FIRSTHUB_NAME /cmd LogSwitchSet security /SWITCH:month || (( exit_count++ ));
# 패킷로그 비활성화
run_without_print $vpncmd /adminhub:$VAR_LOCAL_SEVPN_FIRSTHUB_NAME /cmd LogDisable packet || (( exit_count++ ));

# OpenVPN 포트 변경
run_without_print $vpncmd /cmd OpenVpnEnable yes /PORTS:$VAR_LOCAL_SEVPN_OPENVPN_UDP_PORT || (( exit_count++ ));

# SEVPN Client에게 Virtual HUB 목록 광고기능 제거
#...

if (( $exit_count )); then
  print_color red debug - ExitCount: $exit_count
  print_color red SEVPN 서버 설정에 문제가 발생했어요.
  exit 1
fi

if [ -z "$VAR_LOCAL_SEVPN_DDNSCLIENT" ]; then
  # DDNS클라이언트를 비활성화 하는 경우 기본 OpenVPN 인증서를 변경해야한다.
  # DDNS클라이언트를 시작하자마자 어떻게 비활성화 할 수 있을까?
  print_color cyan SEVPN DDNSClient를 비활성화 합니다
  print_color red 미지원
  exit 1
fi

# SEVPN 종료
print_color cyan SEVPN 서버설정이 끝났습니다.
print_color cyan 임시로 실행한 VPN 서버를 종료합니다.
run_without_print $_vpnserver stop
print_color red debug 기존에 생성 된 필요 없는 파일 삭제..
run_without_print rm -rf $VAR_LOCAL_WORKINGDIR/packet_log
run_without_print rm -rf $VAR_LOCAL_WORKINGDIR/security_log

# IP 포워딩 활성화
print_color cyan 커널 IP 포워딩을 활성화합니다.
run_without_print sysctl -w net.ipv4.ip_forward=1
cat > /etc/sysctl.d/99-ip4-forward.conf <<_EOF
net.ipv4.ip_forward=1
_EOF

if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_ENABLE" ]; then
  print_color white 커널 IPv6 포워딩을 활성화합니다.
  run_without_print sysctl -w net.ipv6.conf.all.forwarding=1
  cat > /etc/sysctl.d/99-ip6-forward.conf <<_EOF
sysctl -w net.ipv6.conf.all.forwarding=1
_EOF
fi

# supporter 설치
print_color cyan SEVPN Supporter를 설치합니다.
mkdir -p $VAR_LOCAL_WORKINGDIR/supporter
mkdir -p $VAR_LOCAL_WORKINGDIR/lib
cp -r $VAR_LOCAL_SCRIPT_WORKINGDIR/supporter/* $VAR_LOCAL_WORKINGDIR/supporter
cp -r $VAR_LOCAL_SCRIPT_WORKINGDIR/lib/* $VAR_LOCAL_WORKINGDIR/lib
if (( $? )); then
  print_color red Supporter 복사에 오류가 발생했어요.
  exit 1
fi

find $VAR_LOCAL_WORKINGDIR/supporter/ -name '*.bash' -exec chmod 700 {} \;

# ifup
rm -f $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash
cat > $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<< '#!/bin/bash'
if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_ENABLE" ]; then
  cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<_EOF 
sysctl -w net.ipv6.conf.\$1.disable_ipv6=1
sysctl -w net.ipv6.conf.\$1.use_tempaddr=0
sysctl -w net.ipv6.conf.\$1.forwarding=0
sysctl -w net.ipv6.conf.\$1.accept_ra=0
sysctl -w net.ipv6.conf.\$1.autoconf=0
_EOF
fi

if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_ENABLE" ] && [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT" ]; then
  print_color white debug - IPv4 NAT 설정 up 스크립트를 생성합니다.
  cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<_EOF
ip addr add $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_LOCALADDRESS/$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_MASKBIT dev \$1
iptables -D FORWARD -i \$1 -m state --state ESTABLISHED,RELATED -j ACCEPT 2> /dev/null
iptables -D FORWARD -i \$1 -j ACCEPT 2> /dev/null
iptables -t nat -D POSTROUTING -s $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NETWORK/$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_MASKBIT -o $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT_MASQUERADE_OUTINTERFACE -j MASQUERADE 2> /dev/null
iptables -A FORWARD -i \$1 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i \$1 -j ACCEPT
iptables -t nat -A POSTROUTING -s $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NETWORK/$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_MASKBIT -o $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT_MASQUERADE_OUTINTERFACE -j MASQUERADE
_EOF
fi

if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_ENABLE" ] && [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT" ]; then
  print_color white debug - IPv6 NAT 설정 up 스크립트를 생성합니다.
  cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.up.bash <<_EOF
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.conf.default.forwarding=0
sysctl -w net.ipv6.conf.\$1.disable_ipv6=0
sysctl -w net.ipv6.conf.\$1.use_tempaddr=0
sysctl -w net.ipv6.conf.\$1.forwarding=1
sysctl -w net.ipv6.conf.\$1.accept_ra=0
sysctl -w net.ipv6.conf.\$1.autoconf=0
sysctl -w net.ipv6.conf.\$1.accept_redirects=0
ip -6 addr add $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_LOCALADDRESS/$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_MASKBIT dev \$1
ip6tables -D FORWARD -i \$1 -m state --state ESTABLISHED,RELATED -j ACCEPT 2> /dev/null
ip6tables -D FORWARD -i \$1 -j ACCEPT 2> /dev/null
ip6tables -t nat -D POSTROUTING -s $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NETWORK/$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_MASKBIT -o $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT_MASQUERADE_OUTINTERFACE -j MASQUERADE 2> /dev/null
ip6tables -A FORWARD -i \$1 -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A FORWARD -i \$1 -j ACCEPT
ip6tables -t nat -A POSTROUTING -s $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NETWORK/$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_MASKBIT -o $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT_MASQUERADE_OUTINTERFACE -j MASQUERADE
_EOF
fi

# ifdown
rm -f $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.down.bash
cat > $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.down.bash <<< '#!/bin/bash'

if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_ENABLE" ] && [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT" ]; then
  print_color white debug - IPv4 NAT 설정 down 스크립트를 생성합니다.
  cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.down.bash <<_EOF 
iptables -D FORWARD -i \$1 -m state --state ESTABLISHED,RELATED -j ACCEPT 2> /dev/null
iptables -D FORWARD -i \$1 -j ACCEPT 2> /dev/null
iptables -t nat -D POSTROUTING -s $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NETWORK/$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_MASKBIT -o $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT_MASQUERADE_OUTINTERFACE -j MASQUERADE 2> /dev/null
_EOF
fi

if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_ENABLE" ] && [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT" ]; then
  print_color white debug - IPv6 NAT 설정 down 스크립트를 생성합니다.
  cat >> $VAR_LOCAL_WORKINGDIR/supporter/interfaces.d/$VAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME.down.bash <<_EOF 
ip6tables -D FORWARD -i \$1 -m state --state ESTABLISHED,RELATED -j ACCEPT 2> /dev/null
ip6tables -D FORWARD -i \$1 -j ACCEPT 2> /dev/null
ip6tables -t nat -D POSTROUTING -s $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NETWORK/$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_MASKBIT -o $VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT_MASQUERADE_OUTINTERFACE -j MASQUERADE 2> /dev/null
_EOF
fi

# DHCP 시작 스크립트 추가 ( ip가 할당 되지 않으면 dhcp서버 시작이 안된다. )
append_run_dhcp_on_interface_script
# 방화벽 허용 스크립트 추가
append_allow_firewall_on_interface_script

# 서비스(systemd) 설치
print_color cyan SEVPN 시스템 서비스를 설치합니다.
cat > /etc/systemd/system/vpnserver.service <<_
[Unit]
Description=SoftEther VPN Server
After=network.target auditd.service

[Service]
Type=forking
ExecStart=$VAR_LOCAL_WORKINGDIR/vpnserver start
ExecStop=$VAR_LOCAL_WORKINGDIR/vpnserver stop
ExecStartPost=
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
_
chmod 755 /etc/systemd/system/vpnserver.service

cat > /etc/systemd/system/vpnserver-supporter.service << _
[Unit]
Description=SoftEther Supporter Service
Wants=vpnserver.service
After=vpnserver.service

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=$VAR_LOCAL_WORKINGDIR/supporter
ExecStart=$VAR_LOCAL_WORKINGDIR/supporter/run.bash
KillMode=process

[Install]
WantedBy=default.target
_
chmod 755 /etc/systemd/system/vpnserver-supporter.service

systemctl daemon-reload

# 서비스 실행
print_color cyan SEVPN 서비스를 시작합니다.
run_without_print systemctl stop vpnserver.service vpnserver-supporter.service
run_without_print systemctl start vpnserver.service vpnserver-supporter.service
run_without_print systemctl enable vpnserver.service vpnserver-supporter.service

sleep 5
# DHCP서버 올라올때까지 시간이 걸린다.
if [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_ENABLE" ] && [ ! -z "$VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP" ]; then
  if `systemctl is-active $VAR_LOCAL_ENV_DHCPD_SERVICE >/dev/null 2>&1`; then
    print_color green DHCP 서버가 정상적으로 실행중입니다.
  else
    print_color red DHCP 서버가 정상적으로 실행되고 있지 않습니다.
  fi
fi
# 마무리
echo
print_color white 설치가 완료되었습니다.
