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
commandname="REQFILLED"
targetdir="/site/REQUESTS"
log="/ftp-data/logs/glftpd.log"
requestfile="/ftp-data/misc/lrequests"
temp="/tmp"

umask 000
echo "[ XXX REQUEST FILLED ]"
reqfill="$(echo $@ | tr ' ' '_')"

if [ -z "$reqfill" ]; then
        if [ ! -s "$requestfile" ]; then
        echo "NO current requests!"
        else
        echo "Current requests..."
		cat "$requestfile"
        fi
        echo "Usage: SITE $commandname <title>"
        exit 0
else
        if [ -d "$targetdir/$reqfill" ]; then
            echo "Marking request as filled..."
            RUSER=`grep "$reqfill" "$requestfile" | awk '{print $1}'`
            grep -v "$reqfill" "$requestfile" >> /tmp/lrequests.tmp
            cp -f /tmp/lrequests.tmp "$requestfile"
            mv "$targetdir/$reqfill" "$targetdir/FILLED-$reqfill"
            touch "$targetdir/FILLED-$reqfill"
            rm -f /tmp/lrequests.tmp
			echo `date "+%a %b %d %T %Y"` REQFILLED: \"$reqfill\" \"$USER\" \"$RUSER\" >> $log
        else
            echo "ERROR: That request does not exist!"
        fi
        exit 0
fi
