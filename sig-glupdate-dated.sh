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

SCANDIRS="
/glftpd/site/MP3
/glftpd/site/FLAC
/glftpd/site/MVID
/glftpd/site/ARCHIVE/MP3/2011
/glftpd/site/ARCHIVE/MP3/2012
/glftpd/site/ARCHIVE/FLAC/2011
/glftpd/site/ARCHIVE/FLAC/2012
/glftpd/site/ARCHIVE/MVID/2011
/glftpd/site/ARCHIVE/MVID/2012
"

DATESTRUC="[0-9][0-9][0-9][0-9]-"

GLUPDATEBIN="/glftpd/bin/glupdate"

for GOTDATEDDIR in $SCANDIRS; do
        DATEDDIRS=$(find "$GOTDATEDDIR" -mindepth 1 -maxdepth 1 -type d -path "$GOTDATEDDIR/$DATESTRUC*" | sort)
        for DATEDDIR in $DATEDDIRS; do
                echo "Updating: $DATEDDIR/* (glupdate)"
				$GLUPDATEBIN $DATEDDIR >/dev/null 2>&1
        done
done

