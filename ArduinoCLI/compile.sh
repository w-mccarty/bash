#!/bin/bash
########################################### FLAGS #############################################
#                                                                                             #
#    -p /path/to/folder/    path to folder that holds .ino file (default current directory    #
#    -b ####                baud (default 9600)                                               #
#    -s                     launch screen serial with configured/default baud after upload    #
#                                                                                             #
###############################################################################################

while getopts :sp:b: flag
do
        case "${flag}" in
                p) vPATH=${OPTARG};;
                b) vBAUD=${OPTARG};;
                s) vSCREEN="yes";;
        esac
done
if [ -z "$vPATH" ]; then
        vCOMP=$PWD
fi
if [ -z "$vBAUD" ]; then
        vBAUD=9600
fi
if [ -z "$vSCREEN" ]; then
        vSCREEN="no"
fi

function compileSuccess() {
        echo "Compile SUCCEEDED"
        ~/bin/arduino-cli upload -p $1 --fqbn $2 $3
}

function compileFailed() {
        echo "Compile FAILED"
}

echo "Compiling ${vCOMP}"
vLIST=$(~/bin/arduino-cli board list | sed -n '2 p')
vPORT=$(printf "${vLIST}" | grep '/dev/tty*' | cut -f1 -d ' ')
vFQBN=$(printf "${vLIST}" | grep 'arduino:*' | rev | cut -f2 -d ' ' | rev )
vCORE=$(printf "${vLIST}" | grep 'arduino:*' | rev | cut -f1 -d ' ' | rev )
~/bin/arduino-cli compile --fqbn $vFQBN $vCOMP && compileSuccess $vPORT $vFQBN $vCOMP || compileFailed
if [ "$vSCREEN" = "yes" ]; then
        screen $vPORT $vBAUD
fi
