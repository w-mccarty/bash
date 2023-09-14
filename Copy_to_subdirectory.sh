#!/bin/bash
Filetype=pdf
VAR=$(ls -d */)
VAR=${VAR// /.}
VAR=${VAR//\//}
ARR=($VAR)
LEN=${#ARR[@]}
for (( i=0; i<$LEN; i++));
do
        REPLACER="${ARR[$i]}";
        REPLACER=${REPLACER//./ };
        cp "$REPLACER"/*."$Filetype" .
done
