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
# 10:25 PM Monday, 1 July 2013

SYSLOG="/glftpd/ftp-data/logs/system.log"

MDADM=$(/bin/cat /proc/mdstat | grep -E "^[Mm][Dd][0-9]{1,3}" | sed -e 's/^\([Mm][Dd].*\) :.*/\1/g' | sort)

OIFS=$IFS
IFS='
'

NOWTIME=$(/bin/date "+%a %b %_d %H:%M:%S %Y" | tr -s " ")

for MD in $MDADM; do
	INFO=$(/sbin/mdadm -D "/dev/$MD" 2> /dev/null | tr -s " " | grep " : " | sed -e 's/^ //g')
	for LINE in $INFO; do
		LINE=$(echo $LINE | grep ":")
		KEY=$(echo $LINE | cut -d ':' -f 1 | tr -cd 'a-zA-Z0-9\#')
		STRING=$(echo $LINE | cut -d ':' -f 2- | tr -cd 'a-zA-Z0-9\ \#\.\,\/\:\=\@' | tr -s ' ' | sed -e 's/^ //')
		case $KEY in
			Version) VERSION=$(echo $STRING) ;;
			CreationTime) CTIME=$(echo $STRING | tr -s " ") ;;
			RaidLevel) RLEV=$(echo $STRING | tr '[:lower:]' '[:upper:]') ;;
			ArraySize) ARSIZE=$(echo $STRING | awk -F"GB" '{print $1}' | awk '{print $(NF-0)}') ;;
			UsedDevSize) UDSIZE=$(echo $STRING | awk -F"GB" '{print $1}' | awk '{print $(NF-0)}') ;;
			RaidDevices) RDEV=$(echo $STRING) ;;
			TotalDevices) TDEV=$(echo $STRING) ;;
			UpdateTime) UPTIME=$(echo $STRING | tr -s " ") ;;
			State) STATE=$(echo $STRING | tr '[:lower:]' '[:upper:]') ;;
			ActiveDevices) ADEV=$(echo $STRING) ;;
			WorkingDevices) WDEV=$(echo $STRING) ;;
			FailedDevices) FDEV=$(echo $STRING) ;;
			SpareDevices) SDEV=$(echo $STRING) ;;
			ChunkSize) CHUNK=$(echo $STRING) ;;
		esac
	done
	MD=$(echo $MD | tr '[:lower:]' '[:upper:]')
	echo "[MDADM] $MD ($STATE) V.${VERSION} $RLEV ARRAY [ ${ARSIZE}GB / ${UDSIZE}GB ] [ ${ADEV}A | ${WDEV}W | ${FDEV}F | ${SDEV}S ] $CHUNK ($UPTIME/$NOWTIME)"
	echo "`/bin/date "+%a %b %d %T %Y"` \"MDADM\" \"$MD\" \"$STATE\" \"$VERSION\" \"$RLEV\" \"$ARSIZE\" \"$UDSIZE\" \"$ADEV\" \"$WDEV\" \"$FDEV\" \"$SDEV\" \"$CHUNK\" \"$UPTIME\" \"$NOWTIME\"" >> $SYSLOG
done
