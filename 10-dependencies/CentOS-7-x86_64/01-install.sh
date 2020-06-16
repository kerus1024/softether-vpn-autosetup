#!/bin/bash

yum update -y

yum groupinstall -y "Development Tools"

yum install -y wget net-tools dhcp
