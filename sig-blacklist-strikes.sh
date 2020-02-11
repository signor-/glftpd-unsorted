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

# run in chroot/site command.
USERDIR="/ftp-data/users"
BLDIR="/ftp-data/iplogs"

BLUSERS=$(cat $BLDIR/blacklist-strikes | sort | uniq)

for BLUSER in $BLUSERS; do
	BLSTRIKES=$(cat $BLDIR/blacklist-strikes | sort | grep "$BLUSER" | wc -l)
	if [ -f "$USERDIR/$BLUSER" ]; then
		if [ $BLSTRIKES -gt 3 ]; then
			echo "[BLACKLIST] STRIKE $BLSTRIKES/3 - $BLUSER [INSTANT PURGE!]"
		else
			if [ $BLSTRIKES == 3 ]; then
				echo "[BLACKLIST] STRIKE $BLSTRIKES/3 - $BLUSER [STRUCK OUT!]"
			else
				echo "[BLACKLIST] STRIKE $BLSTRIKES/3 - $BLUSER [STRIKE $BLSTRIKES!]"
			fi
		fi
	else
		echo "[BLACKLIST] STRIKE $BLSTRIKES/3 - $BLUSER [ALREADY PURGED!]"
	fi
done
