#!bin/bash

cNOC='\033[0m'
cRED='\033[0;31m'
cORG='\033[0;33m'
cGRN='\033[0;32m'

f_deviceStats () {
	clear
	f_start () {
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	echo "  1) Interface info"
    	echo "  2) Public ip Info"
    	echo "  3) Ping"
    	echo "  4) Serial"
    	#echo "  5)Traceroute"
		echo " "
		echo "  r) Refresh"
    	echo "  e) Exit"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	read -rsn1 n
	case $n in
		1)
			f_intinfo ;;
		2)
			f_publicStats ;;
		3)
			f_ping ;;
		4)
			f_serial ;;
		#5)
		#	f_traceroute ;;
		r)
			f_deviceStats ;;
		e)
			clear
			exit;;
        esac
	}

	f_serial () {
		clear
		dmesg | grep tty
		srl=$(dmesg | grep tty)
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
		echo -n "Enter 'e' to exit or..."
		echo -n "Enter terminal name and baud rate ie ttyS12 9600: " 
		read name
		if [[ $name == "" ]]; then
			f_serial
		elif [[ $name == "e" ]]; then
			f_deviceStats
		else
			sr1=$(echo $name | cut -d ' ' -f 1 | sed 's/ //g')
			sr2=$(echo $name | cut -d ' ' -f 2 | sed 's/ //g')
			if [ $sr1 != "" ] && [ $sr2 != "" ]; then
				if [[ $srl =~ $sr1 ]]; then
				gnome-terminal -- bash -c "screen /dev/${sr1} ${sr2}"
				f_serial
				else
					f_serial
				fi
			else
				f_serial
			fi
		fi
	}

	f_ping () {
		f_ping_quick() {
			echo "starting quick pingtest..."
			ipn=("LO" "GWAY" "DNS" "WEB1" "WEB2" "WEB3" "WEB4")
			ipv=('127.0.0.1' ${arr[0,8]} ${arr[0,8]} '1.1.1.1' '8.8.8.8' 'google.com' 'amazon.com')
			ipl=${#ipv[@]}
			for((i=0;i<$ipl;i++)); do
				mip=$(echo ${ipv[$i]} | cut -d '/' -f 1 | sed 's/ //g')
				dvr=$(fping -c4 -t500 -e -q $mip 2>&1)
				dv0=$(echo $dvr | cut -d ':' -f 1)
				dv1=$(echo $dvr | cut -d ':' -f 2)
				if  [[ $dv1 =~ "," ]]; then
						dv2=$(echo $dv1 | cut -d ',' -f 1 | sed 's/ //g')
						dv3=$(echo $dv1 | cut -d ',' -f 2 | sed 's/ //g')
				else
						dv2=$(echo $dv1 | sed 's/ //g')
						dv3=""
				fi
				if [[ $dv2 =~ "100%" ]]; then
						dvc=$cRED
				elif [[ $dv2 =~ "0%" ]]; then
						dvc=$cGRN
				else
						dvc=$cORG
				fi
				echo -e "$dvc ${ipn[$i]} \t $dv0 \t $dv2 \t $dv3 $cNOC"
			done
			printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
			f_ping
		}
		echo "1) Quick Ping test"
		echo "2) Custom Ping test"
		echo "e) Exit"
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
		read -rsn1 name
		if [[ $name == "e" ]]; then
			f_deviceStats
		elif [[ $name == "1" ]]; then
			f_ping_quick
		elif [[ $name == "2" ]]; then
			f_ping_custom
		else
			f_ping
		fi
	}

	f_publicStats () {
	clear
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
		f_start
	}

	f_intinfo () {
		echo "available interfaces"
		vint=()
		for ((i=0;i<$dvt;i++)); do
			if [ "${arr[$i,3]}" != "--" ] && [ "${arr[$i,3]}" != "" ] && [ "${arr[$i,3]}" != " " ]; then
				v=$(echo "$i | ${arr[$i,3]}")
				echo $v
				vint+=($i)
			fi
		done
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
		read -rsn1 n
		if [[ " ${vint[*]} " =~ $n ]]; then
			clear
			readarray -t arr2 < <(nmcli con show ${arr[$n,3]})
			rlen=${#arr2[@]}
			for ((i=0;i<$rlen;i++)); do
				echo ${arr2[i]}
			done
			printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
			f_start
		else
			echo "$n NOT FOUND.  Please try again."
			printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
			f_start
		fi
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
		f_start
	}

	dvt=$(nmcli dev status | wc -l)
	dvc=$(nmcli dev status)
	dvc="${dvc//' (externally)'/'(externally)'}"
	declare -A arr
	for ((i=1;i<$dvt;i++)); do
		for ((j=1;j<5;j++)); do
			dv=$(echo $dvc | cut -d ' ' -f$((i * 4 + j)))
			arr[$((i - 1)),$((j - 1))]=${dv}
		done
	done
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	for ((k=0;k<$((dvt - 1));k++)); do
		bc="${arr[$k,0]} ${arr[$k,1]} ${arr[$k,2]} ${arr[$k,3]}"
		if echo $bc | grep "disconnected" > /dev/null; then
			for ((m=4;m<16;m++)); do
				arr[$k,$m]="--"
			done
			arr[$k,7]='\033[0;31m'
		elif echo $bc | grep "connected" > /dev/null; then
			dv="${arr[$k,0]}"
			arr[$k,4]=$(/sbin/ip -o -4 addr list $dv | grep -oP 'inet\K.*?(?=scope)' | cut -d ' ' -f2 | sed 's/ //g')
			mac=$(/sbin/ip -o -4 link list $dv | grep -oP 'link/ether\K.*?(?=brd)' | sed 's/ //g')
			if [[ $mac == "" ]]; then
				arr[$k,5]="--"
			else
				arr[$k,5]=$(/sbin/ip -o -4 link list $dv | grep -oP 'link/ether\K.*?(?=brd)' | sed 's/ //g')
			fi
			pv6=$(/sbin/ip -o -6 addr list $dv | grep -oP 'inet6\K.*?(?=scope)' | sed 's/ //g')
			arr[$k,6]=$(/sbin/ip -o -6 addr list $dv | grep -oP 'inet6\K.*?(?=scope)' | sed 's/ //g')
			arr[$k,7]='\033[0;32m'
			arr[$k,8]=$(nmcli device show $dv | grep 'IP4.GATEWAY' | cut -d ':' -f2 | sed 's/ //g' | tr '\n' ';' | sed '$s/;$/\n/')
			arr[$k,9]=$(nmcli device show $dv | grep 'IP6.GATEWAY' | cut -d ':' -f2 | sed 's/ //g' | tr '\n' ';' | sed '$s/;$/\n/')
			arr[$k,10]=$(nmcli device show $dv | grep 'IP4.DNS' | cut -d ':' -f2 | sed 's/ //g' | tr '\n' ';' | sed '$s/;$/\n/')
			arr[$k,11]=$(nmcli device show $dv | grep 'IP4.DOMAIN' | cut -d ':' -f2 | sed 's/ //g' | tr '\n' ';' | sed '$s/;$/\n/')
			arr[$k,12]=$(nmcli device show $dv | grep 'IP4.ROUTE' | cut -d ':' -f2 | sed 's/ //g' | tr '\n' ';' | sed '$s/;$/\n/')
			arr[$k,13]=$(nmcli con show hwlan | grep 'ipv4.method' | cut -d ':' -f2 | sed 's/ //g' | tr '\n' ';' | sed '$s/;$/\n/')
			arr[$k,14]=$(nmcli con show hwlan | grep 'ipv6.method' | cut -d ':' -f2 | sed 's/ //g' | tr '\n' ';' | sed '$s/;$/\n/')
			arr[$k,15]=$(nmcli device show $dv | grep 'IP6.ROUTE' | cut -d ':' -f2 | sed 's/ //g' | tr '\n' ';' | sed '$s/;$/\n/')
		else
			for ((m=4;m<16;m++)); do
				arr[$k,$m]="--"
			done
			arr[$k,7]='\033[0;37m'
		fi
		echo -e "${arr[$k,7]}$k | ${arr[$k,0]} ${arr[$k,1]} ${arr[$k,2]} ${arr[$k,3]}${cNOC}"
		if echo $bc | grep -w 'connected' > /dev/null; then 
			echo -e "${arr[$k,7]}  | 	${arr[$k,4]} (${arr[$k,13]}) via ${arr[$k,8]} on ${arr[$k,5]}${cNOC}"
			if [ ${#arr[$k,10]} -ge 3 ]; then
	                        echo -e "${arr[$k,7]}  | 		DNS ${arr[$k,10]} on DOMAIN ${arr[$k,11]}${cNOC}"
	                fi
	                if [ ${#arr[$k,12]} -ge 3 ]; then
	                        echo -e "${arr[$k,7]}  | 		ROUTE ${arr[$k,12]}${cNOC}"
	                fi
			echo -e "${arr[$k,7]}  | 	${arr[$k,6]}$ (${arr[$k,14]}) via ${arr[$k,9]}${cNOC}"
			if [ ${#arr[$k,15]} -ge 3 ]; then
				echo -e "${arr[$k,7]}  | 		ROUTE ${arr[$k,15]}${cNOC}"
			fi
		fi
	done
	f_start
}
f_deviceStats
