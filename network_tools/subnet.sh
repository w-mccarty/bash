#!bin/bash
read -p "Enter IPV4 address: " Var
read -p "Enter Mask: " Mas

#Decimal to Binary
dec_2_bin () {
  D2B=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})
  NC=($(echo "$1" | tr '.' '\n'))
  BN=""
  for j in $(seq 0 3);
  do
    BN="$BN${D2B[${NC[${j}]}]}"
  done
  echo $BN
}

spacer () {
  BX=$1
  BL="${#BX}"
  BD=""
  let BM=$((15 - BL))
  for i in $(seq 1 $BM);
  do
    BD="$BD#"
  done
  BX="$BX$BD"
  echo $BX | sed 's/#/ /g'
}

#BINARY TO DECIMAL
bin_2_dec () {
  NB=("0" "-24" "8" "-16" "16" "-8" "24" "32")
  NA=$1 #name of binary var
  NC=""
  for i in $(seq 0 3);
  do
    NC="$NC$((2#${NA:${NB[$(($i * 2))]}:${NB[$((($i * 2) + 1))]}}))."
  done
  NC=${NC::-1}
  if [[ $2 -eq 0 ]]; then #if $2 = 0, remove decimals and replace empty space with zeros
    DV=($(echo "$NC" | tr '.' '\n'))
    DA=""
    for k in $(seq 0 3);
    do
      dlen="${DV[${k}]}"
      dcen=${#dlen}
      if [ $dcen -eq 2 ]; then
        DC="0$dlen"
      elif [ $dcen -eq 1 ]; then
        DC="00$dlen"
      else
        DC=$dlen
      fi
      DA="$DA$DC"
    done
    NC=$DA
  fi
  echo $NC
}

ip_class () {
  VBN=$(dec_2_bin $Var)
  tIP=
  echo "$(spacer 'IP') - $(spacer $Var) - $VBN"
  MBN=$(dec_2_bin $Mas)
  echo "$(spacer 'Mask') - $(spacer $Mas) - $MBN"
  #CIDR
  res="${MBN//[^1]}"
  res="${#res}"
  hos=$((32-$res))
  #echo "          /$res CIDR network bits with $hos host bits" NOW BELOW ON LINE 128
  #NETWORK ADDRESS
  NBIT=${VBN:0:-"${hos}"}
  for i in $(seq 1 $hos);
  do
    NBIT="${NBIT}0"
  done
  GATEWAY=$(bin_2_dec $NBIT 1)
  echo "$(spacer 'GATEWAY') - $(spacer $GATEWAY) - $NBIT"
  #FIRST IP
  NFIP="${NBIT::-1}1"
  NFIC=$(bin_2_dec $NFIP 1)
  echo "$(spacer 'FIRST IP') - $(spacer $NFIC) - $NFIP"
  #LAST IP
  NBIL=${VBN:0:-"${hos}"}
  for i in $(seq 1 $hos);
  do
    NBIL="${NBIL}1"
  done
  NBIL="${NBIL::-1}0"
  NBIC=$(bin_2_dec $NBIL 1)
  echo "$(spacer 'LAST IP') - $(spacer $NBIC) - $NBIL"
  #BROADCAST
  NBIL=${VBN:0:-"${hos}"}
  for i in $(seq 1 $hos);
  do
    NBIL="${NBIL}1"
  done
  NBIC=$(bin_2_dec $NBIL 1)
  echo "$(spacer 'BROADCAST') - $(spacer $NBIC) - $NBIL"
  #LIST CLASSES AND HOST NET BITS
  ip=$(bin_2_dec $NBIT 0)
  atype="public"
  cbits=0
  if [[ $ip -ge 001000000000 && $ip -le 127255255255 ]] ; then
    if [[ $ip -ge 001000000000 && $ip -le 127255255255 ]] ; then
	  atype="private"
	fi
    class="A"
	cbits=8
  elif [[ $ip -ge 128000000000 && $ip -le 191255255255 ]] ; then
    if [[ $ip -ge 172016000000 && $ip -le 172031255255 ]] ; then
	  atype="private"
	fi
    class="B"
	cbits=16
  elif [[ $ip -ge 192000000000 && $ip -le 223255255255 ]] ; then
    if [[ $ip -ge 192168000000 && $ip -le 192168255255 ]] ; then
	  atype="private"
	fi
    class="C"
	cbits=24
  elif [[ $ip -ge 224000000000 && $ip -le 239255255255 ]] ; then
    class="D"
  else
    class="E"
  fi
  let hbits=$((res - cbits))
  echo " "
  echo "/$res CIDR network bits with $hos host bits"
  echo "        - class $class $atype ($cbits network + $hbits shared bits)"
  let hbits=(2**$hbits)
  echo "        - network(s): $hbits"
  let bbits=(2**$hos)-2
  echo "        - host(s) per network: $bbits"
}

#Check IP and MASK
if [[ "$Var" =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; then
  MSP=($(echo "$Mas" | tr '.' '\n'))
  List="255 254 252 248 240 224 192 128 0"
  if [[ ${MSP[0]} < ${MSP[1]} || ${MSP[1]} < ${MSP[2]} || ${MSP[2]} < ${MSP[3]} ]]; then #test mask length
    echo "mask not ok"
  else
    for i in $(seq 0 3); #test if mask val in List
    do
      if ! [[ $List =~ (^|[[:space:]])${MSP["${i}"]}($|[[:space:]]) ]]; then
        echo "MASK NOT OK"
		exit 0
      else
		continue
      fi
    done
	ip_class
  fi
else
  echo "IP NOT OK"
fi
