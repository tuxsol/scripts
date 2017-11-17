#!/bin/bash
# very quick and dirty script to rename NEF files to include timestamp from the file on Mac OS X
# run ./renameNEF.sh <source dir> <target dir>

workdir=$1
targetdir=$2

cd $workdir
chflags -R nouchg "$workdir"

for i in `ls *{NEF,MOV}`;  do
        prefix=$(strings $i | head -8 | tail -1)
        prefix_=${prefix// /_}
        echo moving $i to $targetdir/$prefix_"_"$i
        cp $i $targetdir/$prefix_"_"$i

done
exit 0
