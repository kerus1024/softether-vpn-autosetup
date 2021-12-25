#!/bin/bash
ENV_PRINT_DEBUG=yes
ENV_REMOTE_SOFTETHER_PACKAGE=

set_remote_softether_package () {
  # https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.38-9760-rtm/softether-vpnserver-v4.38-9760-rtm-2021.08.17-linux-x64-64bit.tar.gz
  basedir='https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download'
  version='v4.38-9760-rtm'
  releasedate='2021.08.17'
  
  LINUX_INTEL86=$basedir/$version/softether-vpnserver-$version-$releasedate-linux-x86-32bit.tar.gz
  LINUX_AMD64=$basedir/$version/softether-vpnserver-$version-$releasedate-linux-x64-64bit.tar.gz
  LINUX_ARM32=$basedir/$version/softether-vpnserver-$version-$releasedate-linux-arm-32bit.tar.gz
  LINUX_ARM64=$basedir/$version/softether-vpnserver-$version-$releasedate-linux-arm64-64bit.tar.gz
  LINUX_ARMEABI=$basedir/$version/softether-vpnserver-$version-$releasedate-linux-arm_eabi-32bit.tar.gz
  
  case "$1" in
    "intel86")
      ENV_REMOTE_SOFTETHER_PACKAGE=$LINUX_INTEL86
      ;;
    "amd64"|"x86_64")
      ENV_REMOTE_SOFTETHER_PACKAGE=$LINUX_AMD64
      ;;  
    "arm32")
      ENV_REMOTE_SOFTETHER_PACKAGE=$LINUX_ARM32
      ;;
    "arm64")
      ENV_REMOTE_SOFTETHER_PACKAGE=$LINUX_ARM64
      ;;
    "armeabi")
      ENV_REMOTE_SOFTETHER_PACKAGE=$LINUX_ARMEABI
      ;;
    *)
      echo "패키지를 알 수 없는 아키텍처: $1"
      exit 1
      ;;
  esac

}

declare -A NETMASKADDR4
NETMASKADDR4[0]="0.0.0.0"
NETMASKADDR4[1]="128.0.0.0"
NETMASKADDR4[2]="192.0.0.0"
NETMASKADDR4[3]="224.0.0.0"
NETMASKADDR4[4]="240.0.0.0"
NETMASKADDR4[5]="248.0.0.0"
NETMASKADDR4[6]="252.0.0.0"
NETMASKADDR4[7]="254.0.0.0"

NETMASKADDR4[8]="255.0.0.0"
NETMASKADDR4[9]="255.128.0.0"
NETMASKADDR4[10]="255.192.0.0"
NETMASKADDR4[11]="255.224.0.0"
NETMASKADDR4[12]="255.240.0.0"
NETMASKADDR4[13]="255.248.0.0"
NETMASKADDR4[14]="255.252.0.0"
NETMASKADDR4[15]="255.254.0.0"

NETMASKADDR4[16]="255.255.0.0"
NETMASKADDR4[17]="255.255.128.0"
NETMASKADDR4[18]="255.255.192.0"
NETMASKADDR4[19]="255.255.224.0"
NETMASKADDR4[20]="255.255.240.0"
NETMASKADDR4[21]="255.255.248.0"
NETMASKADDR4[22]="255.255.252.0"
NETMASKADDR4[23]="255.255.254.0"

NETMASKADDR4[24]="255.255.255.0"
NETMASKADDR4[25]="255.255.255.128"
NETMASKADDR4[26]="255.255.255.192"
NETMASKADDR4[27]="255.255.255.224"
NETMASKADDR4[28]="255.255.255.240"
NETMASKADDR4[29]="255.255.255.248"
NETMASKADDR4[30]="255.255.255.252"
NETMASKADDR4[31]="255.255.255.254"
NETMASKADDR4[32]="255.255.255.255"

# Reset
CC_Color_Off='\033[0m'       # Text Reset

# Regular Colors
CC_Black='\033[0;30m'        # Black
CC_Red='\033[0;31m'          # Red
CC_Green='\033[0;32m'        # Green
CC_Yellow='\033[0;33m'       # Yellow
CC_Blue='\033[0;34m'         # Blue
CC_Purple='\033[0;35m'       # Purple
CC_Cyan='\033[0;36m'         # Cyan
CC_White='\033[0;37m'        # White

# Bold
CC_BBlack='\033[1;30m'       # Black
CC_BRed='\033[1;31m'         # Red
CC_BGreen='\033[1;32m'       # Green
CC_BYellow='\033[1;33m'      # Yellow
CC_BBlue='\033[1;34m'        # Blue
CC_BPurple='\033[1;35m'      # Purple
CC_BCyan='\033[1;36m'        # Cyan
CC_BWhite='\033[1;37m'       # White

# Underline
CC_UBlack='\033[4;30m'       # Black
CC_URed='\033[4;31m'         # Red
CC_UGreen='\033[4;32m'       # Green
CC_UYellow='\033[4;33m'      # Yellow
CC_UBlue='\033[4;34m'        # Blue
CC_UPurple='\033[4;35m'      # Purple
CC_UCyan='\033[4;36m'        # Cyan
CC_UWhite='\033[4;37m'       # White

# Background
CC_On_Black='\033[40m'       # Black
CC_On_Red='\033[41m'         # Red
CC_On_Green='\033[42m'       # Green
CC_On_Yellow='\033[43m'      # Yellow
CC_On_Blue='\033[44m'        # Blue
CC_On_Purple='\033[45m'      # Purple
CC_On_Cyan='\033[46m'        # Cyan
CC_On_White='\033[47m'       # White

# High Intensity
CC_IBlack='\033[0;90m'       # Black
CC_IRed='\033[0;91m'         # Red
CC_IGreen='\033[0;92m'       # Green
CC_IYellow='\033[0;93m'      # Yellow
CC_IBlue='\033[0;94m'        # Blue
CC_IPurple='\033[0;95m'      # Purple
CC_ICyan='\033[0;96m'        # Cyan
CC_IWhite='\033[0;97m'       # White

# Bold High Intensity
CC_BIBlack='\033[1;90m'      # Black
CC_BIRed='\033[1;91m'        # Red
CC_BIGreen='\033[1;92m'      # Green
CC_BIYellow='\033[1;93m'     # Yellow
CC_BIBlue='\033[1;94m'       # Blue
CC_BIPurple='\033[1;95m'     # Purple
CC_BICyan='\033[1;96m'       # Cyan
CC_BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
CC_On_IBlack='\033[0;100m'   # Black
CC_On_IRed='\033[0;101m'     # Red
CC_On_IGreen='\033[0;102m'   # Green
CC_On_IYellow='\033[0;103m'  # Yellow
CC_On_IBlue='\033[0;104m'    # Blue
CC_On_IPurple='\033[0;105m'  # Purple
CC_On_ICyan='\033[0;106m'    # Cyan
CC_On_IWhite='\033[0;107m'   # White

is_root() {
    if [[ "$EUID" -ne 0 ]]; then
        return 1
    else
        return 0
    fi
}

run_without_print () {
  if [ ! -z "$ENV_PRINT_DEBUG" ]; then
    echo "${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]} : ${@}"
  fi

  echo "${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]} : ${@}" >> $VAR_LOCAL_TMP_STOUT_FILE 2>> $VAR_LOCAL_TMP_STERR_FILE
  ${@} >> $VAR_LOCAL_TMP_STOUT_FILE 2>> $VAR_LOCAL_TMP_STERR_FILE
  if [ ! -z "$ENV_PRINT_DEBUG" ]; then
    echo "[exit status code: $?] ${@}"
  fi
  return $?
}

print_clear() {
  /usr/bin/clear 2> /dev/null
}
print_color() {
  
  if [ -z "$1" ]; then return; fi;

  echoset="echo -n -e"
  echo="echo"
  text="${@:2}"

  if [ "$2" = "inline" ]; then
    echo="echo -n"
    text="${@:3}"
  fi

  if [ "$2" = "debug" ]; then

    if [ -z "$ENV_PRINT_DEBUG" ]; then
      return
    fi

    echo="echo"
    text="${@:3}"
  fi
  
  case "$1" in
    black)
      $echoset $CC_Black
      $echoset $CC_On_White
      ;;
    red)
      $echoset $CC_Red
      $echoset $CC_On_Black
      ;;
    green)
      $echoset $CC_Green
      $echoset $CC_On_Black
      ;;
    yellow)
      $echoset $CC_Yellow
      $echoset $CC_On_Black
      ;;
    blue)
      $echoset $CC_Blue
      $echoset $CC_On_White
      ;;
    purple)
      $echoset $CC_Purple
      $echoset $CC_On_Black
      ;;
    cyan)
      $echoset $CC_Cyan
      $echoset $CC_On_Black
      ;;
    white)
      $echoset $CC_White
      $echoset $CC_On_Black
      ;;
    *)
      ;;
  esac

  if [ "$2" = "debug" ]; then
    echo -n "${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]} : "
  fi 

  $echo $text

  $echoset $CC_Color_Off

}

is_shell_safe_text () {

  safepass=`get_shell_safe_text $1`

  if [ "'$1'" != "$safepass" ]; then
    return 1
  fi

  return 0

}

get_shell_safe_text () {
  echo ${1@Q}
}

