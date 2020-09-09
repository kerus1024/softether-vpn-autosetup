#!/bin/bash

echo
echo "설정을 위해 임시로 서버를 실행합니다."
echo

$SEVPN_LOCAL_PATH/vpnserver start && sleep 1

if [ "$?" -gt 0 ]; then
  echo -e "\n\n${Red} 오류 ${Color_Off}"
  exit
fi


# 비밀번호가 안맞으면 파라미터 입력이 오류나는데...

function sevpn_settings() {
  vpncmd=$SEVPN_LOCAL_PATH/vpncmd
  localhost="127.0.0.1:5555"
  echo
  echo -ne "\r[ ] $localhost 연결."
  $vpncmd /SERVER $localhost /cmd About

  if [ "$?" -gt 0 ]; then
    echo -e "\n\n${Red} 연결에 오류가 생겼습니다. ${Color_Off}"
    exit
  fi

  echo -ne "\r[✓] $localhost 연결\n"
  #################################
 
  echo
  echo "\r[ ] 설정 적용."
 
  $vpncmd /SERVER $localhost /cmd HubDelete DEFAULT
  # Password와 공백부분에 Escape를 해야하는지 모르겠다

  PASSARG=$SEVPN_NETWORK_DEFAULT_ADMINPASSWORD

  echo -ne "\r[ ] Password 적용"
  $vpncmd /SERVER localhost /cmd ServerPasswordSet $SEVPN_NETWORK_DEFAULT_ADMINPASSWORD
  sleep 1
  echo -ne "\r[✓] Password 적용\n"

  echo
  echo "기타 설정 적용..."
  echo

  cmdserver="$vpncmd /SERVER $localhost /PASSWORD:$PASSARG"
  echo $cmdserver
 
  hubname=$SEVPN_NETWORK_DEFAULT_HUBNAME
 
  # /IN 으로 해도됨. 

  $cmdserver /cmd HubDelete DEFAULT
  $cmdserver /cmd HubCreate $hubname /PASSWORD
  $cmdserver /cmd BridgeCreate $hubname /DEVICE:$SEVPN_NETWORK_LOCAL_BRIDGE_TAP_NAME /TAP:yes
  $cmdserver /cmd ServerCipherSet $SEVPN_NETWORK_START_ENCRYPTION_MODE
  $cmdserver /cmd IPsecEnable /L2TP:yes /L2TPRAW:no /ETHERIP:no /PSK:vpn /DEFAULTHUB:$hubname
  $cmdserver /adminhub:$hubname /cmd UserCreate $SEVPN_NETWORK_START_USERNAME /GROUP:none /REALNAME:none /NOTE:none
  $cmdserver /adminhub:$hubname /cmd UserPasswordSet $SEVPN_NETWORK_START_USERNAME /PASSWORD:$SEVPN_NETWORK_START_PASSWORD
  $cmdserver /adminhub:$hubname /cmd SstpEnable yes
  $cmdserver /cmd DynamicDnsGetStatus 
  echo
  echo "설정완료 !"
  echo

}

sevpn_settings

echo
echo 서버를 종료합니다
echo

$SEVPN_LOCAL_PATH/vpnserver stop




