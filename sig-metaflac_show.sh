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

INPUT="$@"

[ "$INPUT" = "help" ] && {
	echo "This script will show ALL of the metadata fields for .flac files within a -FLAC- release."
	echo " "
	echo "You MUST be inside a -FLAC- release directory for this script to function!"
        echo " "
        echo "Usage: 'site flacmeta' (shows metadata for flac files in the current directory)"
        echo " "
        echo "-sigscript (written by signor 2012)"
	exit 0
}

[ `basename $PWD | grep "\-FLAC\-"` ] || {
	echo "Type 'site flacmeta help' for help. (not inside a flac release directory)"
        exit 2
}

FLACFILES=$(find $PWD -maxdepth 1 -iname "*.flac" | sort -g)
TMPDIR="/tmp"
TMPMETADIR=`basename $PWD`

[ "$FLACFILES" ] && {
	echo "---------------------------------------------------------"
	echo " "
	echo "$TMPMETADIR FLAC METADATA"
	echo " "
	for FILE in $FLACFILES; do
		BASEFILE=`basename $FILE`
		[ -d "$TMPDIR/$TMPMETADIR" ] || mkdir -m777 "$TMPDIR/$TMPMETADIR"       
		metaflac --export-tags-to="$TMPDIR/$TMPMETADIR/$BASEFILE" $FILE
		DATA=`cat "$TMPDIR/$TMPMETADIR/$BASEFILE" | sort` 
		echo "---------------------------------------------------------"
		echo " "
		echo "$BASEFILE..."
		echo " "
		echo "$DATA"
		echo " "
		rm -f "$TMPDIR/$TMPMETADIR/$BASEFILE"
	done
	echo "---------------------------------------------------------"
	rmdir "$TMPDIR/$TMPMETADIR"
	
} || {
	echo "Type 'site flacmeta help' for help. (no flac files found)"
}


