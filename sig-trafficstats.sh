#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# at your option any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################
# this script checks yesterdays traffic (after midnight) and logs it! hence the use of 'yesterday' in date.

# where to put the info obtained
prelog_statsdir="/glftpd/site/STATS/`date +%Y-%B -d 'yesterday'`"
prelog_statsfile="`date +%Y-%B -d 'yesterday'`_Traffic_Stats.txt"

vndate=`date +%m/%d/%y -d 'yesterday'`

today=$(date +%d)
lastday=$(cal -h | awk -v nr=1 '{ for (x=nr; x<=NF; x++) { printf $x " "; }; print " " }' | tr -s '[:blank:]' '\n' | tail -1)

yesterday=`vnstat -d | grep $vndate | awk -F" " '{print $1" - "$2" "$3" RX - "$5" "$6" TX - "$8" "$9" TOTAL - "$11" "$12" AVG"}'`

# checks if dir exists, if not, create it!
if [ ! -d $prelog_statsdir ]; then
	mkdir -m777 $prelog_statsdir
fi

# check if file exists, if not, create it!
if [ ! -f $prelog_statsdir/$prelog_statsfile ]; then
	touch $prelog_statsdir/$prelog_statsfile
	chmod 666 $prelog_statsdir/$prelog_statsfile
fi

echo " $yesterday" >> $prelog_statsdir/$prelog_statsfile

if [ "$today" == "$lastday" ]; then
	eomdate=`date "+%m/"XX"/%y" -d 'yesterday'`
	shortmonth=`date +%b -d 'yesterday'`
	lastmonth=`vnstat -m | grep $shortmonth | awk -F" " '{print $3" "$4" RX - "$6" "$7" TX - "$9" "$10" TOTAL - "$12" "$13" AVG"}'`
	echo "---------------------------------------------------------------------------"
	echo "                         EOM TRAFFIC STAT TOTALS"
	echo " $eomdate - $lastmonth" >> $prelog_statsdir/$prelog_statsfile
	echo "---------------------------------------------------------------------------"
fi
	

