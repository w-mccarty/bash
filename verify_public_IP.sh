#!/bin/bash

#expected public IP:
expected="XXX.XXX.XXX.XXX"

myIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
if [[ "$myIP" == *"$expcted"* ]]
then
  echo "ok"
fi
