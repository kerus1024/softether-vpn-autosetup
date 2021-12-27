# SoftEther VPN AutoSetup for Linux

## 지원기능
- 설정 응답 파일을 통한 자동 구성
- SoftEther VPN Server (Standalone) 설치
- Virtual Hub 리눅스 로컬브릿지 설정 (SecureNAT의 내부 패킷 루핑 버그를 방지합니다)
- VPN 클라이언트를 위한 DHCPv4 Server 설정
- VPN 클라이언트를 위한 NAT 설정
- L2TP over IPSec (Pre-shared key) 설정
- MS-SSTP 활성화
- OpenVPN UDP 클론 서버 활성화
- 단일 VPN 사용자 계정 자동 추가

## TO-DO
- 쉘 커맨드를 통한 응답 파일 구성
- IPv6 DHCP (RA) 구성

## 지원 되는 리눅스 배포판
- Debian 11 (bullseye) x86_64

## 설치 방법
```
git clone -b ng https://github.com/kerus1024/softether-vpn-autosetup ./setupvpn
cd setupvpn
bash setup.bash
```

## WARNING
- https://raw.githubusercontent.com/SoftEtherVPN/SoftEtherVPN_Stable/master/WARNING.TXT