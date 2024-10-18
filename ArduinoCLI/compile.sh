#!/bin/bash
pathMAIN="/home/pd/usb/"
filePORT="${pathMAIN}port"
fileFQBN="${pathMAIN}fqbn"
fileCORE="${pathMAIN}core"

function echoInfo() {
	echo " "
	echo "######################################## INFO #########################################"
	echo " "
	arduino-cli version
	echo "https://arduino.github.io/arduino-cli"
	echo " "
	echo "######################################## FLAGS ########################################"
	echo "                                                                                       "
	echo " -?                     print flags                                                    "
	echo " -r                     setup board variables                                          "
	echo " -n name                create new sketch in current directory with name               "
	echo " -p /path/to/folder/    path to folder with .ino file (default current directory       "
	echo " -b #                   baud (default 9600)                                            "
	echo " -s                     launch screen serial with configured/default baud after upload "
	echo "                                                                                       "
	echo "#######################################################################################"
	exit 0
}

function newSketch() {
	echo "creating new sketch ${1}..."
	arduino-cli sketch new $1
	exit 0
}

function fSetup() {
	vLIST=$(~/bin/arduino-cli board list | sed -n '2 p')
        vPORT=$(printf "${vLIST}" | grep '/dev/tty*' | cut -f1 -d ' ')
        vFQBN=$(printf "${vLIST}" | grep 'arduino:*' | rev | cut -f2 -d ' ' | rev )
        vCORE=$(printf "${vLIST}" | grep 'arduino:*' | rev | cut -f1 -d ' ' | rev )
        echo "${vPORT}" > $filePORT
        echo "${vFQBN}" > $fileFQBN
        echo "${vCORE}" > $fileCORE
}

function xSetup() {
	fSetup
	exit 0
}

while getopts :sr?p:b:n: flag
do
        case "${flag}" in
                p) vPATH=${OPTARG};;
                b) vBAUD=${OPTARG};;
                s) vSCREEN="YES";;
		r) xSetup;;
		n) newSketch ${OPTARG};;
		?) echoInfo;;
        esac
done
if [ -z "$vPATH" ]; then
        vCOMP=$PWD
fi
if [ -z "$vBAUD" ]; then
        vBAUD=9600
fi
if [ -z "$vSCREEN" ]; then
        vSCREEN="NO"
fi
function compileSuccess() {
	echo "Compile SUCCEEDED.  Uploading Script"
	~/bin/arduino-cli upload -p $1 --fqbn $2 $3
	echo "Launching screen serial connection"
}
function compileFailed() {
	echo "Compile FAILED"
	exit 1
}
if [ ! -f "$filePORT" ] || [ ! -f "$fileFQBN" ] || [ ! -f "$fileCORE" ]; then
	echo "board variable files not found... running initial setup"
	fSetup
fi
modsecs=$(date --utc --reference=$fileCORE +%s)
nowsecs=$(date +%s)
delta=$(($nowsecs-$modsecs))
echo "board variable files updated ${delta} seconds ago"
if [ $delta -gt 86400 ]; then
	echo "re-running board variable setup..."
	fSetup
fi
echo "Compiling ${vCOMP} for upload.  ${vSCREEN} serial connection at ${vBAUD} following."
vPORT=$(cat "$filePORT")
vFQBN=$(cat "$fileFQBN")
vCORE=$(cat "$fileCORE")
~/bin/arduino-cli compile --fqbn $vFQBN $vCOMP && compileSuccess $vPORT $vFQBN $vCOMP || compileFailed
if [ "$vSCREEN" = "YES" ]; then
	screen $vPORT $vBAUD
fi
