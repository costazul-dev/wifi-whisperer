#!/bin/bash
#
# Puts the wlan1 interface into monitor mode.
#

echo "Putting wlan1 into monitor mode..."
sudo ip link set wlan1 down
sudo iw wlan1 set monitor
sudo ip link set wlan1 up

echo "Done. Verifying mode:"
iwconfig wlan1