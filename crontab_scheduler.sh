#!/bin/bash
#schedule this script to run every hour with cron
#will run every X hours starting at 0; once a day set to 24:
schedule=4
now=$(date +%H)

mainFunction(){
  echo "run someting..."
}

if [ $now -eq 0 ] || [ $(( $now % $schedule )) -eq 0 ]; then
	mainFunction
fi
