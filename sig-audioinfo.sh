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
# archive complete dir and .message deleter
# show_diz        .audioinfo      *
###############################################################################
# where is mediainfo located?
mediainfo=$(which mediainfo)
# use regex! multiple regex dirs allowed, space seperated
complete_dir=".*\/\[XXX\].COMPLETE.(.*)"
# replace the complete dir with a generic version?
replace_dir=yes
# delete message file? (it holds race data from pzs-ng)
delete_message=yes
###############################################################################
# check the bottom of script for other variables!
###############################################################################
function do_audio_info () {
	for found_dir in $complete_dir; do
		echo "[+] searching for pattern \"$found_dir\" inside path \"$1\" to create .audioinfo"
                find "$1" -regextype posix-egrep -regex "$complete_dir" | while read LINE
		do
			releaseful=$(dirname "$LINE") # contains full path, not including the complete directory
			releasedir=$(basename "$releaseful") # contains the release directory name only
			releaselst=$(ls "$releaseful") # contains the file contents of the release directory
			releasenum=$(echo "$releaselst" | grep -Ei "\.mp3|\.flac" | wc -l) # contains # of audio files
			releasedet=$(echo "$releaselst" | grep -Ei "\.mp3|\.flac" | tail -1) # contains 1 audio file, for use with mediainfo
			releaseext=${releasedet##*.} # contains the extention of the audio file
			completdir=$(basename "$LINE") # contains the [complete] dir that was found
			audioinfo=$(echo "${releaseful}/.audioinfo")
			
			[ "$releasenum" = "1" ] && releasedes="Track" || releasedes="Tracks";
			
			# calculate release size
			calclist=$(stat -c"%n#%s" $releaseful/*.$releaseext)
			releasesiz=0
			for calcfile in $calclist; do
				filesize=`echo $calcfile | awk -F# '{print $2}'`
				releasesiz=$(( $releasesiz + $filesize ))
			done
			
			if [ $releasesiz != 0 ]; then
				releasesiz=`echo "$releasesiz/1048576" | bc -l`
				releasesiz=`printf "%.2f" $releasesiz`
			else
				releasesiz=0
			fi

			# obtaining audio information from file via mediainfo
			$mediainfo "$releaseful/$releasedet" >/tmp/audioinfo.tmp 2>/dev/null
			while read line; do

				key=$(echo "$line" | cut -d ':' -f 1 | tr -cd 'a-zA-Z0-9\#')
				string=$(echo $line | cut -d ':' -f 2- | tr -cd 'a-zA-Z0-9\ \#\.\,\/\:\=\@' | tr -s ' ')

				[[ "$key" == "General" ]] && part=general
				[[ "$key" == "Audio" ]] && part=audio

				case $part in
					general)
						case $key in
							Genre) g_genre=$(echo $string) ;;
							Recordeddate) g_recordeddate=$(echo $string | tr -cd '0-9' | cut -c 1-4) ;;
							Performer) g_artist=$(echo $string) ;;
							Album) g_album=$(echo $string  | sed 's/EP//' | sed 's/WEB//') ;;
						esac
					;;
					audio)
						case $key in
							Bitratemode) a_bitratemode=$(echo $string) ;;
							Bitrate) a_bitrate=$(echo $string | tr -d " ") ;;
							Channels) a_channels=$(echo $string | tr -cd '0-9') ;;
							Samplingrate) a_samplingrate=$(echo $string | tr -d " ") ;;
							Writinglibrary) a_writinglibrary=$(echo $string | cut -d' ' -f1-2 | tr -d " ") ;;
						esac
					;;
				esac
			done </tmp/audioinfo.tmp         
			rm -f /tmp/audioinfo.tmp

			completnew=$(echo \[AUDiOiNFO\] COMPLETE \( ${releasesiz}MB ${releasenum}F $g_genre $g_recordeddate \))
			
			[ $a_writinglibrary ] || a_writinglibrary="Unknown"

			echo "[+]-----------------------------------"
			echo "[+] found $releaseful"
			
			if [ "$replace_dir" == "yes" ]; then
				[ -d "$releaseful/$completdir" ] && rmdir "$releaseful/$completdir"
				[ -d "$releaseful/$completdir" ] || echo "[-] deleted -> $completdir" 
				
				[ -d "$releaseful/$completnew" ] || mkdir -m644 "$releaseful/$completnew"
				[ -d "$releaseful/$completnew" ] && echo "[+] created -> $completnew" 
			fi

			if [ "$delete_message" == "yes" ]; then
				[ -f "$releaseful/.message" ] && rm -f "$releaseful/.message"
				[ -f "$releaseful/.message" ] || echo "[-] deleted -> .message" 
				[ -f "$releaseful/.bakmessage" ] && rm -f "$releaseful/.bakmessage"
				[ -f "$releaseful/.bakmessage" ] || echo "[-] deleted -> .bakmessage" 
			fi

			# release
			line0=$(echo "$releasedir" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
			line0=$(echo "$line0" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
			# artist
			line1=$(echo "$g_artist" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
			line1=$(echo "$line1" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
			# album
			line2=$(echo "$g_album" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
			line2=$(echo "$line2" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
			# tracks genre year bitrate
			line3=$(echo "$releasenum $releasedes Of $g_genre From $g_recordeddate" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
			line3=$(echo "$line3" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
			# audio info
			line4=$(echo "$a_channels Channels Of $a_bitratemode $a_bitrate At $a_samplingrate" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
			line4=$(echo "$line4" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
			# encoder preset
			line5=$(echo "Encoded With $a_writinglibrary" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
			line5=$(echo "$line5" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')

			echo "[+] created -> .audioinfo" 

			echo ".--------------------------------------------------------------------." > "$audioinfo"
			echo "|                _______ _     _ ______  _____  _____                |" >> "$audioinfo"
			echo "|                |_____| |     | |     \   |   |     |               |" >> "$audioinfo"
 			echo "|                |     | |_____| |_____/ __|__ |_____|               |" >> "$audioinfo"
			echo "|                     _____ __   _ _______  _____                    |" >> "$audioinfo"
			echo "|                       |   | \  | |______ |     |                   |" >> "$audioinfo"
			echo "|                     __|__ |  \_| |       |_____|                   |" >> "$audioinfo"
			echo "|                                                                    |" >> "$audioinfo"
			echo "| -  -  --  ---   --- -----[ A R T i S T ]------ ---   ---  --  -  - |" >> "$audioinfo"
			echo "|                                                                    |" >> "$audioinfo"
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
			echo "|$line5|" >> "$audioinfo"
			echo "|                                                                    |" >> "$audioinfo"
			echo "|             .                          . -   - -  ---+             |" >> "$audioinfo"
			echo "|            -+----------------------------------------|- SiGSCRiPT -+" >> "$audioinfo"
			echo "+-- --    .   |                                        +-- --    .   |" >> "$audioinfo"
			echo "              .                                                      ." >> "$audioinfo"

		done
	done
}

do_audio_info "/glftpd/site/ARCHIVE/MP3"
do_audio_info "/glftpd/site/ARCHIVE/FLAC"
