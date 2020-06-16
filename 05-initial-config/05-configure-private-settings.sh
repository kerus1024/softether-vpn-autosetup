#!/bin/bash

SEVPN_LOCAL_VPN_ENV_TMP="./tmp/localvpn_env"
SEVPN_LOCAL_VPN_DHCPD_TMP="./tmp/dhcpd_env"

echo
echo
echo VPN 네트워크에 관한 설정
echo
echo

function set_vpn_server_env() {


  # DEFAULT HUBNAME 설정
  hubname=""
  while true; do
    hubname=""
    read -p "HubName을 지정해주세요.  [${SEVPN_NETWORK_DEFAULT_HUBNAME}]" hubname
    if [ "$hubname" = "" ]; then
      hubname=$SEVPN_NETWORK_DEFAULT_HUBNAME
      break
    fi
  done
  
  echo

  # ADMIN PASSWORD
  adminpassword=""
  while true; do
    adminpassword=""
    read -s -p "관리자 비밀번호를 지정해주세요.  [${SEVPN_NETWORK_DEFAULT_ADMINPASSWORD}]" adminpassword
    if [ "$adminpassword" = "" ]; then
      adminpassword=$SEVPN_NETWORK_DEFAULT_ADMINPASSWORD
      break
    fi
  done

  echo

  # Local Bridge NetworkID
  networkid=""
  while true; do
    networkid=""
    read -p "SEVPN Local Bridge 리눅스 장치의 네트워크 ID입니다.  [${SEVPN_NETWORK_LOCAL_BRIDGE_NETWORKID}]" networkid
    if [ "$networkid" = "" ]; then
      networkid=$SEVPN_NETWORK_LOCAL_BRIDGE_NETWORKID
      break
    fi
  done

  echo

  # Local Bridge NetworkPrefix
  networkprefix=""
  while true; do
    networkprefix=""
    read -p "SEVPN Local Bridge 리눅스 장치의 서브넷 마스크 prefix를 입력해주세요.  [${SEVPN_NETWORK_LOCAL_BRIDGE_PREFIX}]" networkprefix
    if [ "$networkprefix" = "" ]; then
      networkprefix=$SEVPN_NETWORK_LOCAL_BRIDGE_PREFIX
      break
    fi
  done

  echo

  # Local Bridge NAT Gateway
  networkgateway=""
  while true; do
    networkgateway=""
    read -p "SEVPN Local Bridge 리눅스 장치의 IP 게이트웨이   [${SEVPN_NETWORK_LOCAL_BRIDGE_NAT_GATEWAY}]" networkgateway
    if [ "$networkgateway" = "" ]; then
      networkgateway=$SEVPN_NETWORK_LOCAL_BRIDGE_NAT_GATEWAY
      break
    fi
  done

  echo


  # Local Bridge DHCP Start
  dhcpstart=""
  while true; do
    dhcpstart=""
    read -p "SEVPN Local Bridge DHCP 할당 시작 주소  [${SEVPN_NETWORK_LOCAL_BRIDGE_DHCP_START}]" dhcpstart
    if [ "$dhcpstart" = "" ]; then
      dhcpstart=$SEVPN_NETWORK_LOCAL_BRIDGE_DHCP_START
      break
    fi
  done

  echo

  # Local Bridge DHCP END
  dhcpend=""
  while true; do
    dhcpend=""
    read -p "SEVPN Local Bridge DHCP 할당 마지막 주소 [${SEVPN_NETWORK_LOCAL_BRIDGE_DHCP_END}]" dhcpend
    if [ "$dhcpend" = "" ]; then
      dhcpend=$SEVPN_NETWORK_LOCAL_BRIDGE_DHCP_END
      break
    fi
  done

  echo

  # Local Bridge DHCP DNS1
  dhcpdns1=""
  while true; do
    dhcpdns1=""
    read -p "SEVPN Local Bridge DHCP DNS1   [${SEVPN_NETWORK_LOCAL_BRIDGE_DNS1}]" dhcpdns1
    if [ "$dhcpdns1" = "" ]; then
      dhcpdns1=$SEVPN_NETWORK_LOCAL_BRIDGE_DNS1
      break
    fi
  done

  # Local Bridge DHCP DNS2
  dhcpdns2=""
  while true; do
    dhcpdns2=""
    read -p "SEVPN Local Bridge DHCP DNS2  [${SEVPN_NETWORK_LOCAL_BRIDGE_DNS2}]" dhcpdns2
    if [ "$dhcpdns2" = "" ]; then
      dhcpdns2=$SEVPN_NETWORK_LOCAL_BRIDGE_DNS2
      break
    fi
  done


  # Local Bridge TAP Name
  networktapname=""
  while true; do
    networktapname=""
    read -p "SEVPN Local Bridge 장치의 인터페이스 명입니다. 접두사 tap_ 이 붙습니다.  [${SEVPN_NETWORK_LOCAL_BRIDGE_TAP_NAME}]" networktapname
    if [ "$networktapname" = "" ]; then
      networktapname=$SEVPN_NETWORK_LOCAL_BRIDGE_TAP_NAME
      break
    fi
  done

  echo "-------------------------------------------"

  echo "VPN 접속에 사용 할 기본 사용자를 생성합니다."

  # First VPN User
  firstusername=""
  while true; do
    firstusername=""
    read -p "생성할 사용자 이름  [${SEVPN_NETWORK_START_USERNAME}]" firstusername
    if [ "$firstusername" = "" ]; then
      firstusername=$SEVPN_NETWORK_START_USERNAME
      break
    fi
  done

  echo
 
  firstpassword=""
  while true; do
    firstpassword=""
    read -s -p "생성할 사용자 비밀번호  [${SEVPN_NETWORK_START_PASSWORD}]" firstpassword
    if [ "$firstpassword" = "" ]; then
      firstpassword=$SEVPN_NETWORK_START_PASSWORD
      break
    fi
  done


  echo
  echo
  echo "Virtual HUB Name : ${hubname}"
  echo "Admin Password : ${adminpassword}"
  echo 
  echo "Network ID : ${networkid}"
  echo "Network Prefix : ${networkprefix}"
  echo "Network Mask : ${NETPREFIX[${networkprefix}]}"
  echo "Network Gateway : ${networkgateway}"
  echo "Network Tap : tap_${networktapname}"
  echo "Network DHCP DNS1 : ${dhcpdns1}"
  echo "Network DHCP DNS2 : ${dhcpdns2}"
  echo "Network DHCP Range : ${dhcpstart} ${dhcpend}"

  echo
  echo "First Username : ${firstusername}"
  echo "First Password : ${firstpassword}"
  echo

  cat << _EOF_ > $SEVPN_LOCAL_VPN_ENV_TMP
#!bin/bash
SEVPN_NETWORK_DEFAULT_HUBNAME=$hubname
SEVPN_NETWORK_DEFAULT_ADMINPASSWORD=$adminpassword
SEVPN_NETWORK_LOCAL_BRIDGE_ID=$networkid
SEVPN_NETWORK_LOCAL_BRIDGE_PREFIX=$networkprefix
SEVPN_NETWORK_LOCAL_BRIDGE_MASK=${NETPREFIX[${networkprefix}]}
SEVPN_NETWORK_LOCAL_BRIDGE_NAT_GATEWAY=${networkgateway}
SEVPN_NETWORK_LOCAL_BRIDGE_TAP_NAME=${networktapname}   
SEVPN_NETWORK_START_USERNAME=${firstusername}
SEVPN_NETWORK_START_PASSWORD=${firstpassword}
SEVPN_NETWORK_LOCAL_BRIDGE_DHCP_START=${dhcpstart}
SEVPN_NETWORK_LOCAL_BRIDGE_DHCP_END=${dhcpend}
SEVPN_NETWORK_LOCAL_BRIDGE_DNS1=${dhcpdns1}
SEVPN_NETWORK_LOCAL_BRIDGE_DNS2=${dhcpdns2}
_EOF_

  cat << _EOF_ > $SEVPN_LOCAL_VPN_DHCPD_TMP
#SEVPNAUTOSETUPST
subnet $networkid netmask ${NETPREFIX[${networkprefix}]} {
  authoritative;
  range ${dhcpstart} ${dhcpend};
  option domain-name-servers ${dhcpdns1} ${dhcpdns2};
  option domain-name "${hubname}.`hostname`.vpn";
  option routers ${networkgateway};
  default-lease-time 600;
  max-lease-time 7200;
}
#SEVPNAUTOSETUPED
_EOF_
 

}

if [ -s $SEVPN_LOCAL_VPN_ENV_TMP ]; then
  echo -e "${Green} 이미 설정 파일이 있습니다. ${Color_Off}"
  echo -e "변경하려면 ${Yellow}$SEVPN_LOCAL_VPN_ENV_TMP$Color_Off} 파일을 삭제합니다."
  sleep 2
else
  set_vpn_server_env
  sleep 3
fi
