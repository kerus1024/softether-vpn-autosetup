#!/bin/bash

echo "[Check Listener]"

function check_listener() {

  testnetstat=`netstat --help > /dev/null 2>&1`

  if [ "$?" -gt "0" ]; then
    /usr/bin/clear 2> /dev/null
    echo -e "${Red} netstat 명령을 실행할 수 없습니다."
    echo -e "${Yellow} net-tools 패키지를 설치해주세요.${Color_Off}"
    echo "RHEL           : yum -y install net-tools"
    echo "Debian/Ubuntu  : apt -y install net-tools"
    exit
  fi

  totalcnt=4
  current_error=0

  # Check TCP 443
  t443=`netstat -nl4t | grep ":443 " 2>&1 | wc -l `

  if [ "$t443" -gt "0" ]; then
    echo -e "${Red} 443 포트를 사용하는 프로세스가 있습니다. ${Color_Off}"
    (( current_error++ ))
  fi

  # Check TCP 992
  t992=`netstat -nl4t | grep ":992 " 2>&1 | wc -l `

  if [ "$t992" -gt "0" ]; then
    echo -e "${Red} 992 포트를 사용하는 프로세스가 있습니다. ${Color_Off}"
    (( current_error++ ))
  fi

  # Check TCP 443
  t1194=`netstat -nl4t | grep ":1194 " 2>&1 | wc -l `

  if [ "$t443" -gt "0" ]; then
    echo -e "${Red} 1194 포트를 사용하는 프로세스가 있습니다. ${Color_Off}"
    (( current_error++ ))
  fi

  # Check TCP 5555
  t5555=`netstat -nl4t | grep ":5555 " 2>&1 | wc -l `

  if [ "$t5555" -gt "0" ]; then
    echo -e "${Red} 5555 포트를 사용하는 프로세스가 있습니다. ${Color_Off}"
    (( current_error++ ))
  fi

  #########################

  if [ "$totalcnt" -eq "$current_error" ]; then
    echo
    echo
    echo
    echo -e "${Red} 사용할 수 있는 TCP 포트가 존재하지 않습니다. ${Color_Off}"
    echo
    echo
    exit 1
  fi


  u67=`netstat -nl4u | grep ":67 " 2>&1 | wc -l`
  if [ "$u67" -gt "0" ]; then
    echo
    echo
    echo -e "${Red} UDP 67 (DHCP) 포트를 사용하는 프로세스가 있습니다. ${Color_Off}"
    echo
    echo
    exit 1
  fi


}

check_listener

echo "[Check Listener] Done"
