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

#scripted by signor 2013-03-13

TEMPDIR="/bin"

INPUT="$@"

if [ `echo "$INPUT" | wc -w` != 3 ]; then
	echo "incorrect string given, must be -> ./script.sh <ADD/DEL> <AFFIL> <SECTION>"
	exit 0
fi

WHAT=$(echo $INPUT | tr "[:lower:]" "[:upper:]" | awk '{print $1}')
if [ -z `echo $WHAT | grep -Ei "ADD|DEL"` ]; then
	echo "incorrect function $WHAT, valid are ADD DEL."
	exit 0
fi

AFFIL=$(echo $INPUT | awk '{print $2}')

SECTION=$(echo $INPUT | tr "[:lower:]" "[:upper:]" | awk '{print $3}')
if [ -z `echo $SECTION | grep -Ei "MP3|FLAC|MVID"` ]; then
	echo "incorrect section $SECTION, valid are MP3 FLAC MVID."
	exit 0
fi

case $SECTION in
	MP3) DIRSCRIPT="/bin/dirscript_mp3.sh" ;;
	FLAC) DIRSCRIPT="/bin/dirscript_flac.sh" ;;
	MVID) DIRSCRIPT="/bin/dirscript_mvid.sh" ;;
esac

CURRENTAFFILS=$(cat "$DIRSCRIPT" | grep -Ei "^AFFILS" | sed 's/^AFFILS\=\"\(.*\)\"/\1/')
CURRENTPREDIRS=$(cat "$DIRSCRIPT" | grep -Ei "^PRE_DIRS" | sed 's/^PRE_DIRS\=\"\(.*\)\"/\1/')

if [ "$WHAT" = "ADD" ]; then
	FOUNDAFFIL=$(echo "$CURRENTAFFILS" | grep "$AFFIL")
	if [ -z "$FOUNDAFFIL" ]; then
		NEWAFFILS=$(echo "$CURRENTAFFILS $AFFIL" | tr " " "\n" | sort -d -f | tr "\n" " " | sed 's/^[ \t]*//;s/[ \t]*$//')
		sed -e "s#^AFFILS\=\".*\"#AFFILS\=\"$NEWAFFILS\"#" $DIRSCRIPT > $TEMPDIR/dirscript_`echo $SECTION | tr "[:upper:]" "[:lower:]"`.temp
		mv -f $TEMPDIR/dirscript_`echo $SECTION | tr "[:upper:]" "[:lower:]"`.temp $DIRSCRIPT
		chmod 755 $DIRSCRIPT
                chown 0:0 $DIRSCRIPT
		echo "added $SECTION dirscript affil list -> $AFFIL"
		echo "current $SECTION dirscript affil list -> $NEWAFFILS"
	else
		echo "$AFFIL affil list for section $SECTION already updated."
	fi

	FOUNDPREDIR=$(echo "$CURRENTPREDIRS" | grep "$AFFIL")
	if [ -z "$FOUNDPREDIR" ]; then
		NEWPREDIRS=$(echo "$CURRENTPREDIRS /site/$SECTION/_PRE/$AFFIL" | tr " " "\n" | sort -d -f | tr "\n" " " | sed 's/^[ \t]*//;s/[ \t]*$//')
		sed -e "s#^PRE_DIRS\=\".*\"#PRE_DIRS\=\"$NEWPREDIRS\"#" $DIRSCRIPT > $TEMPDIR/dirscript_`echo $SECTION | tr "[:upper:]" "[:lower:]"`.temp
		mv -f $TEMPDIR/dirscript_`echo $SECTION | tr "[:upper:]" "[:lower:]"`.temp $DIRSCRIPT
		chmod 755 $DIRSCRIPT
		chown 0:0 $DIRSCRIPT
		echo "added $SECTION dirscript pre dir list -> /site/$SECTION/_PRE/$AFFIL"
		echo "current $SECTION dirscript pre dir list -> $NEWPREDIRS"
	else
		echo "$AFFIL pre dir for section $SECTION already updated."
	fi
fi

if [ "$WHAT" = "DEL" ]; then
	FOUNDAFFIL=$(echo "$CURRENTAFFILS" | grep "$AFFIL")
	if [ -z "$FOUNDAFFIL" ]; then
		echo "$AFFIL affil list for section $SECTION already deleted."
	else
		NEWAFFILS=$(echo "$CURRENTAFFILS" | sed -e "s#$AFFIL##" | tr " " "\n" | sort -d -f | tr "\n" " " | sed 's/^[ \t]*//;s/[ \t]*$//')
		sed -e "s#^AFFILS\=\".*\"#AFFILS\=\"$NEWAFFILS\"#" $DIRSCRIPT > $TEMPDIR/dirscript_`echo $SECTION | tr "[:upper:]" "[:lower:]"`.temp
		mv -f $TEMPDIR/dirscript_`echo $SECTION | tr "[:upper:]" "[:lower:]"`.temp $DIRSCRIPT
		chmod 755 $DIRSCRIPT
                chown 0:0 $DIRSCRIPT
		echo "deleted $SECTION dirscript affil list -> $AFFIL"
		echo "current $SECTION dirscript affil list -> $NEWAFFILS"
	fi

	FOUNDPREDIR=$(echo "$CURRENTPREDIRS" | grep "$AFFIL")
	if [ -z "$FOUNDPREDIR" ]; then
		echo "$AFFIL pre dir for section $SECTION already deleted."
	else
		NEWPREDIRS=$(echo "$CURRENTPREDIRS" | sed -e "s#/site/$SECTION/_PRE/$AFFIL##" | tr " " "\n" | sort -d -f | tr "\n" " " | sed 's/^[ \t]*//;s/[ \t]*$//')
		sed -e "s#^PRE_DIRS\=\".*\"#PRE_DIRS\=\"$NEWPREDIRS\"#" $DIRSCRIPT > $TEMPDIR/dirscript_`echo $SECTION | tr "[:upper:]" "[:lower:]"`.temp
		mv -f $TEMPDIR/dirscript_`echo $SECTION | tr "[:upper:]" "[:lower:]"`.temp $DIRSCRIPT
		chmod 755 $DIRSCRIPT
                chown 0:0 $DIRSCRIPT
		echo "deleted $SECTION dirscript pre dir list -> /site/$SECTION/_PRE/$AFFIL"
		echo "current $SECTION dirscript pre dir list -> $NEWPREDIRS"
	fi
fi

exit 0
