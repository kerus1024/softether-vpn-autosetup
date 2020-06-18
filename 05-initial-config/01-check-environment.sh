#!/bin/bash

# 1 은 실패코드임
RESULTCODE=1

#OS=
VERSION=
ARCH=`uname -m`
KERNEL=`uname -r`

echo "[Check Environment] 운영체제 확인"


######################################################

function check_CentOS7_x86_64() {

  # Find CentOS 7 x86_64
  TRY0001=`cat /etc/redhat-release | awk '{print $1}'`
  TRY0002=`cat /etc/redhat-release | awk '{print $4}' | cut -b 1`

  if [ "$TRY0001" = "CentOS" ] && [ "$TRY0002" = "7" ] && [ "$ARCH" = "x86_64" ]; then
    OS="$TRY0001"-"$TRY0002"-"$ARCH"
    RESULTCODE=0
    SEVPN_REMOTE_BIN_CHOICE=$SEVPN_REMOTE_BIN_AMD64
    return 0
  fi

  return 1

}

function check_Ubuntu20_x86_64() {

  # Find Ubuntu 18 x86_64
  TRY0001=`/usr/bin/lsb_release -si`
  TRY0002=`/usr/bin/lsb_release -cs`

  if [ "$TRY0001" = "Ubuntu" ] && [ "$TRY0002" = "focal" ] && [ "$ARCH" = "x86_64" ]; then

    OS="Ubuntu-20-x86_64"
    RESULTCODE=0
    SEVPN_REMOTE_BIN_CHOICE=$SEVPN_REMOTE_BIN_AMD64
    return 0
  fi

  return 1

}



function check_Ubuntu18_x86_64() {

  # Find Ubuntu 18 x86_64
  TRY0001=`/usr/bin/lsb_release -si`
  TRY0002=`/usr/bin/lsb_release -cs`

  if [ "$TRY0001" = "Ubuntu" ] && [ "$TRY0002" = "bionic" ] && [ "$ARCH" = "x86_64" ]; then
    
    OS="Ubuntu-18-x86_64"
    RESULTCODE=0
    SEVPN_REMOTE_BIN_CHOICE=$SEVPN_REMOTE_BIN_AMD64
    return 0
  fi

  return 1

}

function check_Debian10_x86_64() {

  TRY0001=`/usr/bin/lsb_release -si`
  TRY0002=`/usr/bin/lsb_release -cs`

  if [ "$TRY0001" = "Debian" ] && [ "$TRY0002" = "buster" ] && [ "$ARCH" = "x86_64" ]; then
    OS="Debian-10-x86_64"
    RESULTCODE=0
    SEVPN_REMOTE_BIN_CHOICE=$SEVPN_REMOTE_BIN_AMD64
    return 0
  fi

  return 1

}


####################################################


declare -a checklist_name=("CentOS7_x86_64" "Ubuntu20_x86_64" "Ubuntu18_x86_64" "Debian10_x86_64")
for i in ${checklist_name[@]}
do

  printf "\nCheck $i = "
  check_"${i}"

  if [ "$?" = "0" ]; then

    printf "$OS\n\n"
    break

  else
    printf "FAIL"
  fi
  
  printf "\n"

done


echo "[Check Environment] 운영체제 확인 종료"

if [ -z "$OS" ]; then
  echo -e "$Red"
  echo "지원하지 않는 운영체제입니다."
  echo `uname -a`
  echo -e "$Color_Off"
  exit 1
fi

echo -e "현재 OS : ${Yellow}${OS}${Cyan}${Color_Off}"
echo -e "현재 Kernel : ${Yellow}${KERNEL}${Cyan}${Color_Off}"

return $RESULTCODE
