if (nmcli c show --active | grep vpn); then
	echo "connected"
else
	echo "disconnected"
fi
