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

# this script must be ran in chroot environment for the imdb script to function properly!

# use this script in incoming dirs only, aka for pre releases.

SCANDIRS="
/site/MP3
"
#/site/FLAC

if [ -d "/glftpd/ftp-data/" ]; then
        echo "this script must be ran in chroot /glftpd only"
        exit 0
fi

for SCANDIR in $SCANDIRS; do
	find "$SCANDIR" -iname ".audioinfo" | while read LINE
		do
			releasecom=$(echo "$LINE")
			releaseful=$(dirname "$LINE") # contains full path, not including the .audioinfo
			releasedir=$(basename "$releaseful") # contains the release directory name only
			
			echo "rescanning pre release audio info for $releaseful"
			rm -f "$releasecom"
			/bin/sig-pre_audioinfo.sh "$releaseful"
	done
done


