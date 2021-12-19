#!/bin/bash
source ./lib/common.bash

check_iptables () {
  return
}

check_listener () {
  return
}

build_binary () {
  #make ..
  return
}

copy_binary () {
  return
}

install_tap_up () {
  sysctl -w net.ipv6.conf.$adapter.use_tempaddr=0
  sysctl -w net.ipv6.conf.$adapter.forwarding=0
  sysctl -w net.ipv6.conf.$adapter.accept_ra=0
  sysctl -w net.ipv6.conf.$adapter.autoconf=0
}

# https://www.hpc.mil/program-areas/networking-overview/2013-10-03-17-24-38/ipv6-knowledge-base-ip-transport/enabling-ipv6-in-debian-and-ubuntu-linux


install_tap_down () {
  return
}

dryrun () {
  # PASSWORD SET
  return
}

