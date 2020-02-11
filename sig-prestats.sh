#!/bin/sh
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

# to get info from
glftpd_conf="/etc/glftpd.conf"

if [ "$1" = "sitecmd" ]; then
	prelog_file="/ftp-data/logs/pre.log"
else
	prelog_file="/glftpd/ftp-data/logs/pre.log"
	prelog_statsdir="/glftpd/site/STATS/`date +%Y-%B`"
fi

prelog_statsfile="`date +%Y-%B`_Pre_Stats.txt"

year=`date +%Y`
mnth=`date +%b`

# check if dir exists, if not, make it!
[ ! -d $prelog_statsdir ] && mkdir -m777 $prelog_statsdir

privpaths=`cat $glftpd_conf | grep privpath | grep "=STAFFPRE" | awk '{print $2}'`

predirs=""
for path in $privpaths; do
        predirs="$predirs `basename $path`"
done

sorted_groups=$(echo $predirs | sort -u)

if [ "$1" = "sitecmd" ]; then
        echo " XXX PRE STATS FOR `date "+%B %Y"` UP UNTIL `date "+%Y-%m-%d %H:%M:%S"` BOX TIME"
        echo " "
else
	echo " XXX PRE STATS FOR `date "+%B %Y"`" >>  $prelog_statsdir/$prelog_statsfile
	echo " " >>  $prelog_statsdir/$prelog_statsfile
fi

sorted_groups=$(echo $predirs | sed 's/ /\n/g' | sort -u)

for pregrp in $sorted_groups; do

	numpres=0; numsize=0; numfiles=0; presize=0; prefiles=0

	OIFS="$IFS"
	IFS='
	'

	grppres=`cat $prelog_file | grep "$year " | grep "$mnth " | grep "$pregrp"`

	if [ "$grppres" != "" ]; then
		
		for grppre in $grppres; do
			numpres=$(($numpres + 1))
			presize=`echo $grppre | awk '{print $(NF-0)}' | tr -d "\""`
			prefiles=`echo $grppre | awk '{print $(NF-1)}' | tr -d "\""`
			numsize=`echo "$numsize + $presize" | bc`
			numfiles=`echo "$numfiles + $prefiles" | bc`
		done
		
		if [ "$numpres" = "1" ]; then
			if [ "$1" = "sitecmd" ]; then
				echo "$pregrp -> $numpres pre - total of $numsize MB in $numfiles F"         
			else
				echo "$pregrp -> $numpres pre - total of $numsize MB in $numfiles F" >> $prelog_statsdir/$prelog_statsfile
			fi
		else
                        if [ "$1" = "sitecmd" ]; then
				echo "$pregrp -> $numpres pres - total of $numsize MB in $numfiles F"         
			else
				echo "$pregrp -> $numpres pres - total of $numsize MB in $numfiles F" >> $prelog_statsdir/$prelog_statsfile
			fi
		fi
	else
                if [ "$1" = "sitecmd" ]; then
			echo "$pregrp -> group has no pres this month!"
		else
			echo "$pregrp -> group has no pres this month!" >> $prelog_statsdir/$prelog_statsfile
		fi
	fi

done
