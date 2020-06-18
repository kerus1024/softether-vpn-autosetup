#!/bin/bash

echo
echo "서비스를 실행합니다."
echo

/bin/systemctl start softether-vpnserver

if [ "$?" -gt 0 ]; then
  echo -ne "${Red} 서비스가 실행되지 않았습니다 ${Color_Off}"
  exit
fi

/sbin/ifconfig tap_$SEVPN_NETWORK_LOCAL_BRIDGE_TAP_NAME

# SNAT 적용 및 dhcp는 se service에서 하므로 내용만 저장 해주면 된다
. ./10-dependencies/05-setup-service.sh


/bin/systemctl enable softether-vpnserver

echo Forwarding 적용
/sbin/sysctl -w net.ipv4.ip_forward=1
cat << _EOF_ >> /etc/sysctl.conf 
net.ipv4.ip_forward=1
_EOF_

sysctl -p


echo
echo
echo -ne "${Green} 완료되었습니다. ${Color_Off}"
echo
echo


