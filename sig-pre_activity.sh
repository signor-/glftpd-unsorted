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

#########################################################################
# this goes in glftpd.conf ABOVE all the pzs-ng entries!
# cscript         MKD                     post     /bin/sig-pre_activity.sh
# cscript         RMD                     post     /bin/sig-pre_activity.sh      
#########################################################################
# pre dir syntax
PREDIR="_PRE"

# pre dir number (/site/MVID/_PRE/GROUP/<pick this number> = 5)
PREDIRNUM="5"

# glftpd log file
GLLOGFILE="/ftp-data/logs/glftpd.log"

#########################################################################

DATE="$(date "+%a %b %d %H:%M:%S %Y")"

# this script will only execute if the MKD or RMD is successful!

COUNTDIR=$(echo "$PWD" | sed 's/\//\n/g' | wc -l)
COUNTMKD=$(echo "$1" | sed 's/\//\n/g' | wc -l)

if [ "$COUNTDIR" == "$PREDIRNUM" ] || [ "$COUNTMKD" == "$PREDIRNUM" ]; then
	
	GRPDIR=$(echo $PWD | grep "$PREDIR" | cut -d/ -f5); # should have groupdir name inside if found!
	GRPMKD=$(echo $1 | grep "$PREDIR" | cut -d/ -f4); # should have groupdir name inside if found!

	if [ ! -z "$GRPDIR" ]; then
		PREGROUP="$GRPDIR"
		PRESEC=$(echo $PWD | grep "$PREDIR" | sed 's/.*\/\(.*\)\/'"$PREDIR"'\/.*/\1/')
	else
		PREGROUP="$GRPMKD"
		PRESEC=$(echo $1 | grep "$PREDIR" | sed 's/.*\/\(.*\)\/'"$PREDIR"'\/.*/\1/')
	fi
	
	COMMAND=$(echo $1 | awk '{print $1}'); # should have either MKD or RMD command
	RELNAME=$(echo $1 | awk '{print $2}' | awk -F/ '{print $(NF-0)}'); # should have the directory/release name if found!;

	if [ ! -z "$GRPDIR" ] || [ ! -z "$GRPMKD" ]; then

		if [ "$COMMAND" = "MKD" ]; then
			echo "$DATE PREACTIVITY: \"$USER\" \"$GROUP\" \"$PRESEC PRE\" \"$PREGROUP\" \"\0033MKD\003 $RELNAME\" \"$2\" \"$3\"" >> $GLLOGFILE
		fi                 

		if [ "$COMMAND" = "RMD" ]; then
			echo "$DATE PREACTIVITY: \"$USER\" \"$GROUP\" \"$PRESEC PRE\" \"$PREGROUP\" \"\0034RMD\003 $RELNAME\" \"$2\" \"$3\"" >> $GLLOGFILE     
		fi

	fi

fi
