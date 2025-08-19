function findrule() {
	regex="$*${port}.*DENY.*OUT.*Anywhere.*on.*wlp1s0.*"
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
	#get username
	local uname=$(who | head -n 1 | cut -d ' ' -f 1)
	#get uuid
	local uusid=$(id -u $uname)
	sudo -u $uname DISPLAY=0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uusid/bus notify-send "$@"
}

function allowout {
  sudo ufw delete deny out on wlp1s0 to any port 80
  sudo ufw delete deny out on wlp1s0 to any port 443
  sudo ufw delete deny out on wlp1s0 to any port 53
  sudoN-send "REMOVED block of wireless wlp1s0 to 80 443 53"
}

function denyout {
  sudo ufw deny out on wlp1s0 to any port 80
  sudo ufw deny out on wlp1s0 to any port 443
	sudo ufw deny out on wlp1s0 to any port 53
	sudoN-send "blocked wireless wlp1s0 to 80 443 53"
}

v1=$(findrule)
#echo $v1
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
