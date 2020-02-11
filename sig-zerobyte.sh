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

RELPATH=$(basename $PWD)
DIRNUMBER="5"
RELDIRPWD=$(echo $PWD | sed 's/\//\n/g' | wc -l)

#PWD = /site/MP3/<DATE>/<REL>
#PWD = /site/FLAC/<DATE>/<REL>
#PWD = /site/MVID/<WEEK DATE>/<REL>
# 00-motionless_in_white-infamous-2012.sfv
# 12-motionless_in_white-infamous.mp3-missing
# 11-motionless_in_white-underdog.mp3-missing

PREDIR=$(echo $PWD | grep "_PRE")
#[ -n $PREDIR ] && echo "Error, not inside a release directory, exiting!"; exit 0;
[ -n $PREDIR ] && DIRNUMBER="6" || DIRNUMBER="5";

[ "$RELDIRPWD" = "$DIRNUMBER" ] && {
		echo "Searching for zero byte files in $RELPATH"
		ZEROBYTELIST=$(find $PWD -maxdepth 1 -type f -size 0 | egrep -iv "\-missing$")
        [ -z $ZEROBYTELIST ] && { 
                echo "Found no zero byte files. (*-missing files are exempt)" 
                exit 0 
        } || { 
                for ZEROBYTE in $ZEROBYTELIST; do
                        FILENAME=$(basename $ZEROBYTE)
                        echo "Deleted zero byte file -> $FILENAME"           
                        rm -f "$ZEROBYTE"
                done
        }
} || {
        echo "Error, not inside a release directory, exiting!"
        exit 0
}
exit 0
