#!/bin/bash



cat << _EOF_ > /etc/default/isc-dhcp-server
INTERFACESv4="tap_$SEVPN_NETWORK_LOCAL_BRIDGE_TAP_NAME"
_EOF_

touch $SEVPN_NETWORK_ENVSCRIPT_PATH/restartDHCPD.sh
chmod 700 $SEVPN_NETWORK_ENVSCRIPT_PATH/restartDHCPD.sh

cat << _EOF_ > $SEVPN_NETWORK_ENVSCRIPT_PATH/restartDHCPD.sh
#!/bin/bash
/bin/systemctl stop isc-dhcp-server ; /bin/systemctl stop isc-dhcp-server
_EOF_
