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

# this script gets the current disk setup for mounting the crypted drives.
# UUID is shown as from 'blkid'.
# Make sure the mount list is in order of mounting procedure.

UUID="
00000000-0000-0000-00000000000000000#glftpd#/glftpd
00000000-0000-0000-00000000000000000#site#/glftpd/site
00000000-0000-0000-00000000000000000#flac#/glftpd/site/FLAC
00000000-0000-0000-00000000000000000#mp3#/glftpd/site/MP3
00000000-0000-0000-00000000000000000#archive#/glftpd/site/ARCHIVE
"

###############################################################################

BLKID=$(blkid)

for DUID in $UUID; do
	ID=$(echo $DUID | awk -F# '{print $1}')
	DM=$(echo $DUID | awk -F# '{print $2}')
	MT=$(echo $DUID | awk -F# '{print $3}')
	DEV=$(echo "$BLKID" | grep "$ID" | awk -F: '{print $1}')
	echo "cryptsetup luksOpen $DEV $DM"
	echo "mount /dev/mapper/$DM $MT"
done
