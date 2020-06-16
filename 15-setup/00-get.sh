#!/bin/bash

SEVPN_LOCAL_BIN_TEMP="./tmp/sevpn.tar.gz"

echo
echo SoftEther VPN ${SEVPN_REMOTE_VERSION} Binary를 내려받습니다.
echo

if [[ -s $SEVPN_LOCAL_BIN_TEMP ]]; then
  echo
  echo "Binary를 이미 내려받았습니다."
  echo 
else
  wget -4 --timeout=10 --tries=5 --retry-connrefused -O $SEVPN_LOCAL_BIN_TEMP "$SEVPN_REMOTE_BIN_CHOICE" 
  
  if [[ $? -ne 0 ]]; then
    rm -f $SEVPN_LCAOL_BIN_TEMP
    echo
    echo -e "${Red}원격파일 ${White}${SEVPN_REMOTE_BIN_CHOICE} ${Red}를 정상적으로 받지 못했습니다."
    echo -e "네트워크 연결에 문제 또는 원격 서버가 문제일 수 있습니다."
    echo -e "수동으로 다운로드 후 ${pwd}${SEVPN_LOCAL_BIN_TEMP}에 저장한 뒤 다시 시도해보세요. ${Color_Off}"
    exit 1
  fi
  
fi


echo 
echo

