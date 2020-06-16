#!/bin/bash

# 1 은 실패코드임
RESULTCODE=1

#OS=
VERSION=
ARCH=`uname -i`
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


####################################################


declare -a checklist_name=("CentOS7_x86_64" "Ubuntu18_x86_64")

for i in $checklist_name
do

  printf "\nCheck $checklist_name = "
  check_"$checklist_name"

  if [ "$?" ]; then

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
