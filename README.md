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
- 쉘 커맨드를 통한 응답 파일 구성
- 리눅스 TAP 장치가 아닌 물리 인터페이스와 브릿지 된 Virtual Hub 구성

## 지원 되는 리눅스 배포판
|distro|version|arch|
|:--------|----------:|:------:|
|Debian|11|x86_64|
|Debian|10|x86_64|
|Debian|9|x86_64|
|Ubuntu|21.10|x86_64|
|Ubuntu|21.04|x86_64|
|Ubuntu|LTS-20.04|x86_64|
|Ubuntu|LTS-18.04|x86_64|
|Ubuntu|LTS-16.04|x86_64|
|CentOS|7|x86_64|

## 설치 방법
```
git clone -b master https://github.com/kerus1024/softether-vpn-autosetup ./setupvpn
cd setupvpn
bash setup.bash
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

