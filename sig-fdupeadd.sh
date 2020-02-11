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

# $1 = Name of file.
# $2 = Actual path the file is stored in
# $3 = CRC number
# $PWD = Current Path.
# $USER = Username of uploader

# EXIT codes..
# 0 - Good: 
# 2 - Bad:

# check if we are in a predir */_PRE/* etc
dirstonotadd="
_PRE
REQUESTS
PRIVATE
"

SHOWHEADER=0

###############################################################################

BWID="50" #width of banner not including "|" and "|" for borders
FNUM="${#1}" #number of characters in current filename

if [ "$FNUM" -lt "$BWID" ]; then
	FCAL=$(( $BWID - $FNUM ))
	BFIL=$(echo "$1" | sed -e :a -e 's/^.\{1,49\}$/ & /;ta')
	BFIL=${BFIL:0:50}
else
	FCAL=$(( $FNUM - $BWID ))
	FEXT="${1##*.}" # ext
	ECAL="${#FEXT}" # length of ext
	BLEN=$(( $FNUM - ( $FCAL + $ECAL + 7 ) )) # 7 = 5 dots + 2 spaces
	BFIL="${1:0:($BLEN)}" # trims filename
	BFIL=$(echo " ${BFIL}.....${FEXT} " )
	BFIL=${BFIL:0:50}
fi

if [ "$SHOWHEADER" = "1" ]; then
	echo -e ".--------------------------------------------------."
	echo -e "|     _______ ______  _     _  _____  _______      |"
	echo -e "|     |______ |     \ |     | |_____] |______      |"
	echo -e "|     |       |_____/ |_____| |       |______      |"
	echo -e "|                                                  |"
fi
###############################################################################

for doweaddfile in $dirstonotadd; do
	predir=`expr "$PWD" : '.*\/$doweaddfile\/*'`
	if [ $predir != "0" ]; then
		if [ "$SHOWHEADER" != "1" ]; then
			echo -e ".--------------------------------------------------."
		fi
		echo -e "|       FDUPE FILE DATABASE UPDATE - SKIPPED       |"
		echo -e "|                                                  |"
		echo -e "|$BFIL|"
		echo -e "\`--------------------------------------------------'"
		exit 0
	fi
done

###############################################################################

case "$1" in  
	*.mp3)
		/bin/dupeaddchroot -r /etc/bogus.conf "$1" "$USER" > /dev/null 2>&1
		if [ "$SHOWHEADER" != "1" ]; then
			echo -e ".--------------------------------------------------."
		fi
		echo -e "|      FDUPE FILE DATABASE UPDATE - MP3 ADDED      |"
		echo -e "|                                                  |"
		echo -e "|$BFIL|"
		echo -e "\`--------------------------------------------------'"
		exit 0
        ;;

	*.flac)
		/bin/dupeaddchroot -r /etc/bogus.conf "$1" "$USER" > /dev/null 2>&1
		if [ "$SHOWHEADER" != "1" ]; then
			echo -e ".--------------------------------------------------."
		fi
		echo -e "|     FDUPE FILE DATABASE UPDATE - FLAC ADDED      |"
		echo -e "|                                                  |"
		echo -e "|$BFIL|"
		echo -e "\`--------------------------------------------------'"
		exit 0
        ;;

	*)
		if [ "$SHOWHEADER" != "1" ]; then
			echo -e ".--------------------------------------------------."
		fi
		echo -e "|       FDUPE FILE DATABASE UPDATE - SKIPPED       |"
		echo -e "|                                                  |"
		echo -e "|$BFIL|"
		echo -e "\`--------------------------------------------------'"
		exit 0
        ;;
esac
