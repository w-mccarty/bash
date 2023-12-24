#! /bin/bash
#tcdump pi interface connected to mgmt interface of switch; when traffic matches pattern it is redirected to this interface
#########################################################################
#VARIABLES
#########################################################################
#pi username
USER='padmin'
#for write stability this will write to 2 usbs, one that is never removed ($USB1) and one that can be safely removed ($USB2) to view pcap files.
#these should exist at /media/<USER>/<DISKNAME>
USB1='REMOVABLE'
USB2='NONREMOVABLE'
#pi ethernet interface name
INTERFACE='eth0'
#this script should be scheduled every 60 mintutes using crontab, if not adjust the variable below
TIMEOUT='60m'
#date used to create filename of pcap file
NOW=`date '%F_%H-%M'`;
#########################################################################
#SCRIPT
#########################################################################
if test -d /media/$USER/$USB2
then
  timeout $TIMEOUT tcpdump -n -i $INTERFACE -s 96 -w /media/$USER/$USB2/$NOW.pcap
  if test -d /media/$USER/$USB1
  then
    mv /media/$USER/$USB2/*.pcap /media/$USER/$USB1
    find /media/$USER/$USB1 -mindepth 1 -type f -mtime +30 -delete
  fi
  mv /home/$USER/*.pcap /media/$USER/$USB2
  find /media/$USER/$USB2 -mindepth 1 -type f -mtime +30 -delete
else
  timeout $TIMEOUT tcpdump -n -i $INTERFACE -s 96 -w /home/$USER/$NOW.pcap
fi
