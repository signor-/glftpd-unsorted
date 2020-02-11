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

### CODE ###

# find affil list in dirscript for each section
dirscripts="
/bin/dirscript_mp3.sh:MP3
/bin/dirscript_flac.sh:FLAC
/bin/dirscript_mvid.sh:MVID
"

OIFS=$IFS
IFS='
'

###############################################################################

for dirscript in $dirscripts; do
	filename=$(echo $dirscript | awk -F: '{print $1}')
	section=$(echo $dirscript | awk -F: '{print $2}')
	affillist=$(cat $filename | grep ^AFFILS= | awk -F= '{print $2}' | tr -d "\"" | tr " " "\n" | sort -uf | tr "\n" " ")
	number=$(echo $affillist | wc -w)
	
	section=$(echo "$section AFFILIATES" | sed -e :a -e 's/^.\{1,78\}$/ & /;ta')
	section=${section:0:77}
	affillist=$(echo $affillist | sed -e 's/.\{40\} /&\n/g')

	echo "|                                                                             |"
	echo "|$section|"
	echo "|                                                                             |"
		for affilline in $affillist; do
			affilline=$(echo "$affilline" | sed -e :a -e 's/^.\{0,78\}$/ & /;ta')
			affilline=${affilline:0:77}
			echo "|$affilline|"
		done
	echo "|                                                                             |"
	echo "|    + ----------------------------------------------------------------- +    |"
done
	echo "|                                                                             |"
	echo "|             .                                   . -   - -  ---+             |"
	echo "|            -+-------------------------------------------------|- SiGSCRiPT -+"
	echo "+-- --    .   |                                                 +-- --    .   |"
	echo "              .                                                               ."
exit 0

