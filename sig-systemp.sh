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

# DISKS are shown from 'fdisk -l' disk labels. These do not have to be grouped together, but help order if they are.
# fdiskid#sectionlabel

#XXX

DISKS="
0x0#glftpd
0x0#mvid
0x0#mp3
0x0#flac
0x0#md0
0x0#md0
0x0#md0
0x0#md0
0x0#md0
0x0#md0
0x0#md1
0x0#md1
0x0#md1
0x0#md1
0x0#md1
"

###############################################################################

OIFS=$IFS
IFS='
'

FDISK=$(/sbin/fdisk -l 2> /dev/null | tr "\n" " " | sed 's/Disk \/dev/\nDisk \/dev/g' | tr -s " ")

for DISK in $DISKS; do
	DISKID=$(echo $DISK | awk -F# '{print $1}')
	DISKMOUNT=$(echo $DISK | awk -F# '{print $2}' | tr '[:lower:]' '[:upper:]' )
	DISKFDISK=$(echo "$FDISK" | grep "$DISKID")
	DISKDEVICE=$(echo $DISKFDISK | awk '{print $2}' | tr -d ":")
	DISKTEMP=$(/usr/sbin/hddtemp -n $DISKDEVICE 2> /dev/null)
	if [ -z "$DISKTEMP" ]; then
		DISKTEMP="00"
	fi
	if [ -z "$DISKLINE" ]; then
		DISKLINE=$(echo "[$DISKMOUNT] $DISKTEMP")
	else
		DISKFIND=$(echo "$DISKLINE" | grep "$DISKMOUNT")
		if [ -z "$DISKFIND" ]; then
			DISKLINE=$(echo "$DISKLINE [$DISKMOUNT] $DISKTEMP")
		else
			DISKLINE=$(echo "$DISKLINE" | sed -e "s/\[$DISKMOUNT\]/\[$DISKMOUNT\] $DISKTEMP/")
		fi
	fi
done

###############################################################################

CPUS=$(/usr/bin/sensors -u | grep -e "temp[1-2]_input" | sed 's/[^A-Za-z0-9. ]//g' | tr -s ' ')

for CPU in $CPUS; do
	CORE=$(echo $CPU | awk '{print $1}')
	TEMP=$(echo $CPU | awk '{print $2}' | sed 's/[^0-9.]//g' | sed -e 's/\.[0-9]\{1,2\}//')
	if [ -z "$CPULINE" ]; then
		CPULINE=$(echo "[CPU] $TEMP")
	else
		CPULINE=$(echo "$CPULINE $TEMP")
	fi
done

echo "[SYSTEMP] -> $CPULINE $DISKLINE (Celcius)"
echo "`/bin/date "+%a %b %d %T %Y"` \"SYSTEMP\" \"$CPULINE $DISKLINE\"" >> $SYSLOG
