# softether-vpn-autosetup
SoftEther VPN AutoSetup for Linux

## Features
- SoftEther VPN Server (Standalone)
- Linux Local Bridge (prevents sevpn securenat internal loops)
- NAT Setup
- DHCP Server (for Local Bridge VPN Client) Setup

- L2TP over IPSec (Pre-shared key)
- MS-SSTP

## Supports Distros
- CentOS 8 x86_64
- CentOS 7 x86_64
- Debian 10 (buster) x86_64
- Debian 9 (stretch) x86_64
- Ubuntu 20 (focal) x86_64
- Ubuntu 18 (bionic) x86_64 

## Install
```
bash <(curl -s https://raw.githubusercontent.com/kerus1024/softether-vpn-autosetup/master/get-autosetup.sh)
 ```


## CAUTION
Do not use on production servers. Data may be lost.
