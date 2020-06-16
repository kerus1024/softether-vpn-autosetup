#!/bin/bash

echo "[Check Listener]"

function check_listener() {

  totalcnt=4
  current_error=0

  # Check TCP 443
  t443=`netstat -nl4t | grep ":443 " 2>&1 | wc -l `

  if [ "$t443" -gt "0" ]; then
    echo "${Red} 443 포트를 사용하는 프로세스가 있습니다. ${Color_Off}"
    (( current_error++ ))
  fi

  # Check TCP 992
  t992=`netstat -nl4t | grep ":992 " 2>&1 | wc -l `

  if [ "$t992" -gt "0" ]; then
    echo "${Red} 992 포트를 사용하는 프로세스가 있습니다. ${Color_Off}"
    (( current_error++ ))
  fi

  # Check TCP 443
  t1194=`netstat -nl4t | grep ":1194 " 2>&1 | wc -l `

  if [ "$t443" -gt "0" ]; then
    echo "${Red} 1194 포트를 사용하는 프로세스가 있습니다. ${Color_Off}"
    (( current_error++ ))
  fi

  # Check TCP 5555
  t5555=`netstat -nl4t | grep ":5555 " 2>&1 | wc -l `

  if [ "$t5555" -gt "0" ]; then
    echo "${Red} 5555 포트를 사용하는 프로세스가 있습니다. ${Color_Off}"
    (( current_error++ ))
  fi

  #########################

  if [ "$totalcnt" -eq "$current_error" ]; then
    echo
    echo
    echo
    echo "${Red} 사용할 수 있는 TCP 포트가 존재하지 않습니다. ${Color_Off}"
    echo
    echo
    exit 1
  fi

}

check_listener

echo "[Check Listener] Done"
