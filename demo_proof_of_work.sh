#!/bin/bash 

# rmcd 23 May 2017
# simple mining simulation
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

echo "Please enter a string to hash and mine?"
read input_text

echo "Your input text is : $input_text" 
hash=$(echo $input_text | $shacmd | awk '{print $1}')
echo "with hash $hash"

echo "Now lets try to simulate mining a block using this hash : y/n"
read reply

# SET THE LEVEL OF DIFFICULTY HERE #
#DIFF="0"
#DIFF="00"
DIFF="000"
#DIFF="0000"

if [[ $reply =~ ^[Yy]$ ]] ;then
	i=0
		while true ; do

			nonce=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
			proof_of_work=$(echo $hash $nonce | $shacmd | awk '{print $1}')
			echo -n $input_text $hash $nonce $proof_of_work

				if [[ $proof_of_work == $DIFF* ]]; then
					echo "#------------------------------------------#"
					echo "mining successful : $input_text $hash $nonce $proof_of_work $i"
					exit 0
				fi
	
		echo " attempt $i"
		i=$((i+1))
		done
fi

exit 1

