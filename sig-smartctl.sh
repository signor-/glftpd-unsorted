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

LOG="/glftpd/ftp-data/logs/system.log"

HDDS="
/dev/sdl#GLFTPD
/dev/sda#MP3
/dev/sdj#FLAC
/dev/sdb#MVID
/dev/sdc#MD0
/dev/sdd#MD0
/dev/sde#MD0
/dev/sdf#MD0
/dev/sdg#MD0
/dev/sdh#MD0
/dev/sdi#MD1
/dev/sdk#MD1
/dev/sdm#MD1
/dev/sdn#MD1
/dev/sdo#MD1
"

for HDD in $HDDS; do
	HDEV=$(echo $HDD | awk -F# '{print $1}')
	HSEC=$(echo $HDD | awk -F# '{print $2}')
	HTES=$(smartctl -H $HDEV | grep "^SMART" | awk '{print $(NF-0)}')
	if [ "$HTES" = "PASSED" ]; then
		# echo "[PASSED] $HDEV ($HSEC)"
		echo `date "+%a %b %d %T %Y"` SYSTEMCTL: \"PASSED\" \"$HDEV\" \"$HSEC\" #>> $LOG
	else
		HREAS=$(smartctl -H $HDEV | sed -e 's/^[ \t]*//' | egrep '^[[:digit:]]{1,3}' | tr -s " ")
		# echo "[FAILED] $HDEV ($HSEC)"
		for HREA in "$HREAS"; do
			# 171 Unknown_Attribute 0x0032 000 000 000 Old_age Always FAILING_NOW 0
			# 172 Unknown_Attribute 0x0032 000 000 000 Old_age Always FAILING_NOW 0
			HNUM=$(echo $HREA | awk '{print $1}')
			HATT=$(echo $HREA | awk '{print $2}')
			HFLA=$(echo $HREA | awk '{print $3}')
			HVAL=$(echo $HREA | awk '{print $4}')
			HWOR=$(echo $HREA | awk '{print $5}')
			HTHR=$(echo $HREA | awk '{print $6}')
			HTYP=$(echo $HREA | awk '{print $7}')
			HWHE=$(echo $HREA | awk '{print $9}')
			HRAW=$(echo $HREA | awk '{print $10}')
			if [ "$HWHE" = "FAILING_NOW" ]; then
				# echo "[FAILED] $HDEV ($HSEC) -> ($HNUM) $HATT - $HFLA $HVAL/$HWOR/$HTHR - FAILING... BACK UP DATA!"
				echo `date "+%a %b %d %T %Y"` SYSTEMCTL: \"FAILED\" \"$HDEV\" \"$HSEC\" #>> $LOG
			fi
		done
	fi
done
