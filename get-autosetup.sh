#!/bin/bash

if [ `command -v curl > /dev/null 2>&1 ; echo $?` -gt "0" ]; then
  echo "curl 을 찾을 수 없습니다."
  echo "RHEL           : yum -y install curl"
  echo "Debian/Ubuntu  : apt -y install curl"
  exit
fi

if [ `command -v tar > /dev/null 2>&1 ; echo $?` -gt "0" ]; then
  echo "tar 를 찾을 수 없습니다."
  echo "RHEL           : yum -y install tar"
  echo "Debian/Ubuntu  : apt -y install tar"
  exit
fi

/usr/bin/curl -L https://github.com/kerus1024/softether-vpn-autosetup/archive/master.tar.gz > softether-vpn-autosetup.tar.gz
mkdir softether-vpn-autosetup
tar xzf softether-vpn-autosetup.tar.gz --strip 1 -C ./softether-vpn-autosetup
cd ./softether-vpn-autosetup
sudo bash run.sh
