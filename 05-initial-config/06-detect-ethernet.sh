#!/bin/bash

echo
echo "[Detect Internet]"
echo



function get_internet_info() {

  #getinterface=`ip route | head -n 1 | awk '{ print $NF }'`
  getinterface=$(echo `ip route | head -n 1 | grep -oP '\sdev\s[^\s]+\s'` | awk '{ print $2 }')
  /sbin/ifconfig

  userinterface=""
  while true; do
    userinterface=""
    read -p "인터넷 인터페이스를 지정해주세요. ? [${getinterface}]" userinterface
    if [ "$userinterface" = "" ]; then 
      userinterface=$getinterface
      break
    else

      checkexist=`ip -o link | grep " $userinterface: "`

      if [ "$?" -ne "0" ] || [ "$checkexist" -eq "0" ]; then
        echo -e "${Red}존재하지 않는 인터페이스 입니다.${Color_Off}"
      else
        break
      fi

    fi
  done
 

  getaddr=`ip address show dev $userinterface | grep inet | head -1 |  awk '{ print $2 }' | grep -oP '[^/]+' | head -1`
  
  echo
  echo -e "감지한 인터페이스 [${userinterface}] IP 주소 : ${Cyan} $getaddr ${Color_Off}"
  echo

  echo "일치하지 않은 경우 직접 입력하세요"

  useraddrinput=""
  while true; do
    useraddrinput=""
    read -p "인터넷 인터페이스를 지정해주세요. ? [${getaddr}]" useraddrinput
    if [ "$useraddrinput" = "" ]; then
      useraddrinput=$getaddr
      break
    else

      checkexist=`ip address | grep \'"$useraddrinput"\' | wc -l`

      if [ "$?" -ne "0" ] || [ $checkexist -eq "0" ]; then
        echo -e "${Red}인터페이스에 존재하지 않는 IP 입니다.${Color_Off}"
      else
        break
      fi

    fi
  done

  SEVPN_LOCAL_ETHERNET_INTERFACE=$userinterface
  SEVPN_LOCAL_ETHERNET_SOURCEIP=$getaddr

}

get_internet_info

echo
echo
echo
echo
echo
echo
echo -e "Interface Name : ${Yellow}${SEVPN_LOCAL_ETHERNET_INTERFACE}$Color_Off"
echo -e "IP Address : ${Yellow}${SEVPN_LOCAL_ETHERNET_SOURCEIP}${Color_Off}"
sleep 2
echo
echo
echo



echo "[Detect Internet] Done"
