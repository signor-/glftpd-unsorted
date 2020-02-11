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

VIDEOAFFILS="-XXXX -XXXXX"
VIDEOAVOID="/_PRE/ /DONTKNOW/"

VIDEOPATHS="
/site/MVID
"

###############################################################################

if [ -d "/glftpd/ftp-data/" ]; then
        echo "this script must be ran in chroot /glftpd only"
        exit 0
fi

VIDEOAFFILS=$(echo $VIDEOAFFILS | sed 's/ /\\|/g')
VIDEOAVOID=$(echo $VIDEOAVOID | sed 's/ /\\|/g')

for VIDEOPATH in $VIDEOPATHS; do
	find "$VIDEOPATH" -type d -iregex ".*\(${VIDEOAFFILS}\)$" -not -iregex ".*\(${VIDEOAVOID}\).*" | while read LINE
	do
		# mr-pre_musicvideoinfo.sh "$LINE"
		echo "[+] updated pre release video info for $LINE"
	done
done
