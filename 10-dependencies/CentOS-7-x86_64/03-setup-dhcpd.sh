#!/bin/bash

# https://serverfault.com/questions/723365/how-to-ignore-unused-network-interfaces-in-dhcpd-on-centos-7

cp /usr/lib/systemd/system/dhcpd.service /etc/systemd/system/dhcpd.service
chmod 755 /etc/systemd/system/dhcpd.service
sed -i '/^ExecStart/s/$/ tap_'$SEVPN_NETWORK_LOCAL_BRIDGE_TAP_NAME'/' /etc/systemd/system/dhcpd.service
/bin/systemctl --system daemon-reload


touch $SEVPN_NETWORK_ENVSCRIPT_PATH/restartDHCPD.sh
chmod 700 $SEVPN_NETWORK_ENVSCRIPT_PATH/restartDHCPD.sh

cat << _EOF_ > $SEVPN_NETWORK_ENVSCRIPT_PATH/restartDHCPD.sh
#!/bin/bash
/bin/systemctl stop dhcpd ; /bin/systemctl start dhcpd
_EOF_
