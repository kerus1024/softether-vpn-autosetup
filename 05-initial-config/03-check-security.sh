#!/bin/bash

echo
echo "[Check Security] SELinux 및 Firewall 서비스 확인"

function check_selinux() {

  SELINUXCONFPATH='/etc/sysconfig/selinux'

  sestatus=`sestatus | head -n 1 | awk '{print $3}'`

  if [ "$sestatus" = "enabled" ]; then
    echo -e "${Red}SELinux가 활성화 되어있습니다.${Color_Off}"

    echo -e "${Cyan}SELinux를 비활성화 할 수 있습니다. SELinux를 끄시겠습니까?"${Color_Off}

    while true; do
    yn=
    read -p "Do you wish to install this ? [y/n]" yn
    case $yn in
      [Yy]* )  

      /sbin/setenforce 0

      sestatus=`/sbin/getenforce`
      selinuxconftmp="./tmp/selinux_origin"
 
      sed 's/SELINUX=enforcing/SELINUX=disabled/' $SELINUXCONFPATH > $selinuxconftmp
     
      cat > $SELINUXCONFPATH < $selinuxconftmp

      if [ "$sestatus" != "Permissive" ]; then
        echo -e "${Red}오류. SELinux를 비활성화하지 못했습니다.${Color_Off}"
        exit 1
      fi
   
      echo "SELinux가 해제 되었습니다."
      echo "재부팅 후 SELinux가 완벽히 해제됩니다."

      break
      ;;
      [Nn]* ) exit;;
      * ) echo "Please answer yes or no.";;
      esac
    done

  fi

}

check_selinux


function check_firewalld_service () {

  run=`systemctl status firewalld 2>&1 | grep "enabled" | wc -l`

  if [ "$run" -gt "0" ]; then

    echo -e "${Red}Firewalld 서비스가 활성화 되어있습니다. ${Color_Off}"
    echo "VPN서버의 포트를 수동으로 허용 설정 해야합니다."

    echo -e "${Cyan}firewalld를 비활성화 할 수 있습니다. firewalld 서비스를 비활성화 하시겠습니까?"${Color_Off}

    while true; do
    yn=
    read -p "Do you wish to install this ? [y/n]" yn
    case $yn in
      [Yy]* )

      /bin/systemctl stop firewalld
      /bin/systemctl disable firewalld
      /bin/systemctl mask firewalld

      run=`systemctl status firewalld 2>&1 | grep "enabled" | wc -l`

      if [ "$run" -gt "0" ]; then
        echo -e "${Red}오류. firewalld를 비활성화하지 못했습니다.${Color_Off}"
        exit 1
      fi

      echo "firewalld가 해제 되었습니다."

      break
      ;;
      [Nn]* ) exit;;
      * ) echo "Please answer yes or no.";;
      esac
    done

  else
    echo
    echo "Firewalld 서비스를 발견하지 못했습니다."
    echo
  fi

}

check_firewalld_service

echo "[Check Security] SELinux 및 Firewall 서비스 확인 종료"
echo

