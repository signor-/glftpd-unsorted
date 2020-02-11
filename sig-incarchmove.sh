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

#incoming to archive move

INCDIRS="
/glftpd/site/MVID#2013#/glftpd/site/ARCHIVE/MVID
"

for INCDIR in $INCDIRS; do
	INCPATH=$(echo $INCDIR | awk -F# '{print $1}')
	INCDATE=$(echo $INCDIR | awk -F# '{print $2}')
	INCARCH=$(echo $INCDIR | awk -F# '{print $3}')
	find "$INCPATH" -mindepth 1 -maxdepth 1 -type d -name "$INCDATE*" | while read LINE
	do
		INCMOVE=$(echo $LINE)
		INCSUBD=$(basename $INCMOVE)
		echo "moving $INCSUBD ($INCMOVE) to $INCARCH"
		cp -rf --preserve "${INCMOVE}" "${INCARCH}"
		echo "changing $INCARCH/$INCSUBD perms to read only"
		chmod -R 755 "${INCARCH}/${INCSUBD}"
		echo "changing $INCARCH/$INCSUBD owner to 0:0"
		chown -R 0:0 "${INCARCH}/${INCSUBD}"
		echo "removing source dir $INCMOVE"
		rm -rf "$INCMOVE"
	done
done
