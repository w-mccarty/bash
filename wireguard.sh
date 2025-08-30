#!/bin/bash

declare -a myInterfaces=("wlp1s0" "enx54af975c3d02")

function findrule() {
	regex="$*${port}.*DENY.*OUT.*Anywhere.*on.*${myInterfaces[0]}.*"
	rule=$(/usr/sbin/ufw status numbered | grep $regex)
	echo "${rule}"
}

f_publicStats () {
        bv=$(curl ipinfo.io )
        bv1=$(echo $bv | grep  -oP 'ip": "\K.*?(?=",)')
        bv2=$(echo $bv | grep  -oP 'hostname": "\K.*?(?=",)')
        bv3=$(echo $bv | grep  -oP 'city": "\K.*?(?=",)')
        bv4=$(echo $bv | grep  -oP 'region": "\K.*?(?=",)')
        bv5=$(echo $bv | grep  -oP 'country": "\K.*?(?=",)')
        bv6=$(echo $bv | grep  -oP 'loc": "\K.*?(?=",)')
        bv7=$(echo $bv | grep  -oP 'org": "\K.*?(?=",)')
        bv8=$(echo $bv | grep  -oP 'postal": "\K.*?(?=",)')
        bv9=$(echo $bv | grep  -oP 'timezone": "\K.*?(?=",)')
        printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
        echo "public $bv1"
        echo "hostname $bv2"
        echo "$bv3, $bv4, $bv5, $bv6"
        echo "$bv7"
        printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

function sudoN-send() {
	local uname=$(who | head -n 1 | cut -d ' ' -f 1)
	local uusid=$(id -u $uname)
	sudo -u $uname DISPLAY=0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uusid/bus notify-send "$@"
}

function allowout {
	for i in "${myInterfaces[@]}"
	do
        sudo ufw delete deny out on $i to any port 80
        sudo ufw delete deny out on $i to any port 443
        sudo ufw delete deny out on $i to any port 53
		sudoN-send "REMOVED block of interface $i to 80 443 53"
	done
}

function denyout {
	for j in "${myInterfaces[@]}"
	do
        sudo ufw deny out on $j to any port 80
        sudo ufw deny out on $j to any port 443
		sudo ufw deny out on $j to any port 53
		sudoN-send "blocked wireless $j to 80 443 53"
	done
}

v1=$(findrule)
if [ -n "$v1" ]; then
	echo "disabling VPN..."
	wg-quick down wg0
	echo "removing VPN firewall rules..."
	allowout
	f_publicStats
else
	echo "initiating VPN connection"
	echo "firewall rule DOES NOT exist..."
	denyout
	echo "connecting to VPN"
	sudo wg-quick up wg0
	f_publicStats
fi
