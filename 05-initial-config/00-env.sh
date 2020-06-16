#!/bin/bash

# SoftEther PATH
SEVPN_REMOTE_BIN_AMD64="https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.34-9745-beta/softether-vpnserver-v4.34-9745-beta-2020.04.05-linux-x64-64bit.tar.gz"
SEVPN_REMOTE_BIN_ARM32="https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.34-9745-beta/softether-vpnserver-v4.34-9745-beta-2020.04.05-linux-arm_eabi-32bit.tar.gz"
SEVPN_REMOTE_VERSION="4.34.9745"
SEVPN_LOCAL_PATH="/usr/local/vpnserver"
SEVPN_SERVICE_PATH="/lib/systemd/system/softether-vpnserver.service"

SEVPN_NETWORK_DEFAULT_HUBNAME="DHUB"
SEVPN_NETWORK_DEFAULT_ADMINPASSWORD="12345678"

SEVPN_NETWORK_LOCAL_BRIDGE_NETWORKID="10.255.255.0"
SEVPN_NETWORK_LOCAL_BRIDGE_PREFIX=24
SEVPN_NETWORK_LOCAL_BRIDGE_NAT_GATEWAY="10.255.255.254"
SEVPN_NETWORK_LOCAL_BRIDGE_TAP_NAME="soft"

SEVPN_NETWORK_LOCAL_BRIDGE_DHCP_START="10.255.255.100"
SEVPN_NETWORK_LOCAL_BRIDGE_DHCP_END="10.255.255.199"
SEVPN_NETWORK_LOCAL_BRIDGE_DNS1="8.8.8.8"
SEVPN_NETWORK_LOCAL_BRIDGE_DNS2="8.8.4.4"

SEVPN_NETWORK_ENVSCRIPT_PATH="/usr/local/vpnserver/auto"

SEVPN_NETWORK_START_ENCRYPTION_MODE="ECDHE-RSA-AES256-GCM-SHA384"
SEVPN_NETWORK_START_USERNAME="vpnuser"
SEVPN_NETWORK_START_PASSWORD="12345678"

SEVPN_NETWORK_DEFAULT_LISTEN_PORT_443=1
SEVPN_NETWORK_DEFAULT_LISTEN_PORT_992=1
SEVPN_NETWORK_DEFAULT_LISTEN_PORT_1194=1
SEVPN_NETWORK_DEFAULT_LISTEN_PORT_5555=1

SEVPN_NETWORK_DEFAULT_LISTEN_L2TP=1
SEVPN_NETWORK_DEFAULT_LISTEN_OPENVPN=1


SEVPN_REMOTE_BIN_CHOICE=
SEVPN_LOCAL_ETHERNET_INTERFACE=
SEVPN_LOCAL_ETHERNET_SOURCEIP=



declare -A NETPREFIX
NETPREFIX[0]="0.0.0.0"
NETPREFIX[1]="128.0.0.0"
NETPREFIX[2]="192.0.0.0"
NETPREFIX[3]="224.0.0.0"
NETPREFIX[4]="240.0.0.0"
NETPREFIX[5]="248.0.0.0"
NETPREFIX[6]="252.0.0.0"
NETPREFIX[7]="254.0.0.0"

NETPREFIX[8]="255.0.0.0"
NETPREFIX[9]="255.128.0.0"
NETPREFIX[10]="255.192.0.0"
NETPREFIX[11]="255.224.0.0"
NETPREFIX[12]="255.240.0.0"
NETPREFIX[13]="255.248.0.0"
NETPREFIX[14]="255.252.0.0"
NETPREFIX[15]="255.254.0.0"

NETPREFIX[16]="255.255.0.0"
NETPREFIX[17]="255.255.128.0"
NETPREFIX[18]="255.255.192.0"
NETPREFIX[19]="255.255.224.0"
NETPREFIX[20]="255.255.240.0"
NETPREFIX[21]="255.255.248.0"
NETPREFIX[22]="255.255.252.0"
NETPREFIX[23]="255.255.254.0"

NETPREFIX[24]="255.255.255.0"
NETPREFIX[25]="255.255.255.128"
NETPREFIX[26]="255.255.255.192"
NETPREFIX[27]="255.255.255.224"
NETPREFIX[28]="255.255.255.240"
NETPREFIX[29]="255.255.255.248"
NETPREFIX[30]="255.255.255.252"
NETPREFIX[31]="255.255.255.254"
NETPREFIX[32]="255.255.255.255"





# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White


