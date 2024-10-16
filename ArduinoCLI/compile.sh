#!/bin/bash

while getopts ":s" option; do
  case $option in
    s)
      vSCREEN="yes" #LAUNCH SCREEN 9600 BAUD
      ;;
    *)
      vSCREEN="no"
      ;;
  esac
done

function compileSuccess() {
        echo "Compile SUCCEEDED"
        ~/bin/arduino-cli upload -p $1 --fqbn $2 $3
}

function compileFailed() {
        echo "Compile FAILED"
}

vCOMP=$PWD
echo "Compiling ${vCOMP}"
vLIST=$(~/bin/arduino-cli board list | sed -n '2 p')
vPORT=$(printf "${vLIST}" | grep '/dev/tty*' | cut -f1 -d ' ')
vFQBN=$(printf "${vLIST}" | grep 'arduino:*' | rev | cut -f2 -d ' ' | rev )
vCORE=$(printf "${vLIST}" | grep 'arduino:*' | rev | cut -f1 -d ' ' | rev )
~/bin/arduino-cli compile --fqbn $vFQBN $vCOMP && compileSuccess $vPORT $vFQBN $vCOMP || compileFailed
if [ "$vSCREEN" = "yes" ]; then
        screen $vPORT 9600
fi
