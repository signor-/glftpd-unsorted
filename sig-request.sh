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

commandname="REQUEST"
targetdir="/site/REQUESTS"
log="/ftp-data/logs/glftpd.log"
requestfile="/ftp-data/misc/lrequests"
maxreqs="5"

umask 000
echo "[ XXX REQUESTS ]"
request="$(echo $@ | tr ' ' '_')"
if [ -z "$request" ]; then
        if [ ! -s "$requestfile" ]; then
            echo "NO current requests!"
        else
        echo "Current requests..."
        cat "$requestfile"
        fi
        echo "Usage: SITE $commandname <title>"
        exit 0
else
	usrnum=$(cat $requestfile | grep "$USER" | wc -l)
	if [ $usrnum -ge $maxreqs ]; then
		echo "ERROR: You currently have $usrnum requests, which is the maximum requests per user at any one time."
		exit 0
	fi
        echo "Processing your request..."
        if [ ! -d "$targetdir/$request" ]; then
            echo "request of $request added."
            echo "$USER -> $request [ `date "+%Y-%m-%d"` ]" >> $requestfile
            echo `date "+%a %b %d %T %Y"` REQUEST: \"$request\" \"$USER\" >> $log
            mkdir -m777 "$targetdir/$request"
        else
            echo "ERROR: That request already exists!"
        fi
        exit 0
fi

