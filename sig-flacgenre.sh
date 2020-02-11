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

# /site/FLAC/<dateddir>/<releasedir>/*.flac = #5 in the list.
# /site/FLAC/_PRE/<GROUP>/<RELEASE>/*.flac = #6 in the list.

FLACDIRNUMBER="6"
RELDIRPWD=$(echo $PWD | sed 's/\//\n/g' | wc -l)

VALIDGENRES="
Blues
Classic Rock
Country
Dance
Disco
Funk
Grunge
Hip-Hop
Jazz
Metal
New Age
Oldies
Other
Pop
R&B
Rap
Reggae
Rock
Techno
Industrial
Alternative
Ska
Death Metal
Pranks
Soundtrack
Euro-Techno
Ambient
Trip-Hop
Vocal
Jazz+Funk
Fusion
Trance
Classical
Instrumental
Acid
House
Game
Sound Clip
Gospel
Noise
AlternRock
Bass
Soul
Punk
Space
Meditative
Instrumental Pop
Instrumental Rock
Ethnic
Gothic
Darkwave
Techno-Industrial
Electronic
Pop-Folk
Eurodance
Dream
Southern Rock
Comedy
Cult
Gangsta
Top 40
Christian Rap
Pop/Funk
Jungle
Native American
Cabaret
New Wave
Psychadelic
Rave
Showtunes
Trailer
Lo-Fi
Tribal
Acid Punk
Acid Jazz
Polka
Retro
Musical
Rock & Roll
Hard Rock
Goa
Drum & Bass
Club House
Hardcore
Terror
Indie
BritPop
Negerpunk
Polsk Punk
Beat
Christian Gangsta Rap
Heavy Metal
Black Metal
Crossover
Contemporary Christian
Christian Rock
Merengue
Salsa
Thrash Metal
Anime
JPop
Synthpop
Unknown
"

INPUT="$@"  

[ "$INPUT" = "help" ] && {
	echo "[x] This script functions in the following way..."
	echo "[x] "
	echo "[x] (00:00:00) [1] site flacgenre Pop"
	echo "[x] (00:00:00) [1] 200- [x] Changing .flac file(s) GENRE for <Artist>-<Album Title>-CD-FLAC-2012-<GROUP> from Metal to Pop..."
	echo "[x] (00:00:00) [1] 200- [x] ...Regenerating .sfv file 00-<artist>-album title>-cd-2012.sfv"
	echo "[x] (00:00:00) [1] 200- [x] ...Rescanning <Artist>-<Album Title>-CD-FLAC-2012-<GROUP>"
	echo "[x] (00:00:00) [1] 200- [x] ...Genre change complete!"
	echo "[x] (00:00:00) [1] 200- [x] ...Make sure to manually update genre field in 00-<artist>-album title>-cd-2012.nfo"
	echo "[x] (00:00:00) [1] 200 Command Successful."
	echo "[x] "
	echo "[x] You MUST be inside a -FLAC- release within your PRE directory for this script to function!"
	echo "[x] "
	echo "[x] This script was designed so that you are able to change the GENRE field on-the-fly,"
	echo "[x] as we all know, this field can be accidently mislabeled, and needs to be changed!"
	echo "[x] "
	echo "[x] Now you can change genre without having to retag/repack locally and then reupload."
	echo "[x] "
    echo "[x] Usage: 'site flacgenre list' (shows a list of valid genres)"
	echo "[x] Usage: 'site flacgenre <genre>' (sets flac file genre to <genre>)"
	echo "[x] "
	echo "[x] -sigscript (written by signor 2012)"
	exit 2
}

[ "$INPUT" ] || {
		echo "[x] Type 'site flacgenre help' for help. (no input given)"
		exit 2
}     

[ `echo $PWD | grep "/FLAC/_PRE"` ] || {
	echo "[x] Type 'site flacgenre help' for help. (not inside a flac pre directory)"
        exit 2
}

[ "$RELDIRPWD" = "$FLACDIRNUMBER" ] && {

[ `basename $PWD | grep "\-FLAC\-"` ] || {
        echo "[x] Type 'site flacgenre help' for help. (not inside a flac release directory)"
	exit 2
}

		[ "$INPUT" = "list" ] && {
			echo "[x] Valid flac genres are..."
			for GENRECHECK in "$VALIDGENRES"; do
					echo "$GENRECHECK"
			done
			echo "[x] ... list complete!"
			exit 2
		}

        for GENRECHECK in "$VALIDGENRES"; do
                echo "$INPUT" | grep -x "$GENRECHECK" > /dev/null && {
                        GENREOK=YES
                }
        done           

        [ $GENREOK ] || {
	        echo "[x] Type 'site flacgenre list' for a list of valid genres (genre '$INPUT' is not valid)"
                exit 2
        }        

        FLACFILES=$(find $PWD -maxdepth 1 -iname "*.flac")

        [ "$FLACFILES" ] && {
                GENREBEFORE=$(metaflac --show-tag=GENRE $PWD/*.flac | egrep -i ":genre=" | awk -F= '{print $(NF-0)}' | head -1)
                #remove GENRE field first
                metaflac --remove-tag=GENRE $PWD/*.flac      
                #set new GENRE field
                metaflac --set-tag=GENRE="$INPUT" $PWD/*.flac
                GENREAFTER=$(metaflac --show-tag=GENRE $PWD/*.flac | egrep -i ":genre=" | awk -F= '{print $(NF-0)}' | head -1)
                RELEASE=$(basename $PWD)
                echo "[x] Changing .flac file(s) GENRE for $RELEASE from $GENREBEFORE to $GENREAFTER..."
                SFVNAME=$(find $PWD -maxdepth 1 -iname "*.sfv")
				[ "$SFVNAME" ] && {
					echo "[x] ...Regenerating .sfv file `basename $SFVNAME`"
					rm -f "$SFVNAME"
					cksfv -C "$PWD" *.flac > "$SFVNAME"
					echo "[x] ...Rescanning $RELEASE"
					cd "$PWD"
					rescan --normal >/dev/null 2>&1
					echo "[x] ...Genre change complete!"
				} || {
					NEWSFV=`basename $PWD | tr [A-Z] [a-z]`
					echo "[x] ...No .sfv file found, generating a new sfv file 00-${NEWSFV}.sfv"
					cksfv -C "$PWD" *.flac > "$PWD/00-${NEWSFV}.sfv"
					echo "[x] ...Rescanning $RELEASE"
					cd "$PWD"
					rescan --normal >/dev/null 2>&1
					echo "[x] ...Genre change complete!"
					}
                NFO=$(find $PWD -maxdepth 1 -iname "*.nfo")       
                echo "[x] ...Make sure to manually update genre field in `basename $NFO`"
        } || {
				echo "[x] No .flac files, you might want to upload some first!"
		}
} || {      
	echo "[x] Type 'site flacgenre help' for help. (not inside a flac release directory)"
}                 
