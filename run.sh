#!/bin/bash

#MIT License

#Copyright (c) 2020 Kerus Ashe <github.com/kerus1024>

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

/usr/bin/clear 2> /dev/null
. ./05-initial-config/00-env.sh
echo
echo
echo
echo "SoftEther VPN Auto Setup"
echo "          author: Kerus Ashe < https://github.com/kerus1024/softether-vpn-autosetup >"
echo 
echo
echo

. ./05-initial-config/01-check-environment.sh
. ./05-initial-config/02-check-rootpermission.sh
. ./05-initial-config/03-check-security.sh
. ./05-initial-config/04-check-listener.sh
. ./05-initial-config/05-configure-private-settings.sh
. ./05-initial-config/06-detect-ethernet.sh
. ./10-dependencies/00-dependency-auto.sh
. ./15-setup/00-get.sh
. ./15-setup/01-extract.sh
. ./15-setup/02-building.sh
#. ./15-setup/03-


exit 0
