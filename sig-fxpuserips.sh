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

#run in chroot, dont need /glftpd
iplogdir="/ftp-data/iplogs/whois"
usersdir="/ftp-data/users"

if [ "$1" == "" ]; then
        echo "Please provide a username"
        exit 0
fi

if [ ! -f $usersdir/$1 ]; then
	echo "USER FILE FOR $1 DOESNT EXIST, TRYING TO SEARCH ANYWAY..."
        # echo ".--------------------------------------------------."
        # echo " USER $1 IS INVALID"
        # echo ".--------------------------------------------------."
        # exit 0
else
	echo "USER FILE FOR $1 FOUND, SEARCHING..."
fi


userlist=`ls -la $iplogdir | awk '{print $9}' | grep "\-users"`

echo ".--------------------------------------------------."
echo " USER $1 HAS USED THE FOLLOWING IP ADDRESSES..."
echo " "

count=0

for file in $userlist; do

        finduser=`cat $iplogdir/$file | grep "$1"`

        if [ "$finduser" != "" ]; then

        ip=`echo $file | sed "s/-users//"`
        inetnum=`cat $iplogdir/$ip-whois | grep "inetnum\:" | awk '{print $2" to "$4}'`
        netname=`cat $iplogdir/$ip-whois | grep "netname\:" | awk '{print $2}' | tr -d '[:space:]'`
        country=`cat $iplogdir/$ip-whois | grep "country\:" | head -1 | awk '{print $2}' | tr -d '[:space:]' | tr [a-z] [A-Z]`

        [ "$inetnum" = "" ] && inetnum="0.0.0.0 to 0.0.0.0"
        [ "$netname" = "" ] && netname="UNKNOWN"
        [ "$country" = "" ] && country="XX"
                
        echo " + $country -> $ip - $netname ($inetnum)"

        count=$(($count + 1))

        fi


done

echo " "
echo " + $count TOTAL FXP IP ENTRIES!"
echo ".--------------------------------------------------."
