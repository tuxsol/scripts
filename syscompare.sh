#######################################################################
# Filename:     syscompare.sh
Version=“1.0”
# Author:       rmcd (Robert D. McDonnell)
# Date:         Feb 2017
# Purpose:      scan and compare UNIX filesystems and files
# Usage:        see --help
# Requirements: gnu getopts
# Parameters:    -
# Return Values: ExitCode
#
# History / Known Bugs
# Date        Version Name            Description
#-----------------------------------------------------------------
#  Feb 2017 1.0     Robert D. McDonnell   - Initial version
#######################################################################
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
#######################################################################

# Initialize defaults
workdir="/tmp/sysscandata/"
scan="false"
compare="false"
report="false"
getfiles="false"
sysfilesdiff="false"
exclude="false"
verbose="false"
exclstr=""
host=$(hostname -s)
hostname=$(hostname)
#######################################################################

# Functions
prtusage()
{
        cat<< EOT
syscompare.sh $Version
-v [verbose]
--help <this>
--version
--scan <abs path>
--scan /var/lib/tomcat
--scan /var/lib/tomcat --exclude "docs|examples"
--scan /var/lib/tomcat --exclude "docs|examples" --work /tmp/myscan
--list-scans
--list-scans --work <work dir>
--report [long report, default short report]
--compare <sysA> <epochA> <sysB> <epochB>
--compare dev01 1486556694 dev01 1486556798
--get-files <name> <file list>
--sys-files-diff <DIR1> <DIR2> <FOI-file>
EOT
exit 0
}
 
listscans()
{
        ls -lart $workdir
        exit 0
}
 
vprint ()
{
        if [ "$verbose" == "true" ] ; then
                echo $1
        fi
}
 
scanfunc ()
{
        scanpath="$1"
        cd $workdir # go to work dir
        scanpathname=$(echo "$scanpath" | sed 's/\//_/g')
        starttimestamp=$(date +%s)
 
        # setup file names for file and dir listings
        dirlist="$workdir$host$scanpathname"_"$starttimestamp.dirlist"
        permownlist="$workdir$host$scanpathname"_"$starttimestamp.allpermsownership"
        filelist="$workdir$host$scanpathname"_"$starttimestamp.filelist"
        shafilelist="$workdir$host$scanpathname"_"$starttimestamp.fileSHA256list"
 
        vprint "scanning ...."
 
        # get listings with find
        find $scanpath -type d > "$dirlist"
        find $scanpath -type f > "$filelist"
        find $scanpath -ls | awk '{print $3,$5,$6,$11}' > "$permownlist"
 
        vprint "'applying exclude filter :- $exclustr"
        # remove excludes from listings
        for file in $filelist $dirlist $permownlist ; do
                if [ -z "$exclustr" ]; then
                        cp $file $file.filtered
                else
                        cat $file | egrep -v $exclustr  > $file.filtered
                fi
        done
 
        # get file hashes for filtered file list
        vprint "calculating file hashes ...."
        while read line ; do
                sha256sum $line >> $shafilelist
        done < $filelist.filtered
 
        vprint "scan done"
 
        # add host label to listings to end of lines (otherwise this effects sort)
        sed -e "s/$/ $host"_"$starttimestamp/" $dirlist.filtered  > $dirlist"_"hostlabel
        sed -e "s/$/ $host"_"$starttimestamp/" $filelist.filtered  > $filelist"_"hostlabel
        sed -e "s/$/ $host"_"$starttimestamp/" $permownlist.filtered  > $permownlist"_"hostlabel
        sed -e "s/$/ $host"_"$starttimestamp/" $shafilelist  > $shafilelist"_"hostlabel
}
 
compfunc ()
{
        sysA="$1"
        sysAtime="$2"
        sysB="$3"
        sysBtime="$4"
        report=$sysA"@"$sysAtime"_vs_"$sysB"@"$sysBtime
        cd $workdir
 
        if [ "$rep" == "true" ] ; then
 
        vprint "long reports"
        # FIND DIFFS
        echo "Directory Structure diffs" > "$report.diffreport"
        diff ./$sysA*$sysAtime*dirlist.filtered ./$sysB*$sysBtime*dirlist.filtered >> "$report.diffreport"
        echo "File Name and SAHA256 Hash diffs" >> "$report.diffreport"
        diff ./$sysA*$sysAtime*fileSHA256list ./$sysB*$sysBtime*fileSHA256list >> "$report.diffreport"
        echo "Directory and File Permissions, Ownership and Names diffs" >> "$report.diffreport"
        diff ./$sysA*$sysAtime*allpermsownership.filtered ./$sysB*$sysBtime*allpermsownership.filtered >> "$report.diffreport"
 
        # FIND DIFFS VIA SORTING
        echo "Directory Structure sort then diffs" > "$report.sortreport"
        sort ./$sysA*$sysAtime*dirlist*hostlabel ./$sysB*$sysBtime*dirlist*hostlabel | awk '{print $2,$1}' | uniq -f1 -u >> "$report.sortreport"
        echo "File Name and SAHA256 sort then Hash diffs" >> "$report.sortreport"
        sort ./$sysA*$sysAtime*fileSHA256list*hostlabel ./$sysB*$sysBtime*fileSHA256list*hostlabel | awk '{print $3,$1,$2}' | uniq -f1 -u >> "$report.sortreport"
        echo "Directory and File Permissions, Ownership and Names sorted then diffs" >> "$report.sortreport"
        sort ./$sysA*$sysAtime*allpermsownership*hostlabel ./$sysB*$sysBtime*allpermsownership*hostlabel | awk '{print $5,$1,$2,$3,$4}' | uniq -f1 -u >> "$report.sortreport"
 
        else
 
        vprint "short reports"
        # SHORT REPORT TO GENERATE FILES OF INTEREST LIST
        sort ./$sysA*$sysAtime*fileSHA256list*hostlabel ./$sysB*$sysBtime*fileSHA256list*hostlabel | awk '{print $3,$1,$2}' | uniq -f1 -u >> "$report.shortsortreport"
        grep $sysA  "$report.shortsortreport" | awk '{ print $3 }' > "$sysA"_from_"$sysA"_vs_"$sysB"_FOI
        grep $sysB  "$report.shortsortreport" | awk '{ print $3 }' > "$sysB"_from_"$sysA"_vs_"$sysB"_FOI
 
        fi
}
 
tarfunc ()
{
        cd $workdir
        echo tar -cvz -f $1.tgz -T $2
        tar -cvz -f $1.tgz -T $2
}
 
difffunc ()
{
        dir1="$1"
        dir2="$2"
        FOI="$3"
        cd $workdir
        while read filename
        do
                vprint "diff "$dir1"/"$filename" "$dir2i"/"$filename" > "$filename"_diff"
                diff "$dir1"/"$filename" "$dir2"/"$filename" > "$filename"_diff
        done < $FOI
}
#######################################################################

# Main
 
shortopts="hw:vscgder:"
longopts="scan,work:,compare,report,help,version,get-files,sys-files-diff,exclude:,list-scans"
 
#OPTS=`getopt -o hw:vscgder: -l scan,work:,compare,help,version,get-files,sys-files-diff,exclude:,list-scans -- "$@"`
OPTS=`getopt -o $shortopts -l $longopts -- "$@"`
if [ $? != 0 ]
then
        exit 1
fi
 
eval set -- "$OPTS"
while true ; do
    case "$1" in
        -v) verbose="true" ; shift ;;
        --help|-h) prtusage ; shift ;;
        --version) echo $Version; exit 0 ;;
        --list-scans|-l) listscans ; shift ;;
        --work|-w) workdir="$2"; shift 2;;
        --exclude|-e) exclustr="$2"; shift 2;;
        --scan|-s)scan="true";  shift ;;
        --compare|-c) compare="true"; shift ;;
        --report|-r) rep="true"; shift ;;
        --get-files|-g)getfiles="true"; shift ;;
        --sys-files-diff|-d) sysfilesdiff="true"; shift ;;
        --) shift; break;;
    esac
done
 
# setup work dir
if [ ! -d "$workdir" ]; then
        mkdir $workdir
fi
 
if [ "$scan" == "true" ] ; then
        scanfunc $1
fi
 
if [ "$compare" == "true" ] ; then
        compfunc $1 $2 $3 $4
fi
 
if [ "$getfiles" == "true" ] ; then
        tarfunc $1 $2
fi
 
if [ "$sysfilesdiff" == "true" ] ; then
        difffunc $1 $2 $3
fi
 
exit 0
######################################################################