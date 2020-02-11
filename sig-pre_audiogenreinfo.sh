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
# this script if for grabbing genre and year from a file to display with pre. ran in chroot.
# ./sig-audiogenreinfo.sh "/site/MP3/2012-11-26/Mrs._Greenbird-Shooting_Stars_And_Fairy_Tales-WEB-2012-ALPMP3" MP3
# will return "Pop 2012 VBR 221"
#########################################################
# where is MediaInfo located?
mediainfo="/bin/mediainfo"

# where do i find a temp dir?
tempdir=/tmp

# where to announce? default is stdout.
# for announces to channel it should probably be changed to /ftp-data/logs/glftpd.log
logto="/ftp-data/logs/glftpd.log"
#########################################################

[ $1 ] || exit 0;
[ $2 ] || exit 0;

release=`basename $1 | tr '[:upper:]' '[:lower:]'`

[ "$2" == "MP3" ] && fileext="*.mp3";
[ "$2" == "FLAC" ] && fileext="*.flac";

filename=`stat -c"%n" $1/$fileext | head -1` # we only need to list 1 file to get details of the release

$mediainfo $filename >$tempdir/${release}.media.tmp 2>/dev/null

while read line; do
        key=$(echo "$line" | cut -d ':' -f 1 | tr -cd 'a-zA-Z0-9\#')
        string=$(echo $line | cut -d ':' -f 2- | tr "&" "N" | tr -cd 'a-zA-Z0-9\ \#\.\,\/\:\=\@\-' | tr -s ' ')

        [[ "$key" == "General" ]] && part=general
        [[ "$key" == "Audio" ]] && part=audio

        case $part in
                general)
                        case $key in
                                Genre) g_genre=$(echo $string) ;;
                                Recordeddate) g_rdate=$(echo $string | tr -cd '0-9Xx' | cut -c -4) ;;
								Overallbitratemode ) g_mode=$(echo $string) ;;
								Overallbitrate) g_bitrate=$(echo $string | tr -cd '0-9') ;;
                        esac
                ;;
        esac

done <$tempdir/${release}.media.tmp
rm -f $tempdir/${release}.media.tmp

date="$(date "+%a %b %d %H:%M:%S %Y")"

case $g_mode in
	Variable) g_mode="VBR" ;;
	Constant) g_mode="CBR" ;;
esac

[ "$g_genre" ] || g_genre="Unknown"
[ "$g_rdate" ] || g_rdate="0000"
[ "$g_mode" ] || g_mode="Unknown"
[ "$g_bitrate" ] || g_bitrate="000"

echo "\"$g_genre\" \"$g_rdate\" \"$g_mode\" \"$g_bitrate\""

