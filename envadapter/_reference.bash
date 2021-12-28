#!/bin/bash
VAR_LOCAL_ENV_OS=
VAR_LOCAL_ENV_CODENAME=
VAR_LOCAL_ENV_PLATFORM=
VAR_LOCAL_ENV_DHCPD_SERVICE=
check_environment() {
  return 1
}
install_dependencies () {
  return
}
check_selinux () {

  # CentOS 7
  selinux_path=/etc/sysconfig/selinux

  sesetatus=`sestatus | head -n 1 | awk '{print $3}'`

  if [ "$sestatus" = "enabled" ]; then
    if [ ! -z "$VAR_LOCAL_SELINUX_DONT_DISABLE_SELINUX" ]; then
      print_color red SELinux가 활성화 되어 있어요.
      exit 1
    fi

    print_color cyan SELinux를 비활성화 합니다.
    disable_selinux
  fi

}
disable_selinux () {

  if `/sbin/setenforce 0`; then 
    print_color green SELinux를 Permissive 모드로 변경에 성공했어요.
  else
    print_color red SELinux를 Permissive 모드로 변경에 실패했어요.
  fi

  print_color purple SELinux 설정 파일을 변경합니다.

  sed -i 's/^SELINUX=.*/SELINUX=disabled/' $selinux_path

  sesetatus=`sestatus | head -n 1 | awk '{print $3}'`

  if [ "$sestatus" = "Enforcing" ]; then
    print_color red SELinux 모드 변경에 실패 했습니다.
  fi

}
install_dhcp_server () { 
  return
}
configure_dhcp_server () {
  return
}
restart_dhcp_server () {
  return
}
install_dhcp6_server () { 
  return
}
check_firewall () {
  return

  # Centos
  if `systemctl is-active firewalld >/dev/null 2>&1`; then
    print_color red firewalld가 실행중이에요.
  fi

}
append_allow_firewall_on_interface_script () { 
  return
}
install_iptables () {
  return
}
