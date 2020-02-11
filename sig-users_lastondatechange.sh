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

USERPATH="/glftpd/ftp-data/users"

# newtime = Sat Feb 1 00:00:00 CET 2014 aka 1391209200 (seconds)
NEWTIME="1391209200"

MODUSERS=$(ls -l $USERPATH | awk '{print $(NF-0)}' | grep -v "default.user")

OIFS=$IFS
IFS='
'

# TIME 26960 1370748345 0 0

for MODUSER in $MODUSERS; do
	echo "updating user file $MODUSER with last online time of $NEWTIME"
	sed -e "s/^TIME \(.*\) .* \(.*\) \(.*\)/TIME \1 $NEWTIME \2 \3/" "$USERPATH/$MODUSER" > "$USERPATH/$MODUSER.time"
	mv -f "$USERPATH/$MODUSER.time" "$USERPATH/$MODUSER"
done
