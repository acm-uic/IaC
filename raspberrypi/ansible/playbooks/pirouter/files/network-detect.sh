#!/usr/bin/env bash

# This script detects if the network is up or not. If not, we will host our own DHCP server

ETHERNET_INTERFACE=eth0

# Check if NetworkManager-wait-online.service is running
if [ "$(systemctl is-active NetworkManager-wait-online.service)" == "failed" ]; then
    echo "Network is down, setting up static IPv6 address"
    systemctl stop NetworkManager
    ip -6 addr add fdc5:2d46:cdc1:b358::1/64 dev $ETHERNET_INTERFACE

    echo "Network is down, starting DHCP server"
    systemctl start kea-dhcp6-server
else
    echo "Network is up, skipping DHCP server startup"
fi
