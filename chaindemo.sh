#!/bin/bash 

# rmcd June 5 20181
# simple blockchain simulation
# version 0.1

# This program is free software: you can redistribute it and/or modify  
# it under the terms of the GNU General Public License as published by  
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# FOR DEMO ONLY !!

if [[ "$OSTYPE" == "linux-gnu" ]]; then

       shacmd=" sha256sum "

elif [[ "$OSTYPE" == "darwin"* ]]; then

       shacmd=" shasum -a 256 " 

else
        echo "sorry you need to locate your SHA commands and modify this script"
	exit 2 
fi
###############################################################################
outfile=./demo.chain.txt # This will be our blockchain database in a text file

echo "BLOCKCHAIN SIMULATION FOR ROTARY CLUB DE BILT BILTHOVEN"
echo "Please enter the number of blocks you want to simulate?"
read numberBlocks 

echo "Please enter text for our genesis block"
read textGenBlock

hashGenBlock=$(echo $textGenBlock | $shacmd | awk '{print $1}')
echo Genesis block : $textGenBlock $hashGenBlock
echo "genesisblock;  $textGenBlock ; $hashGenBlock" > $outfile

hashLastBlock=$hashGenBlock
echo Hit Enter to run
read start

echo "we will stimulate $numberBlocks blocks"
counter=0
block=0
while [ $block -lt $numberBlocks ] ; do

echo "Please enter the block data for block $block?"
read input_text
echo input = $input_text

hash=$(echo $input_text$hashLastBlock | $shacmd | awk '{print $1}')
echo "with hash $hash"

# SET THE LEVEL OF DIFFICULTY HERE #
DIFF="0"

  while true ; do
	nonce=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
	proof_of_work=$(echo $hash$nonce | $shacmd | awk '{print $1}')
	echo -n $input_text $hash $nonce $proof_of_work

		if [[ $proof_of_work == $DIFF* ]]; then
			echo "#------------------------------------------#"
			echo "mining successful for block $block : $hash $nonce $proof_of_work $i"
			echo "block=$block;$input_text;$hashLastBlock;$hash;$nonce;$proof_of_work" >> $outfile
			hashLastBlock=$proof_of_work
			break
		fi

	echo " attempt $counter"
	counter=$((counter+1))
  done
  block=$((block+1))

done # while for blocks

exit 0
