#!/bin/bash
if [[ "$OSTYPE" == "linux-gnu" ]]; then

       shacmd=" sha256sum "

elif [[ "$OSTYPE" == "darwin"* ]]; then

       shacmd=" shasum -a 256 " 

else
        echo "sorry you need to locate your SHA commands and modify this script"
	exit 2 
fi
###############################################################################
chainFile=./demo.chain.txt
{
    read
    while IFS=';' read -r blockID data hashPreviousBlock hash nonce hashHashNonce 
    do 
	valHash=$(echo "$data$hashPreviousBlock" | $shacmd | awk '{print $1}')
	valHash1=$(echo "$hash$nonce" | $shacmd | awk '{print $1}')
	
	if [[ "$valHash" == "$hash" ]]; then
		echo -n "OK "
	else
		echo "$block $blockID is corrupt"
	fi

	if [[ "$valHash1" == "$hashHashNonce" ]]; then
		echo OK
	else
		echo "$block $blockID is corrupt"
	fi
    done
} < $chainFile
