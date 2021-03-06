#!/bin/bash
SAVE_WORKDIR=`pwd`

cd $SEVPN_LOCAL_EXTRACT_TMP/
make

if [ "$?" -gt "0" ]; then

  echo
  echo -e "${Red}빌드가 정상적으로 완료되지 않은 것 같습니다."
  echo -e "어떤 이유로 일어났는지 모릅니다..."
  echo -e "스크립트를 종료합니다. ${Color_Off}"
  echo
  exit 1

fi

cd $SAVE_WORKDIR

. $SEVPN_LOCAL_VPN_ENV_TMP

echo
echo Change Permissions
echo

chmod 600 $SEVPN_LOCAL_EXTRACT_TMP/*
chmod 700 $SEVPN_LOCAL_EXTRACT_TMP/vpnserver
chmod 700 $SEVPN_LOCAL_EXTRACT_TMP/vpncmd


