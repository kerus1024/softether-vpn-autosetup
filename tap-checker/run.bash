#!/bin/bash
#set -e
#set -x



source ../lib/common.bash

declare -A status_if

# init, up, down
# status_if["soft"]=up


#print_color cyan `cat /proc/meminfo`
#print_color red inline "Linux Version:  "
#print_color cyan inline `uname -r`

echo '
* * * * * * * * * * * * * * * * * * * * * * * * * *

                 SE-VPN Support Script~

* * * * * * * * * * * * * * * * * * * * * * * * * *

'

print_color blue TAP 장치를 탐색합니다.

while true
do
#############################################
unset current_status_if
declare -A current_status_if
current_status_if=()

# SEVPN 소스코드에 "tap_" prefix가 하드코딩 되어있다.
for iffile in /sys/class/net/tap_*; do

  if [ ! -d "$iffile" ]; then 
    print_color yellow TAP 장치를 못 찾았어요
    continue
    #exit 1
  fi

  basename=`basename $iffile`
  ifname=`sed -e 's/^tap_\(.*\)/\1/' <<< $basename`
  #echo Found $ifname

  if [ -z "${status_if[$ifname]}" ]; then
    print_color green $ifname 를 처음 발견했어요.
    status_if[$ifname]=init
  fi

  if [ "${status_if[$ifname]}" != "up" ]; then

    # 이 경우엔 source 보다 bash 가 좋아보임.
    if [ -f "./interfaces.d/$ifname.up.bash" ]; then
      logger $ifname.up.bash 실행합니다.
      bash ./interfaces.d/$ifname.up.bash
    else
      logger $ifname.up.bash 가 없어요.
    fi

    print_color green $ifname is up.
    logger $ifname is up.
    status_if[$ifname]=up

  fi

  current_status_if[$ifname]=1

done

# Down 된 인터페이스 찾기
for ifname in ${!status_if[@]}; do

  if [ -z "${current_status_if[$ifname]}" ] && [ "${status_if[$ifname]}" != "down" ]; then

    if [ -f "./interfaces.d/$ifname.down.bash" ]; then
      logger $ifname.down.bash 실행합니다.
      bash ./interfaces.d/$ifname.down.bash
    else 
      logger $ifname.down.bash 가 없어요.
    fi
    
    print_color red $ifname is down.
    logger $ifname is down.

    #unset status_if[$ifname]
    status_if[$ifname]=down
  fi

done

#############################################
# ENDING LOOP
sleep 1
done
