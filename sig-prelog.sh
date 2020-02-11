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

# Mon Jul 02 22:24:56 2012 PRE: "Lil_Black-On_The_Road_Again-CD-FLAC-2000-JLM" "JLM" "FLAC" "20" "468.8"
# Mon Jul 02 23:29:50 2012 PRE: "Tritonal_and_Kaeno-Azuca-AUTR017-WEB-2012-TraX" "TraX" "MP3" "1" "14.1"
# Mon Jul 02 23:30:51 2012 PRE: "Juventa-Nothing_But_Less_Than_Three-ENPROG094-WEB-2012-TraX" "TraX" "MP3" "1" "16.2"
# Mon Jul 02 23:31:42 2012 PRE: "Daniel_Kandi_and_Ferry_Tayle-Flying_Blue-ENHANCED126-WEB-2012-TraX" "TraX" "MP3" "1" "17.5"
# Mon Jul 02 23:32:47 2012 PRE: "Paul_Van_Dyk_feat_Arty-The_Ocean-VAN2049-WEB-2012-TraX" "TraX" "MP3" "5" "70.5"
# Tue Jul 03 00:20:35 2012 PRE: "Just_Urbain-Everybody_Loves-7inch-Vinyl-2011-FiH" "FiH" "MP3" "3" "21.7"
# Tue Jul 03 02:34:04 2012 PRE: "Lorn-Ask_The_Dust-CD-FLAC-2012-PERFECT" "PERFECT" "FLAC" "12" "290.6"
# Tue Jul 03 02:35:04 2012 PRE: "Def_Jef-Just_A_Poet_With_Soul-Deluxe_Edition-2CD-FLAC-2012-PERFECT" "PERFECT" "FLAC" "27" "835.3"
# Tue Jul 03 03:15:58 2012 PRE: "Current_Value-Megalomania-(PC083D)-WEB-2012-BPM" "BPM" "MP3" "5" "68.1"
# Tue Jul 03 03:33:34 2012 PRE: "Mystification-8_Core_Inside-(BH002CD)-WEB-2012-BPM" "BPM" "MP3" "8" "110.1"

#this runs in chroot via site command.

PRELOG="/ftp-data/logs/pre.log"

if [ "$1" = "" ]; then
	echo "[PRE] NO NUMBER STRING FOUND, DEFAULTING TO LISTING 10 LATEST PRE'S"
	PRENUM=10
	else
	PRENUM=$1
fi

if ! [[ "$PRENUM" =~ ^[0-9]+$ ]] ; then
	echo "[PRE] STRING IS NOT A NUMBER, DEFAULTING TO LISTING 10 LATEST PRE'S"
	PRENUM=10
fi

if [ "$PRENUM" -gt 100 ]; then
	echo "[PRE] MAXIMUM PRE LIST IS 100"
	PRENUM=100
fi

echo "[PRE] LISTING LAST $PRENUM PRE RELEASES"

tail -$PRENUM $PRELOG | while read LINE; do
	PREDATE=`echo $LINE | awk -F"PRE:" '{print $1}'`
	PREDATE=$(date -d"$PREDATE" "+%Y-%m-%d")
	PREWEEK=$(date -d"$PREDATE" "+%W")
	PREREL=`echo $LINE | awk -F"PRE:" '{print $2}' | awk '{print $1}' | tr -d "\"" | sed -e :a -e 's/^.\{1,96\}$/& /;ta'`
	PREGROUP=`echo $LINE | awk -F"PRE:" '{print $2}' | awk '{print $2}' | tr -d "\"" | sed -e :a -e 's/^.\{1,8\}$/ &/;ta'`
	PRESECTION=`echo $LINE | awk -F"PRE:" '{print $2}' | awk '{print $3}' | tr -d "\""`
	PREFILES=`echo $LINE | awk -F"PRE:" '{print $2}' | awk '{print $4}' | tr -d "\"" | sed -e :a -e 's/^.\{1,2\}$/ &/;ta'`
	PRESIZE=`echo $LINE | awk -F"PRE:" '{print $2}' | awk '{print $5}' | tr -d "\"" | sed -e :a -e 's/^.\{1,6\}$/ &/;ta'`
	echo "[PRE] [ $PREDATE ] $PREGROUP -> $PREREL [ ${PREFILES}F ${PRESIZE}MB ] [ WEEK $PREWEEK ]"
done

echo "LIST COMPLETE"
