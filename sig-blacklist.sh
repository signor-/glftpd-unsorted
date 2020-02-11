#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
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

blacklists="
/ftp-data/iplogs/blacklist-ip
/ftp-data/iplogs/blacklist-netname
"

OIFS="$IFS"
IFS=$'\n'

echo ".          BLACKLISTED IP'S AND NETWORKS           ."
echo " "

for list in $blacklists; do

if [ -f $list ]; then

	clist=`cat $list`
	what=`basename $list | tr [a-z] [A-Z]`

[ "$what" == "BLACKLIST-IP" ] && what="IP BLACKLIST"
[ "$what" == "BLACKLIST-NETNAME" ] && what="NETWORK BLACKLIST"


	if [ "$clist" = "" ]; then
echo ".--------------------------------------------------'"
echo "       $what CONTAINS NO CURRENT ENTRIES!"
	fi


	if [ "$clist" != "" ]; then

		echo " "
		echo ".--------------------------------------------------'"
		echo " $what CONTAINS THE FOLLOWING ENTRIES.."
                echo " "
		for line in $clist; do

			ipnet=`echo $line | awk '{print $1}'`
			reason=`echo $line | awk -v nr=2 '{ for (x=nr; x<=NF; x++) { printf $x " "; }; print " " }'`
            echo " + $ipnet -> $reason"
		done

	fi

fi

done

echo ".--------------------------------------------------'"

IFS="$OIFS"
