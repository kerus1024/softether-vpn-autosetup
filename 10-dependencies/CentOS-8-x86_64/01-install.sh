#!/bin/bash

dnf makecache

dnf update -y

dnf groupinstall -y "Development Tools"

dnf install -y wget iptables-services dhcp-server
