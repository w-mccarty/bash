#!/bin/bash
#########################################################################################
#FPINGER
#Purpose - Script will ping servers and echo if online (green) or offline (CFF)
#REQUIREMENT: fping installed (sudo apt install -y fping)
#REQUIREMENT: Variables must be configured for item 2 and 4 in this script (see below)
#########################################################################################
#1. CONFIGURABLE VARIABLES... on = 1, off = 0)
Show_Alias=1 #if using bash_aliases or bash.bashrc ie: (alias sv1='ssh username@172.16.0.2 ')
Show_Username=1 
###
#2. SERVER LIST... declare -a arr6=(IP "ALIAS" "USERNAME" "DESCRIPTION") 
#IP is required, for all other items leave as "" if none
declare -a arr0=(172.16.0.2 "sv1" "username" "description of server1")
declare -a arr1=(172.16.0.3 "sv2" "username" "description of server2")
declare -a arr2=(172.16.0.4 "sv3" "username" "description of server3")
###
#3. CONFIGURABLE COLORS... '\033[0;32m' = green, '\033[0;31m' = red, '\033[0m' = reset to default color
CON='\033[0;32m' 
CFF='\033[0;31m' 
CNO='\033[0m'
###
CSUM=$(($Show_Alias * 1 + $Show_Username * 2))
case $CSUM in
	0) echo -e "IP \t \t Description" ;;
	1) echo -e "Alias \t IP \t \t Description" ;;
	2) echo -e "Username@IP \t \t Description" ;;
	3) echo -e "Alias \t Username@IP \t \t Description" ;;
esac
echo  -e "-------------------------------------------------------------------"
#4. CONFIGURE MAXIMUM NUMBER OF SERVERS FOR LOOP (0..X)
for i in {0..2}
###
do
	svar0="arr${i}"[0]
	svar1="arr${i}"[1]
	svar2="arr${i}"[2]
	svar3="arr${i}"[3]
	fping -c1 -t200 ${!svar0} 2>/dev/null 1>/dev/null
	if [ "$?" = 0 ]
	then
		case $CSUM in
			0) echo -e "${CON}${!svar0} \t ${!svar3}${CNO}" ;;
			1) echo -e "${CON}${!svar1} \t ${!svar0} \t ${!svar3}${CNO}" ;;
			2) echo -e "${CON}${!svar2}@${!svar0} \t ${!svar3}${CNO}" ;;
			3) echo -e "${CON}${!svar1} \t ${!svar2}@${!svar0} \t ${!svar3}${CNO}" ;;
		esac
	else
		case $CSUM in
			0) echo -e "${CFF}${!svar0} \t ${!svar3}${CNO}" ;;
			1) echo -e "${CFF}${!svar1} \t ${!svar0} \t ${!svar3}${CNO}" ;;
			2) echo -e "${CFF}${!svar2}@${!svar0} \t ${!svar3}${CNO}" ;;
			3) echo -e "${CFF}${!svar1} \t ${!svar2}@${!svar0} \t ${!svar3}${CNO}" ;;
		esac
	fi
done
echo  -e "-------------------------------------------------------------------"
exit 0
