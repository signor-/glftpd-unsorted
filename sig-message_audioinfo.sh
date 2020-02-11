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

# archive complete dir and .message deleter
# show_diz        .audioinfo      *

# use regex!
complete_dir=".*\/\[XXX\].COMPLETE.(.*)"
message_file=".*\/.message"

function find_complete_dirs () {
	for found_dir in $complete_dir; do
		echo "searching pattern \"$found_dir\" inside path \"$1\""
                find "$1" -regextype posix-egrep -regex "$complete_dir" | while read LINE
		do

			releasedir=`dirname "$LINE"`
			fullreleasedir=`echo "$releasedir"`
			releasedir=`basename "$releasedir"`;
			completedir=`basename "$LINE"`
			newcompletedir=`echo $completedir | sed 's/\[.*\] COMPLETE (\(.*\))/[AUDiOiNFO] COMPLETE \(\1\)/'`
			echo "------------------------------------ - - -"
			echo "created -> $releasedir/$newcompletedir"
			echo "deleted -> $releasedir/$completedir"
			# if directory exists (which it should), delete it!
			[ -d "$fullreleasedir/$completedir" ] && rmdir "$fullreleasedir/$completedir"
			# if new complete directory doesn't exist, make it!
			[ -d "$fullreleasedir/$newcompletedir" ] || mkdir -m644 "$fullreleasedir/$newcompletedir"

		done
	done
	
}

function find_message_files () {
	OIFS="$IFS"
	IFS=$(echo -e "\r")
	for found_msg in $message_file; do
	echo "searching pattern $found_msg"
		find "$1" -regextype posix-egrep -regex "$message_file" | while read LINE
		do
		message=`cat $LINE | tr -d "\|" | tr -s " " | sed 's/^\(.* \: .*\) \(.* \: .*\)/\1\n\2/g' | sed 's/ NA / N\/A /g'`
        
		releasedir=`dirname $LINE`
		messagefile=`echo "$releasedir/.message"`
		messageback=`echo "$releasedir/.bakmessage"`
		releasedir=`basename $releasedir`;
	        audioinfo=`dirname $LINE | awk '{print $1"/.audioinfo"}'`

		# if .message file exists, rename it to .bakmessage so it wont display when entering dir, but we still have the info.
		[ -f $messagefile ] && mv -f $messagefile $messageback
		
		release=`echo $releasedir | sed -r 's/(^.{68}).*/\1/'`
		artist=`echo $message | grep -Ei ".*artist.*\:" | awk -F: '{print $2}' | sed 's/^ *//g' | sed 's/ *$//g'`
		album=`echo $message | grep -Ei ".*album.*\:" | awk -F: '{print $2}' | sed 's/^ *//g' | sed 's/ *$//g'`
		genre=`echo $message | grep -Ei ".*genre.*\:" | awk -F: '{print $2}' | sed 's/^ *//g' | sed 's/ *$//g'`
		tracks=`echo $message | grep -Ei ".*tracks.*\:" | awk -F: '{print $2}' | sed 's/^ *//g' | sed 's/ *$//g'`
		encoder=`echo $message | grep -Ei ".*encoder.*\:" | awk -F: '{print $2}' | sed 's/^ *//g' | sed 's/ *$//g' | sed s'/ Preset//'`
		rate=`echo $message | grep -Ei ".*rate.*\:" | awk -F: '{print $2}' | sed 's/^ *//g' | sed 's/ *$//g'`
		year=`echo $message | grep -Ei ".*year.*\:" | awk -F: '{print $2}' | sed 's/^ *//g' | sed 's/ *$//g'`
		preset=`echo $message | grep -Ei ".*preset.*\:" | awk -F: '{print $(NF-0)}' | sed 's/^ *//g' | sed 's/ *$//g'`

		[ "$encoder" = "Preset" ] && encoder="N/A";
		[ "$preset" = "" ] && preset="N/A";
		[ "$tracks" = "1" ] && trackdesc="Track" || trackdesc="Tracks";

		[ `echo $releasedir | grep -Ei "[-]FLAC[-]"` ] && encoder="FLAC";

		#release
		line0=$(echo "$release" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
		line0=$(echo "$line0" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
		#artist
		line1=$(echo "$artist" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
		line1=$(echo "$line1" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
		#album
		line2=$(echo "$album" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
		line2=$(echo "$line2" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
		#tracks genre year
		line3=$(echo "$tracks $trackdesc Of $genre From $year At $rate" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
		line3=$(echo "$line3" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
		# encoder preset
		line4=$(echo "Encoded With $encoder Using Preset $preset" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
		line4=$(echo "$line4" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')

		echo "moved .message -> $releasedir/.bakmessage"
		echo "created .audioinfo -> $releasedir/.audioinfo"

		echo "   .                        ._____   ____                   .         " > "$audioinfo"
		echo "    \_______.  ___.____     |    /  /__./_______            |         " >> "$audioinfo"
		echo "   ._\____  |./   |   /. ___|_  /  ___./  __   /.   . -  -  +- - ----+" >> "$audioinfo"
		echo "   |   _.    .    |    |/  __/  \./  /|   \|    |           |      . |" >> "$audioinfo"
		echo "   |_  \|    |    |    .   \|    .   .|    _____|__ ______________/  |" >> "$audioinfo"
		echo "    /________|    .    |_________|__  |__./       /.  __/_____   /.  |" >> "$audioinfo"
		echo "   /         |_________|            ./  /|    .    |   ____/\|    |  |" >> "$audioinfo"
		echo "+-/ -- - -   -  -    --+-- -  -   - .    .    |    .    \    |    |  |" >> "$audioinfo"
		echo "|. - A U D i O         |            |____|\___|    |\____\________|  |" >> "$audioinfo"
		echo "|          i N F O -  .|                      |    |              |  |" >> "$audioinfo"
		echo "| -  -  --  ---   --- -+- -[ A R T i S T ]----\____|   ---  --  - +- |" >> "$audioinfo"
		echo "|                      .                                          .  |" >> "$audioinfo"
		echo "|$line1|" >> "$audioinfo"
		echo "|                                                                    |" >> "$audioinfo"
		echo "| -  -  --  ---   --- ------[ A L B U M ]------- ---   ---  --  -  - |" >> "$audioinfo"
		echo "|                                                                    |" >> "$audioinfo"
		echo "|$line2|" >> "$audioinfo"
		echo "|                                                                    |" >> "$audioinfo"
		echo "| -  -  --  ---   --- -------[ i N F O ]-------- ---   ---  --  -  - |" >> "$audioinfo"
		echo "|                                                                    |" >> "$audioinfo"
		echo "|$line3|" >> "$audioinfo"
		echo "|                                                                    |" >> "$audioinfo"
		echo "| -  -  --  ---   --- ----[ E N C O D E R ]----- ---   ---  --  -  - |" >> "$audioinfo"
		echo "|                                                                    |" >> "$audioinfo"
		echo "|$line4|" >> "$audioinfo"
		echo "|                                                                    |" >> "$audioinfo"
		echo "|             .                          . -   - -  ---+             |" >> "$audioinfo"
		echo "|            -+----------------------------------------|- sigscript -+" >> "$audioinfo"
		echo "+-- --    .   |                                        +-- --    .   |" >> "$audioinfo"
		echo "              .                                                      ." >> "$audioinfo"
		
		done
	done
	
}

find_complete_dirs "/glftpd/site/ARCHIVE/MP3"
find_message_files "/glftpd/site/ARCHIVE/MP3"

find_complete_dirs "/glftpd/site/ARCHIVE/FLAC"
find_message_files "/glftpd/site/ARCHIVE/FLAC"
