#!/bin/bash
# $SEVPN_LOCAL_EXTRACT_TMP

rm -rf $SEVPN_LOCAL_PATH

mkdir -p $SEVPN_LOCAL_PATH
chmod 755 $SEVPN_LOCAL_PATH

cp -Rf $SEVPN_LOCAL_EXTRACT_TMP/. $SEVPN_LOCAL_PATH

if [ ! -s "$SEVPN_LOCAL_PATH/vpnserver" ]; then
  echo "복사되지 않음."
  exit 1
fi

chmod 600 $SEVPN_LOCAL_PATH/*
chmod 700 $SEVPN_LOCAL_PATH/vpnserver
chmod 700 $SEVPN_LOCAL_PATH/vpncmd


mkdir -p $SEVPN_NETWORK_ENVSCRIPT_PATH
chmod 755 $SEVPN_NETWORK_ENVSCRIPT_PATH

# Service Install

echo
echo
echo Installing Service
echo
echo
sleep 1

cat << _EOF_ > $SEVPN_SERVICE_PATH
[Unit]
Description=SoftEther VPN Server
After=network.target auditd.service

[Service]
Type=forking
ExecStart=$SEVPN_LOCAL_PATH/vpnserver start
ExecStop=$SEVPN_LOCAL_PATH/vpnserver stop
ExecStop=/sbin/iptables -t nat -D POSTROUTING -s $SEVPN_NETWORK_LOCAL_BRIDGE_ID/$SEVPN_NETWORK_LOCAL_BRIDGE_PREFIX -j SNAT --to-source $SEVPN_LOCAL_ETHERNET_SOURCEIP 2> /dev/null
ExecStartPost=$SEVPN_NETWORK_ENVSCRIPT_PATH/waitTAPinterface.sh
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
_EOF_

/bin/systemctl daemon-reload

# https://stackoverflow.com/questions/16807876/how-to-check-if-another-instance-of-my-shell-script-is-running

cat << _EOF_ > $SEVPN_NETWORK_ENVSCRIPT_PATH/waitTAPinterface.sh
#!/bin/bash

while true; 
do
  if [ "\$(ip l | fgrep ' tap_$SEVPN_NETWORK_LOCAL_BRIDGE_TAP_NAME': | wc -l)" -gt "0" ]; then
    /sbin/ifconfig tap_$SEVPN_NETWORK_LOCAL_BRIDGE_TAP_NAME $SEVPN_NETWORK_LOCAL_BRIDGE_NAT_GATEWAY netmask $SEVPN_NETWORK_LOCAL_BRIDGE_MASK
    $SEVPN_NETWORK_ENVSCRIPT_PATH/restartDHCPD.sh
    /sbin/iptables -t nat -D POSTROUTING -s $SEVPN_NETWORK_LOCAL_BRIDGE_ID/$SEVPN_NETWORK_LOCAL_BRIDGE_PREFIX -j SNAT --to-source $SEVPN_LOCAL_ETHERNET_SOURCEIP 2> /dev/null
    /sbin/iptables -t nat -A POSTROUTING -s $SEVPN_NETWORK_LOCAL_BRIDGE_ID/$SEVPN_NETWORK_LOCAL_BRIDGE_PREFIX -j SNAT --to-source $SEVPN_LOCAL_ETHERNET_SOURCEIP
    break
  fi
  sleep 1
done

_EOF_

chmod 700 $SEVPN_NETWORK_ENVSCRIPT_PATH
chmod 700 $SEVPN_NETWORK_ENVSCRIPT_PATH/waitTAPinterface.sh



# dhcpd or isc-dhcp-server
. ./10-dependencies/03-setup-dhcpd.sh



