#!/bin/bash
/usr/bin/curl -L https://github.com/kerus1024/softether-vpn-autosetup/archive/master.tar.gz > softether-vpn-autosetup.tar.gz
mkdir softether-vpn-autosetup
tar xzf softether-vpn-autosetup.tar.gz --strip 1 -C ./softether-vpn-autosetup
cd ./softether-vpn-autosetup
sudo bash run.sh
