#!/bin/bash
set -e
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
POSITIONAL_ARGS=()

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

extras=""

while [[ $# -gt 0 ]]; do
  case $1 in

    # SEVPN 기본 설정
    --tcp-port)
      TCP_PORT="$2"
      extras="$extras\nVAR_LOCAL_SEVPN_TCP_BASE_PORT=$TCP_PORT"
      shift # past argument
      shift # past value
      ;;
    --openvpn-udp-port)
      OPENVPN_UDP_PORT="$2"
      extras="$extras\nVAR_LOCAL_SEVPN_OPENVPN_UDP_PORT=$OPENVPN_UDP_PORT"
      shift # past argument
      shift # past value
      ;;    
    --no-enable-ddnsclient)
      DISABLE_DDNSCLIENT=yes
      extras="$extras\nVAR_LOCAL_SEVPN_DDNSCLIENT="
      shift # past value
      ;;
    --server-name)
      ALTERNATIVE_HOSTNAME=$2
      extras="$extras\nVAR_LOCAL_SEVPN_ALTERNATIVE_HOSTNAME=$ALTERNATIVE_HOSTNAME"
      shift
      shift
      ;;

    --password|--adminpassword|--adminpass)
      ADMINPASSWORD=$2
      extras="$extras\nVAR_LOCAL_SEVPN_ADMINPASSWORD=$ADMINPASSWORD"
      shift
      shift
      ;;
    
    --no-enable-l2tpipsec)
      extras="$extras\nVAR_LOCAL_SEVPN_L2TPIPSEC="
      shift
      ;;

    --l2tpipsec-presharedkey|--l2tp-psk)
      L2TPIPSEC_PRESHAREDKEY=$2
      extras="$extras\nVAR_LOCAL_SEVPN_L2TPIPSEC_PRESHAREDKEY=$L2TPIPSEC_PRESHAREDKEY"
      shift
      shift
      ;;

    --no-enable-sstp)
      extras="$extras\nVAR_LOCAL_SEVPN_SSTP="
      shift
      ;;
    
    # 기본 vhub 설정
    --set-vhub-name)
      FIRSTHUB_NAME=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NAME=$FIRSTHUB_NAME"
      shift
      shift
      ;;

    --set-vhub-tapname)
      FIRSTHUB_TAPNAME=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_TAPNAME=$FIRSTHUB_TAPNAME"
      shift
      shift
      ;;

    # 기본 계정 설정
    --add-user)
      CREATE_PRIMARYUSER=yes
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_CREATE_FIRSTVPNUSER=yes"
      shift
      ;;
    
    --add-user-username)
      if [ -z "$CREATE_PRIMARYUSER" ]; then
        echo "--create-primaryuser 옵션이 필요함"
        exit 1
      fi
      CREATE_USER_USERNAME=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_FIRSTVPNUSER=$CREATE_USER_USERNAME"
      shift
      shift
      ;;

    --add-user-password)
      if [ -z "$CREATE_PRIMARYUSER" ]; then
        echo "--create-primaryuser 옵션이 필요함"
        exit 1
      fi
      CREATE_USER_PASSWORD=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_FIRSTVPNUSERPASSWORD=$CREATE_USER_PASSWORD"
      shift
      shift
      ;;
    
    # IPv4 설정
    --no-enable-ipv4)
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_ENABLE="
      shift
      ;;

    --ipv4-network|-ipv4-networkid)
      NETWORK4_NETWORK=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NETWORK=$NETWORK4_NETWORK"
      shift
      ;;

    --ipv4-maskbit|--ipv4-subnetbit|--ipv4-bit)
      NETWORK4_MASKBIT=$2
      NETWORK4_NETMASK=${NETMASKADDR4[${VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_MASKBIT}]}
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_MASKBIT=$NETWORK4_MASKBIT"
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NETMASK=$NETWORK4_NETMASK"
      shift
      shift
      ;;

    --ipv4-localaddress)
      NETWORK4_LOCALADDRESS=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_LOCALADDRESS=$NETWORK4_LOCALADDRESS"
      shift
      shift
      ;;
    
    --no-enable-ipv4-dhcp)
      extras="$extras\VAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP="
      shift
      ;;

    --ipv4-dhcp-pool-start)
      NETWORK4_DHCP_START=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP_START=$NETWORK4_DHCP_START"
      shift
      shift
      ;;
    
    --ipv4-dhcp-pool-end)
      NETWORK4_DHCP_END=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP_END=$NETWORK4_DHCP_END"
      shift
      shift
      ;;
    
    --ipv4-dhcp-dns1)
      NETWORK4_DHCP_DNS1=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP_DNS1=$NETWORK4_DHCP_DNS1"
      shift
      shift
      ;;

    --ipv4-dhcp-dns2)
      NETWORK4_DHCP_DNS2=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_DHCP_DNS2=$NETWORK4_DHCP_DNS2"
      shift
      shift
      ;;

    --no-enable-ipv4-nat|--no-enable-nat4)
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT"
      shift
      ;;

    --ipv4-nat-interface)
      NETWORK4_NAT_MASQUERADE_OUTINTERFACE=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK4_NAT_MASQUERADE_OUTINTERFACE=$NETWORK4_NAT_MASQUERADE_OUTINTERFACE"
      shift
      shift
      ;;

    # IPv6 설정
    --ipv6-enable)
      ENABLE_IPV6=yes
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_ENABLE=yes"
      shift
      ;;

    --ipv6-network|--ipv6-networkid)
      if [ -z "$ENABLE_IPV6" ]; then
        echo "--ipv6-enable 옵션이 필요함"
        exit 1
      fi
      NETWORK6_NETWORK=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NETWORK=$NETWORK6_NETWORK"
      shift
      shift
      ;;

    --ipv6-maskbit|--ipv6-subnetbit|--ipv6-bit)
      NETWORK6_MASKBIT=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_MASKBIT=$NETWORK6_MASKBIT"
      shift
      shift
      ;;

    --ipv6-localaddress)
      NETWORK6_LOCALADDRESS=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_LOCALADDRESS=$NETWORK6_LOCALADDRESS"
      shift
      shift
      ;;

    --no-enable-ipv6-radvd|--no-enable-ipv6-dhcp)
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_RADVD="
      shift
      ;;

    --ipv6-radvd-dns1|--ipv6-dhcp-dns1)
      NETWORK6_RADVD_DNS1=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_RADVD_DNS1=$NETWORK6_RADVD_DNS1"
      shift
      shift
      ;;

    --ipv6-radvd-dns2|--ipv6-dhcp-dns2)
      NETWORK6_RADVD_DNS2=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_RADVD_DNS2=$NETWORK6_RADVD_DNS2"
      shift
      shift
      ;;

    --no-enable-ipv6-nat|--no-enable-nat6)
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT"
      shift
      ;;

    --ipv6-nat-interface)
      NETWORK6_NAT_MASQUERADE_OUTINTERFACE=$2
      extras="$extras\nVAR_LOCAL_SEVPN_FIRSTHUB_NETWORK6_NAT_MASQUERADE_OUTINTERFACE=$NETWORK6_NAT_MASQUERADE_OUTINTERFACE"
      shift
      shift
      ;;

    # .

    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

#echo -e $extras

if `command -v apt &> /dev/null`; then
  echo "APT 패키지 설치"
  _=`apt-get update -y && apt-get install -y curl tar sudo > /dev/null 2>&1`
fi

if `command -v yum &> /dev/null`; then
  echo "YUM 패키지 설치"
  _=`yum update -y && yum install -y curl tar sudo > /dev/null 2>&1`
fi

echo "GIT 설치 패키지 다운로드"
curl -L https://github.com/kerus1024/softether-vpn-autosetup/archive/master.tar.gz > softether-vpn-autosetup.tar.gz
mkdir softether-vpn-autosetup
tar xzf softether-vpn-autosetup.tar.gz --strip 1 -C ./softether-vpn-autosetup
echo "# AUTO" >> ./softether-vpn-autosetup/response.env
echo -e $extras >> ./softether-vpn-autosetup/response.env

if [[ "$EUID" -ne 0 ]]; then
  sudo su -c "cd ./softether-vpn-autosetup ; bash setup.bash"
else
  cd ./softether-vpn-autosetup
  bash setup.bash
fi