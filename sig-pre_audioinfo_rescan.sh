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

AUDIOAFFILS="-XXX -XX -XXXX -XXX -XXX -XX -XXXXX -XXXX -XXXXX -XXX -XXX -XXXX -XXXXXXXX -XXXXXX -XXXXXX -XXX -XXXXXX -XXXXXXXXXXX"
AUDIOAVOID="/_PRE/ /DONTKNOW/"

AUDIOPATHS="
/site/MP3
/site/FLAC
"

###############################################################################

if [ -d "/glftpd/ftp-data/" ]; then
        echo "this script must be ran in chroot /glftpd only"
        exit 0
fi

AUDIOAFFILS=$(echo $AUDIOAFFILS | sed 's/ /\\|/g')
AUDIOAVOID=$(echo $AUDIOAVOID | sed 's/ /\\|/g')

for AUDIOPATH in $AUDIOPATHS; do
	find "$AUDIOPATH" -type d -iregex ".*\(${AUDIOAFFILS}\)$" -not -iregex ".*\(${AUDIOAVOID}\).*" -o -iregex ".*\(${AUDIOAFFILS}\)_[a-zA-Z][a-zA-Z][a-zA-Z]$" -not -iregex ".*\(${AUDIOAVOID}\).*" | while read LINE
	do
		rm -f "$LINE/.audioinfo"
		mr-pre_audioinfo.sh "$LINE"
		echo "[+] updated audio pre info for $LINE"
	done
done
