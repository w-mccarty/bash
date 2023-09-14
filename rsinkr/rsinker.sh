#!/bin/bash

hline () {
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

function_remote () {
	function_newremote () {
		COUNT="$(find ~/rsinkr/servers -maxdepth 1 -type d | wc -l)"
		NOUNT="$((COUNT - 2))"
		declare -a arr
		for entry in ~/rsinkr/servers/*
		do
			arr=("${entry[@]##*/}")  
			array=("${array[@]}" "${arr}")
		done
		echo "please select a remote server"
		echo " "
		for ((i = 0 ; i <= $NOUNT ; i++)); do
			echo "$i = ${array[$i]}"
		done
		hline
	}
	function_newdir () {
		read -rsn1 a
		if (($a <= $NOUNT))
		then
			RSRV="${array[$a]}"
			COUNT="$(find ~/rsinkr/servers/$RSRV/directory/ -maxdepth 1 -type d | wc -l)"
			DOUNT="$((COUNT - 2))"
			declare -a carr
			for centry in ~/rsinkr/servers/$RSRV/directory/*
			do
				carr=("${centry[@]##*/}")  
				carray=("${carray[@]}" "${carr}")
			done
			echo "The following directories for $RSRV server already exist:"
			echo " "
			for ((i = 0 ; i <= $DOUNT ; i++)); do
				echo "$i = ${carray[$i]}"
			done
			echo " "
			echo "enter folder name to create in ~/rsinkr/servers/${array[$a]}/directory"
			echo "please only use numbers, letters, and underscores in the name"
			echo "the name should describe the remote directory & be unique and identifiable"
			hline
			read RDIR
			NRDIR="~/rsinkr/servers/${RSRV}/directory/${RDIR}"
			if [ -d ~/rsinkr/servers/${RSRV}/directory/${RDIR} ]
			then
				echo "ERROR: directory already exists, please try again"
				echo "press 1 to retry, press anything else to return to main menu"
				hline
				read -rsn1 a
				if [ "$a" = "1" ]
				then
					function_remote
				else
					function_start
				fi	
			else
				mkdir ~/rsinkr/servers/${RSRV}/directory/${RDIR}
				mkdir ~/rsinkr/servers/${RSRV}/directory/${RDIR}/files
				hline
				echo "${RDIR} has been created at path ${NRDIR}"
				echo "enter full remote location path"
				echo "for example: /home/user/directory"
				echo "NOTE: for the remote user home diretory enter: ~"
				echo "NOTE: DO NOT add '/' to end of line"
				read RLOC
				Rip="~/rsinkr/servers/${RSRV}/directory/${RDIR}/dir.txt"
				hline
				echo "$Rip has been created"
				echo $RLOC > ~/rsinkr/servers/${RSRV}/directory/${RDIR}/dir.txt
				hline
				echo "enter filetype to sync"
				echo "NOTE: for example for all text files enter: *.txt"
				echo "NOTE: for ALL FILES enter: *"
				echo "NOTE: for a SINGLE FILE: enter filename (test.txt)"
				read RFileTYP
				RFP="~/rsinkr/servers/${RSRV}/directory/${RDIR}/filetype.txt"
				echo "$RFP has been created"
				echo "$RFileTYP" > ~/rsinkr/servers/$RSRV/directory/$RDIR/filetype.txt
				hline
				echo "press 1 to add another remote directory, press anything else to return to main menu"
				read -rsn1 a
				if [ "$a" = "1" ]
				then
					function_remote
				else
					function_start
				fi	
			fi
		elif (($a > $NOUNT))
		then
			echo "ERROR: $a is not a valid option, please try again"
			echo "press 1 to retry, press anything else to return to main menu"
			hline
			read -rsn1 a
			if [ "$a" = "1" ]
			then
				function_remote
			else
				function_start
			fi	
		fi
	}
	function_newremote
	function_newdir
}

function_newserver () {
	echo "the following servers are already configured:"
	COUNT="$(find ~/rsinkr/servers -maxdepth 1 -type d | wc -l)"
	NOUNT="$((COUNT - 2))"qd
	declare -a arr
	for entry in ~/rsinkr/servers/*
	do
		arr=("${entry[@]##*/}")  
		array=("${array[@]}" "${arr}")
	done
	#echo ${array[@]} > ~/rsinkr/array1.txt
	for ((i = 0 ; i <= $NOUNT ; i++)); do
		echo "$i = ${array[$i]}"
	done
	echo " "
	echo "enter NEW server name to create in ~/rsinkr/servers"
	echo "this name should describe the remote server & be unique and identifiable"
	hline
	read NDIR
	NDIRTEST="~/rsinkr/servers/${NDIR}"
	if [ -d ~/rsinkr/servers/${NDIR} ] 
	then
		hline
		echo "Directory $NDIRTEST already exists." 
		echo "press 1 to retry, press anything else to return to main menu"
		hline
		read -rsn1 a
		if [ "$a" = "1" ]
		then
			function_newserver
		else
			function_start
		fi
	else
		mkdir ~/rsinkr/servers/${NDIR}
		mkdir ~/rsinkr/servers/${NDIR}/directory
		mkdir ~/rsinkr/servers/${NDIR}/backup
		mkdir ~/rsinkr/servers/${NDIR}/backup/staging
		echo "$NDIRTEST has been created"
		hline
		echo "enter the server SSH username for $NDIR"
		read RNAME
		hline
		echo "enter server IP address for $NDIR"
		read RIP
		SITETEXT=${RNAME}@${RIP}
		echo $SITETEXT > ~/rsinkr/servers/${NDIR}/ip.txt
		hline
		echo "$RNAME@$RIP has been stored in $NDIRTEST/ip.txt"	
		function_start
	fi
	return 5
}

function_pull () {
	function_countremote () {
		COUNT="$(find ~/rsinkr/servers -maxdepth 1 -type d | wc -l)"
		NOUNT="$((COUNT - 2))"
		declare -a arr
		for entry in ~/rsinkr/servers/*
		do
			arr=("${entry[@]##*/}")  
			array=("${array[@]}" "${arr}")
		done
		echo "please select a remote server to PULL from"
		for ((i = 0 ; i <= $NOUNT ; i++)); do
			echo "$i = ${array[$i]}"
		done
		hline
	}
	function_pdir () {
		read -rsn1 a
		if (($a <= $NOUNT))
		then
			RSRV="${array[$a]}"
			ipval=$(<~/rsinkr/servers/$RSRV/ip.txt)
			COUNT="$(find ~/rsinkr/servers/$RSRV/directory -maxdepth 1 -type d | wc -l)"
			DOUNT="$((COUNT - 2))"
			declare -a darr
			for entry in ~/rsinkr/servers/$RSRV/directory/*
			do
				darr=("${entry[@]##*/}")  
				darray=("${darray[@]}" "${darr}")
			done
			echo "please select a directory in $RSRV to PULL to"
			echo " "
			for ((i = 0 ; i <= $DOUNT ; i++)); do
				echo "$i = ${darray[$i]}"
			done
			hline
			read -rsn1 a
			if (($a <= $DOUNT))
			then
				RSDR="${darray[$a]}"
				DESC="pull"
				rdloc=$(<~/rsinkr/servers/$RSRV/directory/$RSDR/dir.txt)
				rdftp=$(<~/rsinkr/servers/$RSRV/directory/$RSDR/filetype.txt)
				fpull () {
					echo "PULL from $ipval:$rdloc/$rdftp"
					echo "PULL into ~/rsinkr/servers/$RSRV/directory/$RSDR/files"
					echo "Press 1 to perform rsync PULL, press any key to exit."
					hline
					read -rsn1 n
					if [ "$n" = "1" ]
					then
						NOW=$(date  +%Y-%m-%d_%H-%M-%S)
						echo "backup initated for ~/rsinkr/servers/$RSRV/directory/$RSDR/files"
						mkdir ~/rsinkr/servers/$RSRV/backup/staging/$NOW
						cp -r ~/rsinkr/servers/$RSRV/directory/$RSDR/files ~/rsinkr/servers/$RSRV/backup/staging/$NOW
						tar -czf ~/rsinkr/servers/$RSRV/backup/${RSDR}_${NOW}_${DESC}.tar.gz -P ~/rsinkr/servers/$RSRV/backup/staging/$NOW
						rm -rf ~/rsinkr/servers/$RSRV/backup/staging/$NOW
						echo "backup complete: ~/rsinkr/servers/$RSRV/backup/${RSDR}_${NOW}_${DESC}.tar.gz"
						echo "pull initiated for $rdloc/$rdftp  from $ipval"
						rm -rf ~/rsinkr/servers/$RSRV/directory/$RSDR/files/*
						rsync $ipval:$rdloc/$rdftp ~/rsinkr/servers/$RSRV/directory/$RSDR/files
						echo "pull complete to ~/rsinkr/servers/$RSRV/directory/$RSDR/files"
						hline
						fpull
					else
						function_start
					fi
				}
				fpull
			elif (($a > $DOUNT))
			then
				echo "ERROR: $a is not a valid option, please try again"
				echo "press 1 to retry, press anything else to return to main menu"
				hline
				read -rsn1 a
				if [ "$a" = "1" ]
				then
					function_pull
				else
					function_start
				fi	
			fi
			
		elif (($a > $NOUNT))
		then
			echo "ERROR: $a is not a valid option, please try again"
			echo "press 1 to retry, press anything else to return to main menu"
			hline
			read -rsn1 a
			if [ "$a" = "1" ]
			then
				function_pull
			else
				function_start
			fi	
		fi
	}
	function_countremote
	function_pdir
}

function_push () {
	function_countremote () {
		COUNT="$(find ~/rsinkr/servers -maxdepth 1 -type d | wc -l)"
		NOUNT="$((COUNT - 2))"
		declare -a arr
		for entry in ~/rsinkr/servers/*
		do
			arr=("${entry[@]##*/}")  
			array=("${array[@]}" "${arr}")
		done
		echo "please select a remote server to PUSH to"
		for ((i = 0 ; i <= $NOUNT ; i++)); do
			echo "$i = ${array[$i]}"
		done
		hline
	}
	function_newdir () {
		read -rsn1 a
		if (($a <= $NOUNT))
		then
			RSRV="${array[$a]}"
			ipval=$(<~/rsinkr/servers/$RSRV/ip.txt)
			COUNT="$(find ~/rsinkr/servers/$RSRV/directory -maxdepth 1 -type d | wc -l)"
			DOUNT="$((COUNT - 2))"
			declare -a darr
			for entry in ~/rsinkr/servers/$RSRV/directory/*
			do
				darr=("${entry[@]##*/}")  
				darray=("${darray[@]}" "${darr}")
			done
			echo "please select a directory in $RSRV to PUSH from"
			for ((i = 0 ; i <= $DOUNT ; i++)); do
				echo "$i = ${darray[$i]}"
			done
			hline
			read -rsn1 a
			if (($a <= $DOUNT))
			then
				RSDR="${darray[$a]}"
				DESC="push"
				rdloc=$(<~/rsinkr/servers/$RSRV/directory/$RSDR/dir.txt)
				rdftp=$(<~/rsinkr/servers/$RSRV/directory/$RSDR/filetype.txt)
				fpush () {
					echo "PUSH from ~/rsinkr/servers/$RSRV/directory/$RSDR/files" 
					echo "PUSH into $ipval:$rdloc"
					echo "Press 1 to perform rsync PUSH, press any key to exit."
					hline
					read -rsn1 n
					if [ "$n" = "1" ]
					then
						NOW=$(date  +%Y-%m-%d_%H-%M-%S)
						echo "backup initated for $ipval:$rdloc"
						mkdir ~/rsinkr/servers/$RSRV/backup/staging/$NOW
						rsinkr $ipval:$rdloc/$rdftp ~/rsinkr/servers/$RSRV/backup/staging/$NOW
						tar -czf ~/rsinkr/servers/$RSRV/backup/${RSDR}_${NOW}_${DESC}.tar.gz -P ~/rsinkr/servers/$RSRV/backup/staging/$NOW
						rm -rf ~/rsinkr/servers/$RSRV/backup/staging/$NOW
						echo "backup complete: ~/rsinkr/servers/$RSRV/backup/${RSDR}_${NOW}_${DESC}.tar.gz"
						echo "push initiated to $ipval:$rdloc"
						rsync ~/rsinkr/servers/$RSRV/directory/$RSDR/files/* $ipval:$rdloc
						echo "push complete to $ipval:$rdloc"
						hline
						fpush
					else
						function_start
					fi
				}
				fpush
			elif (($a > $DOUNT))
			then
				echo "ERROR: $a is not a valid option, please try again"
				echo "press 1 to retry, press anything else to return to main menu"
				hline
				read -rsn1 a
				if [ "$a" = "1" ]
				then
					function_push
				else
					function_start
				fi	
			fi
			
		elif (($a > $NOUNT))
		then
			echo "ERROR: $a is not a valid option, please try again"
			echo "press 1 to retry, press anything else to return to main menu"
			hline
			read -rsn1 a
			if [ "$a" = "1" ]
			then
				function_push
			else
				function_start
			fi	
		fi
	}
	function_countremote
	function_newdir
}

function_info () {
echo "1. ABOUT"
echo "      Rsinkr automates simple repeat rsync transfers"
echo "      Rsinkr ensures backup occurs with every transfer"
echo "2. SETUP & REQUIREMENTS"
echo "      SSH public key MUST be deployed on remote server before using Rsinkr"
echo "      Rsinkr directory MUST be put in the local home folder ~/rsinkr"
echo "      Rsinkr MUST be launched from ~/rsinkr/run.sh"
echo "3. RECOMMENDATIONS"
echo "      Please read carefully when configuring directories to sync"
echo "      As an  example Rsinkr runs the following format for a PULL:"
echo " "
echo "        rsync <ip.txt>:<dir.txt>/<filetype.txt> ~/LOCAL_PATH"
echo " "
echo "      the following configuration files can be edited manually:"
echo "        1) remote 'username@IP'"
echo "          ~/rsinkr/servers/<SERVER>ip.txt"
echo "        2) remote directory"
echo "          ~/rsinkr/servers/<SERVER>/directory/<DIRECTORY>/dir.txt"
echo "        3) remote filetype"
echo "          ~/rsinkr/servers/<SERVER>/directory/<DIRECTORY>/filetype.txt"
echo "      Note: backups of all transfers are stored in:"
echo "        ~/rsinkr/servers/<SERVER>/backup"
echo "4. WARNING"
echo "      This scripts creator is not resposible for any data loss or damage"
hline
read -p "press 'enter' to return to main menu"
hline
function_start
}

function_start () {
	echo "    _____      _       _         "
	echo "   |  __ \    (_)     | |        "
	echo "   | |__) |___ _ _ __ | | ___ __ "
	echo "   |  _  // __| | '_ \| |/ | '__|"
	echo "   | | \ \\__  | | | | |   <| |   "
	echo "   |_|  \_|___|_|_| |_|_|\_|_|   "
	echo "                                 "
	hline
	echo "1) Add a remote server"
	echo "2) Add a backup folder to an existing server"
	echo "3) Rsync PULL from remote server"
	echo "4) Rsync PUSH to remote server"
	echo "5) About Rsinkr"
	echo "6) Quit"
	hline

	read -rsn1 n
	case $n in
		1)
			function_newserver ;;
		2)
			function_remote ;;
		3) 
			function_pull ;;
		4)
			function_push ;;
		5)
			function_info ;;
		6) 
			exit;;
	esac
}

FILE=~/rsinkr/acknowledged.txt
if [ -f "$FILE" ]; then
	echo "WARNING: You assume responsibility for all data loss or damage by running this script.  Please read and follow all directions carefully."
	hline
	function_start
else 
	hline
    echo "Welcome to  Rsinkr 1.0"
	echo "    _____      _       _         "
	echo "   |  __ \    (_)     | |        "
	echo "   | |__) |___ _ _ __ | | ___ __ "
	echo "   |  _  // __| | '_ \| |/ | '__|"
	echo "   | | \ \\__  | | | | |   <| |   "
	echo "   |_|  \_|___|_|_| |_|_|\_|_|   "
	echo "                                 "
	echo "Rsinkr has detected this is your first time running this script..."
	hline
	echo "To use this script, you (the user) must acknowledge the following:"
	echo "    1. User acknowledges they will read and follow all directions carefully"
	echo "    2. User acknowledges responsibility for all actions taken "
	echo "    3. User acknowledges responsibility for the result of any action taken "
    echo "    4. This scripts creator is not resposible for any data loss or damage"
	hline
	read -p "press 'enter' to acklowledge this and proceed."
	touch ~/rsinkr/acknowledged.txt
	read -p "Acknowledgement complete.  press 'enter' to read additonal information"
	function_info
fi
