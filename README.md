# SoftEther VPN AutoSetup for Linux
- [SoftEther VPN](https://github.com/SoftEtherVPN/SoftEtherVPN_Stable) 서버의 설치를 자동으로 수행하기 위한 스크립트입니다.

## 지원 기능
- 설정 응답 파일을 통한 자동 구성
- SoftEther VPN Server (Standalone) 설치
- Virtual Hub 리눅스 로컬브릿지 설정 (가상 NAT인 SecureNAT의 내부 패킷 루핑 버그 및 처리량 손실을 방지합니다.)
- VPN 클라이언트를 위한 DHCPv4 Server 설정
- VPN 클라이언트를 IPv6 RA 구성
- VPN 클라이언트를 위한 NAT 설정
- L2TP over IPSec (Pre-shared key) 설정
- MS-SSTP 활성화
- OpenVPN UDP 클론 서버 활성화
- 단일 VPN 사용자 계정 자동 추가

## TO-DO
- NATv6이 아닌 IPv6 서브네팅 된 라우트 설정
- 스플릿 터널링와 같은 특수 목적을 위한 DHCP/RADVD 게이트웨이 알림 비활성화
- 리눅스 TAP 장치가 아닌 물리 인터페이스와 브릿지 된 Virtual Hub 구성

## 지원 되는 리눅스 배포판
|distro|version|arch|
|:--------|----------:|:------:|
|Debian|11|x86_64|
|Debian|10|x86_64|
|Debian|9|x86_64|
|Ubuntu|LTS-22.04|x86_64|
|Ubuntu|21.10|x86_64|
|Ubuntu|21.04|x86_64|
|Ubuntu|LTS-20.04|x86_64|
|Ubuntu|LTS-18.04|x86_64|
|Ubuntu|LTS-16.04|x86_64|
|CentOS|7|x86_64|

## 설치 방법
```bash
git clone -b master https://github.com/kerus1024/softether-vpn-autosetup ./setupvpn
cd setupvpn
bash setup.bash

```
반드시 `response.env` 파일을 편집하세요
### 커맨드를 이용한 설치
- 서버 관련

```
--tcp-port <tcp 포트 번호>           # SoftEther VPN tcp포트: 기본 포트는 5555 입니다.
                                    # 예: --tcp-port 443

--openvpn-udp-port <udp 포트 번호>   # OpenVPN UDP 클론 서버 포트: 기본 포트는 1194 입니다.

--no-enable-l2tpipsec               # L2TP/IPSec 프로토콜을 비활성화 합니다: 기본 활성화 됩니다.
--no-enable-sstp                    # Microsoft SSTP 프로토콜을 비활성화 합니다: 기본 활성화 됩니다.

--password <비밀번호>                # 서버 관리자 비밀번호를 지정합니다. 
                                    # 기본값은 '123467890' 입니다.
```

- Virtual Hub 관련

```
--set-vhub-name <vhub명>            # 신규 생성되는 Virtual Hub 명: 기본명은 'DHUB' 입니다.
                                    # 예: --set-hub-name remote1

--set-vhub-tapname <tap이름>         # 리눅스 TAP 인터페이스 장치에 사용되는 이름: 기본명은 'soft' 입니다.
                                    # 'soft'의 경우 'tap_soft'가 됩니다. 11자로 제한되며
                                    # 알파벳, 숫자, '_' 를 사용 할 수 있습니다.
                                    # 예: --set-vhub-tapname remote1

--add-user                          # Virtual Hub에 초기 사용자를 생성합니다.
--add-user-username <사용자명>       # 초기 사용자의 사용자명을 지정합니다.
--add-user-password <패스워드>       # 초기 사용자의 비밀번호를 지정합니다.
```

- IPv4 관련

```
--no-enable-ipv4                       # 가상 TAP 인터페이스 장치의 IPv4 를 비활성화 합니다.
--ipv4-network <네트워크ID>             # IPv4 네트워크 ID를 지정합니다: 기본값은 '10.255.255.0' 입니다.
--ipv4-maskbit <서브넷비트수>            # IPv4 네트워크 서브넷 비트수를 지정합니다: 기본값은 '24' 입니다.
--ipv4-localaddress <IP주소>            # 리눅스 서버의 IPv4 주소를 지정합니다: 기본값은 '10.255.255.254' 입니다.

--no-enable-ipv4-dhcp                  # IPv4 네트워크의 DHCP 서버를 비활성화 합니다.
--ipv4-dhcp-pool-start <DHCP시작주소>   # IPv4 DHCP 임대 풀 시작 주소를 지정합니다: 기본값은 '10.255.255.101' 입니다.
--ipv4-dhcp-pool-end <DHCP끝주소>      # IPv4 DHCP 임대 풀 끝 주소를 지정합니다: 기본값은 '10.255.255.199' 입니다.

--ipv4-dhcp-dns1 <DNS서버1>           # IPv4 DHCP 서버가 지정하는 DNS서버 1입니다: 기본값은 '1.1.1.1' 입니다.
--ipv4-dhcp-dns2 <DNS서버2>           # IPv4 DHCP 서버가 지정하는 DNS서버 2입니다: 기본값은 '1.0.0.1' 입니다.

--no-enable-ipv4-nat                 # VPN 클라이언트에 제공하는 IPv4 NAT 기능을 비활성화합니다.
--ipv4-nat-interface <인터페이스명>    # VPN 클라이언트에 제공하는 IPv4 NAT 마스커레이드의 출구 인터페이스를 지정합니다.
                                     # 기본값은 'auto-detect' 입니다.
                                     # 'auto-detect' 를 사용하면 스크립트는 기본 인터페이스를 찾습니다. 
                                     # 예: eth0 

#--ipv4-nat-sourceip <>           
```

- IPv6 관련

```
--ipv6-enable                         # 가상 TAP 인터페이스 장치의 IPv6 를 활성화 합니다.
--ipv6-network <네트워크ID>            # IPv6 네트워크 ID를 지정합니다: 기본값은 'FD00:FACE:B00C::' 입니다.
--ipv6-localaddress <IP주소>          # 리눅스 서버의 IPv6 주소를 지정합니다: 기본값은 'FD00:FACE:B00C::1' 입니다.

--no-enable-ipv6-radvd               # IPv6 네트워크의 RADVD 서버를 비활성화 합니다.
--ipv6-radvd-dns1 <DNS서버1>          # IPv6 RADVD 서버가 알리는 DNS서버 1입니다: 기본값은 '2606:4700:4700::1111' 입니다.
--ipv6-radvd-dns2 <DNS서버2>          # IPv6 RADVD 서버가 알리는 DNS서버 2입니다: 기본값은 '2606:4700:4700::1001' 입니다.

--no-enable-ipv6-nat                 # VPN 클라이언트에 제공하는 IPv6 NAT 기능을 비활성화합니다.
--ipv6-nat-interface <인터페이스명>    # VPN 클라이언트에 제공하는 IPv6 NAT 마스커레이드의 출구 인터페이스를 지정합니다.
                                     # 기본값은 'auto-detect' 입니다.
                                     # 'auto-detect' 를 사용하면 스크립트는 기본 인터페이스를 찾습니다. 
                                     # 예: eth0 
# 현재 routed ipv6 을 지원하지 않습니다.
#--ipv6-nat-sourceip <>
```

- 사용 예

```
bash <(curl -s https://raw.githubusercontent.com/kerus1024/softether-vpn-autosetup/master/tool/auto.bash ) \
--tcp-port 443 \
--password strong-admin-password \
--add-user --add-user-username secuser01 --add-user-password 1q2w3e4r \
--ipv4-nat-interface eth0 \
--ipv6-enable
```

## WARNING
https://raw.githubusercontent.com/SoftEtherVPN/SoftEtherVPN_Stable/master/WARNING.TXT

## CAUTION
- 기본적으로 root 권한이 필요합니다.
- 기존에 구성 된 DHCP 서버 설정이 손상될 수 있습니다.
- CentOS의 경우 SELinux가 파손됩니다.
- 환경에 따라 방화벽 구성에 문제가 될 수 있으며 방화벽이 리로드 된 경우 정상적으로 작동하지 않을 가능성이 있습니다.
- IPv6의 경우 radvd를 통한 SLAAC 구성만 지원하기 때문에 가상 네트워크의 경우 64비트 서브넷만 사용할 수 있습니다.
- IPv6의 경우 실험되지 않았습니다.

## SoftEther VPN
- SoftEther VPN의 TCP 리스너는 별도로 비활성화 하지 않는 한 동일한 TCP 포트에서 SoftEther TCP 서버와, OpenVPN TCP 서버를 응답합니다. 추가 설정으로 동일한 포트에서 MS-SSTP를 응답합니다.
- Site-to-Site VPN을 구성하기 위한 Cascade Connection 기능이 존재합니다.
- China 및 Japan 국가의 시스템에서 일부 기능이 제한되어 있습니다. (Cedar/Server.c)

```
// The following 'enterprise functions' are implemented on SoftEther VPN Server
// since March 19, 2014. However, these functions are disabled on
// SoftEther VPN Servers which run in Japan and China.
// 
// - RADIUS / NT Domain user authentication
// - RSA certificate authentication
// - Deep-inspect packet logging
// - Source IP address control list
// - syslog transfer
...
bool SiIsEnterpriseFunctionsRestrictedOnOpenSource(CEDAR *c)
```

