#!/bin/bash
# $SEVPN_LOCAL_EXTRACT_TMP

mkdir -p $SEVPN_LOCAL_PATH
chmod 755 $SEVPN_LOCAL_PATH

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
ConditionPathExists=!$SEVPN_LOCAL_PATH/do_not_run

[Service]
Type=forking
TasksMax=16777216
EnvironmentFile=-$SEVPN_LOCAL_PATH/vpnserver
ExecStart=$SEVPN_LOCAL_PATH/vpnserver start
ExecStop=$SEVPN_LOCAL_PATH/vpnserver stop
ExecStartPost=$SEVPN_NETWORK_ENVSCRIPT_PATH/waitTAPinterface.sh
KillMode=process
Restart=on-failure

# Hardening
PrivateTmp=yes
ProtectHome=yes
ProtectSystem=full
ReadOnlyDirectories=/
ReadWriteDirectories=-$SEVPN_LOCAL_PATH/vpnserver
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_BROADCAST CAP_NET_RAW CAP_SYS_NICE CAP_SYSLOG CAP_SETUID

[Install]
WantedBy=multi-user.target
_EOF_

/bin/systemctl daemon-reload

cat << _EOF_ > $SEVPN_NETWORK_ENVSCRIPT_PATH/waitTAPinterface.sh
#!/bin/bash
while true; 
do
  if [ "$(ip l | fgrep $SEVPN_NETWORK_LOCAL_BRIDGE_TAP_NAME: | wc -l)" -gt 0 ]; then
    /sbin/ifconfig $SEVPN_NETWORK_LOCAL_BRIDGE_TAP_NAME $SEVPN_NETWORK_LOCAL_BRIDGE_NAT_GATEWAY netmask $SEVPN_NETWORK_LOCAL_BRIDGE_MASK
    /bin/systemctl stop dhcpd && /bin/systemctl start dhcpd
    /sbin/iptables -t nat -D POSTROUTING -s $SEVPN_NETWORK_LOCAL_BRIDGE_ID/$SEVPN_NETWORK_LOCAL_BRIDGE_PREFIX -j SNAT --to-source $SEVPN_LOCAL_ETHERNET_SOURCEIP
    /sbin/iptables -t nat -D POSTROUTING -s $SEVPN_NETWORK_LOCAL_BRIDGE_ID/$SEVPN_NETWORK_LOCAL_BRIDGE_PREFIX -j SNAT --to-source $SEVPN_LOCAL_ETHERNET_SOURCEIP
  fi
done


_EOF_

# TODO dhcpd (isc-dhcp-server)
