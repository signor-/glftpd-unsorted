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
# show_diz        .musicvideoinfo      *
###############################################################################
# where is mediainfo located?
mediainfo="/bin/mediainfo"
# use regex! multiple regex dirs allowed, space seperated
complete_dir=".*\/\[XXX\].COMPLETE.(.*)"
# replace the complete dir with a generic version?
replace_dir=no
# delete message file? (it holds race data from pzs-ng)
delete_message=yes
###############################################################################
# check the bottom of script for other variables!
###############################################################################
function do_musicvideo_info () {
	for found_dir in $complete_dir; do
		# echo "[+] searching for pattern \"$found_dir\" inside path \"$1\" to create .musicvideoinfo"
                find "$1" -regextype posix-egrep -regex "$complete_dir" | while read LINE
		do
			releaseful=$(dirname "$LINE") # contains full path, not including the complete directory
			releasedir=$(basename "$releaseful") # contains the release directory name only
			releaselst=$(ls "$releaseful") # contains the file contents of the release directory
			releasenfo=$(echo "$releaselst" | grep -Ei "\.nfo") # contains filename of .nfo
			releasenum=$(echo "$releaselst" | grep -Ei "\.mkv|\.r[a0-9][r0-9]" | wc -l) # contains number of files
			releasedet=$(echo "$releaselst" | grep -Ei "\.mkv|\.r[a0-9][r0-9]" | tail -1) # contains 1 file, for use with mediainfo
			releaseext=${releasedet##*.} # contains the extention of the file
			releaseart=$(echo "$releasedir" | tr "-" "#" | awk -F# '{print $1}' | tr "_" " ") # contains artist
			releaseart=`correct_case "$releaseart"` # corrects the case structure of artist
			releasetit=$(echo "$releasedir" | sed 's/\([0-9][0-9][0-9][0-9]\)\-\([0-9][0-9]\)\-\([0-9][0-9]\)/\1_\2_\3/' | tr "-" "#" | awk -F# '{print $2}' | tr "_" " " | tr -cd 'a-zA-Z0-9 ' | sed 's/\([0-9][0-9][0-9][0-9]\) \([0-9][0-9]\) \([0-9][0-9]\)/\1-\2-\3/') # contains title
			releasetit=`correct_case "$releasetit"` # corrects the case structure of title
			releaseyea=$(echo "$releasedir" | sed 's/.*[-]\([0-9][0-9][0-9].\)[-].*/\1/')
			completdir=$(basename "$LINE") # contains the [complete] dir that was found
			musicvideoinfo=$(echo "${releaseful}/.musicvideoinfo")
			
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
			$mediainfo "$releaseful/$releasedet" >/tmp/musicvideoinfo.tmp 2>/dev/null
			while read line; do

				key=$(echo "$line" | cut -d ':' -f 1 | tr -cd 'a-zA-Z0-9\#')
				string=$(echo $line | cut -d ':' -f 2- | tr "&" "N" | tr -cd 'a-zA-Z0-9\ \#\.\,\/\:\=\@\-' | tr -s ' ')

				[[ "$key" == "General" ]] && part=general
				[[ "$key" == "Video" ]] && part=video
				[[ "$key" == "Audio" ]] && part=audio

				case $part in
					general)
						case $key in
							Format) g_format=$(echo $string) ;;
							Duration) g_duration=$(echo $string) ;;
							Overallbitrate) g_bitrate=$(echo $string | tr -d " ") ;;
						esac
					;;
					video)
						case $key in
							Format) v_format=$(echo $string) ;;
							Formatprofile) v_formatprofile=$(echo $string) ;;
							Framerate) v_framerate=$(echo $string | tr -cd '.0-9') ;;
							Writinglibrary) v_writinglibrary=$(echo $string) ;;
						esac
					;;
					audio)
						case $key in
							Format) a_format=$(echo $string) ;;
							Formatprofile) a_formatprofile=$(echo $string) ;;
							Channels) a_channels=$(echo $string | tr -cd '0-9') ;;
							Samplingrate) a_samplingrate=$(echo $string | tr -d " ") ;;
						esac
					;;
				esac
			done </tmp/musicvideoinfo.tmp         
			rm -f /tmp/musicvideoinfo.tmp

			# grab genre from the nfo file
			[ $releasenfo ] && releasegen=`cat $releaseful/$releasenfo | grep -Ei ".*genre.*" | tr -cd 'a-zA-Z0-9' | tr "[:upper:]" "[:lower:]" | awk -Fgenre '{print $2}'`
			
			case $releasegen in
				acapella*) releasegen="acapella";;
				acid*) releasegen="acid";;
				acidjazz*) releasegen="acid jazz";;
				acidpunk*) releasegen="acid punk";;
				acoustic*) releasegen="acoustic";;
				alternative*) releasegen="alternative";;
				alternrock*) releasegen="altern rock";;
				ambient*) releasegen="ambient";;
				anime*) releasegen="anime";;
				avantgarde*) releasegen="avant garde";;
				ballad*) releasegen="ballad";;
				bass*) releasegen="bass";;
				beat*) releasegen="beat";;
				bebob*) releasegen="be bob";;
				bigband*) releasegen="big band";;
				blackmetal*) releasegen="black metal";;
				bluegrass*) releasegen="blue grass";;
				blues*) releasegen="blues";;
				bootybass*) releasegen="booty bass";;
				britpop*) releasegen="brit pop";;
				cabaret*) releasegen="cabaret";;
				celtic*) releasegen="celtic";;
				chambermusic*) releasegen="chamber music";;
				chanson*) releasegen="chanson";;
				chorus*) releasegen="chorus";;
				christiangangsta*) releasegen="christian gangsta";;
				christianrap*) releasegen="christian rap";;
				christianrock*) releasegen="christian rock";;
				classical*) releasegen="classical";;
				classicrock*) releasegen="classic rock";;
				club*) releasegen="club";;
				clubhouse*) releasegen="club house";;
				comedy*) releasegen="comedy";;
				contemporaryc*) releasegen="contemporary c";;
				country*) releasegen="country";;
				crossover*) releasegen="crossover";;
				cult*) releasegen="cult";;
				dance*) releasegen="dance";;
				dancehall*) releasegen="dance hall";;
				darkwave*) releasegen="darkwave";;
				deathmetal*) releasegen="death metal";;
				disco*) releasegen="disco";;
				dream*) releasegen="dream";;
				drumbass*) releasegen="drum bass";;
				drumsolo*) releasegen="drum solo";;
				duet*) releasegen="duet";;
				easylistening*) releasegen="easy listening";;
				electronic*) releasegen="electronic";;
				ethnic*) releasegen="ethnic";;
				eurodance*) releasegen="eurodance";;
				eurohouse*) releasegen="euro house";;
				eurotechno*) releasegen="euro techno";;
				fastfusion*) releasegen="fast fusion";;
				folk*) releasegen="folk";;
				folklore*) releasegen="folk lore";;
				folkrock*) releasegen="folk rock";;
				freestyle*) releasegen="freestyle";;
				funk*) releasegen="funk";;
				fusion*) releasegen="fusion";;
				game*) releasegen="game";;
				gangsta*) releasegen="gangsta";;
				goa*) releasegen="goa";;
				gospel*) releasegen="gospel";;
				gothic*) releasegen="gothic";;
				gothicrock*) releasegen="gothic rock";;
				grunge*) releasegen="grunge";;
				hardcore*) releasegen="hard core";;
				hardrock*) releasegen="hard rock";;
				heavymetal*) releasegen="heavy metal";;
				hiphop*) releasegen="hip hop";;
				house*) releasegen="house";;
				humour*) releasegen="humour";;
				indie*) releasegen="indie";;
				industrial*) releasegen="industrial";;
				instrumental*) releasegen="instrumental";;
				instrumentalpop*) releasegen="instrumental pop";;
				instrumentalrock*) releasegen="instrumental rock";;
				jazz*) releasegen="jazz";;
				jazzfunk*) releasegen="jazz funk";;
				jpop*) releasegen="jpop";;
				jungle*) releasegen="jungle";;
				latin*) releasegen="latin";;
				lofi*) releasegen="lo fi";;
				meditative*) releasegen="meditative";;
				merengue*) releasegen="merengue";;
				metal*) releasegen="metal";;
				musical*) releasegen="musical";;
				nationalfolk*) releasegen="national folk";;
				nativeamerican*) releasegen="native american";;
				negerpunk*) releasegen="neger punk";;
				newage*) releasegen="new age";;
				newwave*) releasegen="new wave";;
				noise*) releasegen="noise";;
				none*) releasegen="none";;
				oldies*) releasegen="oldies";;
				opera*) releasegen="opera";;
				other*) releasegen="other";;
				polka*) releasegen="polka";;
				polskpunk*) releasegen="polsk punk";;
				pop*) releasegen="pop";;
				popfolk*) releasegen="pop folk";;
				popfunk*) releasegen="pop funk";;
				porngroove*) releasegen="porn groove";;
				powerballad*) releasegen="power ballad";;
				pranks*) releasegen="pranks";;
				primus*) releasegen="primus";;
				progressiverock*) releasegen="progressive rock";;
				psychadelic*) releasegen="psychadelic";;
				psychedelicrock*) releasegen="psychedelic rock";;
				punk*) releasegen="punk";;
				punkrock*) releasegen="punk rock";;
				rap*) releasegen="rap";;
				rave*) releasegen="rave";;
				reggae*) releasegen="reggae";;
				retro*) releasegen="retro";;
				revival*) releasegen="revival";;
				rhythmicsoul*) releasegen="rhythmic soul";;
				rb*) releasegen="rnb";;
				rock*) releasegen="rock";;
				rockroll*) releasegen="rock n roll";;
				salsa*) releasegen="salsa";;
				samba*) releasegen="samba";;
				satire*) releasegen="satire";;
				showtunes*) releasegen="show tunes";;
				ska*) releasegen="ska";;
				slowjam*) releasegen="slow jam";;
				slowrock*) releasegen="slow rock";;
				sonata*) releasegen="sonata";;
				soul*) releasegen="soul";;
				soundclip*) releasegen="sound clip";;
				soundtrack*) releasegen="sound track";;
				southernrock*) releasegen="southern rock";;
				space*) releasegen="space";;
				speech*) releasegen="speech";;
				swing*) releasegen="swing";;
				symphonicrock*) releasegen="symphonic rock";;
				symphony*) releasegen="symphony";;
				synthpop*) releasegen="synth pop";;
				tango*) releasegen="tango";;
				techno*) releasegen="techno";;
				technoindustrial*) releasegen="techno industrial";;
				terror*) releasegen="terror";;
				thrashmetal*) releasegen="thrash metal";;
				top40*) releasegen="top 40";;
				trailer*) releasegen="trailer";;
				trance*) releasegen="trance";;
				tribal*) releasegen="tribal";;
				triphop*) releasegen="trip hop";;
				vocal*) releasegen="vocal";;
				*) releasegen="unknown";;
			esac
			
			releasegen=`correct_case "$releasegen"`
			
			completnew=$(echo \[ViDEOiNFO\] COMPLETE \( ${releasesiz}MB ${releasenum}F $releasegen $releaseyea \))
			
			# echo "[+]-----------------------------------"
			# echo "[+] found $releaseful"
			
			if [ "$replace_dir" == "yes" ]; then
				[ -d "$releaseful/$completdir" ] && rmdir "$releaseful/$completdir"
				[ -d "$releaseful/$completnew" ] || mkdir -m644 "$releaseful/$completnew"
			fi

			if [ "$delete_message" == "yes" ]; then
				[ -f "$releaseful/.message" ] && rm -f "$releaseful/.message"
			fi

			# release
			line0=$(echo "$releasedir" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
			line0=$(echo "$line0" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
			# artist
			line1=$(echo "$releaseart" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
			line1=$(echo "$line1" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
			# album
			line2=$(echo "$releasetit" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
			line2=$(echo "$line2" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
			# tracks genre year
			line3=$(echo "$releasenum $releasedes Of $releasegen From $releaseyea" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
			line3=$(echo "$line3" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
			# video info
			line4=$(echo "$g_duration Runtime At An Average Bitrate Of $g_bitrate" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
			line4=$(echo "$line4" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
			line5=$(echo "Codec Is $v_format ($v_formatprofile) At $v_framerate FPS" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
			line5=$(echo "$line5" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
			# audio info
			line6=$(echo "$a_channels Channels Of $a_format ($a_formatprofile) At $a_samplingrate" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
			line6=$(echo "$line6" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')
			# encoder preset
			line7=$(echo "Encoded With $v_writinglibrary" | awk '{ l=length(); s=int((68-l)/2); printf "%"(s+l)"s\n", $0 }')
			line7=$(echo "$line7" | awk '{ l=length(); s=int((68-l)); printf "%-"(s+l)"s\n", $0 }')

			echo ". -  -  --  ---   --- -------------------------- ---   ---  --  -  - ." > "$musicvideoinfo"
			echo "|                       _____   ______ _______                       |" >> "$musicvideoinfo"
			echo "|                      |_____] |_____/ |______                       |" >> "$musicvideoinfo"
			echo "|                      |       |    \_ |______                       |" >> "$musicvideoinfo"
			echo "|       ______ _______        _______ _______ _______ _______        |" >> "$musicvideoinfo"    
			echo "|      |_____/ |______ |      |______ |_____| |______ |______        |" >> "$musicvideoinfo"
			echo "|      |    \_ |______ |_____ |______ |     | ______| |______        |" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "| -  -  --  ---   --- -------------------------- ---   ---  --  -  - |" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "|     T H I S    W A S    A    S I T E    P R E    R E L E A S E     |" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "| -  -  --  ---   --- -----[ A R T i S T ]------ ---   ---  --  -  - |" >> "$musicvideoinfo" 
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "|$line1|" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "| -  -  --  ---   --- ------[ A L B U M ]------- ---   ---  --  -  - |" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "|$line2|" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "| -  -  --  ---   --- -------[ i N F O ]-------- ---   ---  --  -  - |" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "|$line3|" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "| -  -  --  ---   --- ------[ V i D E O ]------- ---   ---  --  -  - |" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "|$line4|" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "|$line5|" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "| -  -  --  ---   --- ------[ A U D i O ]------- ---   ---  --  -  - |" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "|$line6|" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "| -  -  --  ---   --- ----[ E N C O D E R ]----- ---   ---  --  -  - |" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "|$line7|" >> "$musicvideoinfo"
			echo "|                                                                    |" >> "$musicvideoinfo"
			echo "|             .                          . -   - -  ---+             |" >> "$musicvideoinfo"
			echo "|            -+----------------------------------------|- SiGSCRiPT -+" >> "$musicvideoinfo"
			echo "+-- --    .   |                                        +-- --    .   |" >> "$musicvideoinfo"
			echo "              .                                                      ." >> "$musicvideoinfo"
		done
	done
}

function correct_case () { 
	IFS=" "
	fullstring=""
	for i in $1; do
		i=`echo $i | tr -d "."`
		case $i in
                    [Ff][Tt]|[Ff][Ee][Aa][Tt]|[Ff][Ee][Aa][Tt][Uu][Rr][Ii][Nn][Gg]) i="ft";;
                    [Vv]|[Vv][Ss]|[Vv][Ee][Rr][Ss][Uu][Ss]) i="vs";;
					[Vv][Aa]|[Vv][.-_][Aa][.-_]|[Vv][Aa][Rr][Ii][Oo][Uu][Ss][.-_][Aa][Rr][Tt][Ii][Ss][Tt][Ss]) i="va";;
                esac
		uprcase=`echo "${i:0:1}" | tr "[:lower:]" "[:upper:]"`;
		lwrcase=`echo "${i:1}" | tr "[:upper:]" "[:lower:]"`;
		fullstring=`echo ${fullstring} ${uprcase}${lwrcase}`
	done
	echo "$fullstring"              
} 

if [ -z $1 ]; then
	exit 0
else
	if [ -d $1 ]; then
		do_musicvideo_info "$1"
	else
		exit 0
	fi
fi
