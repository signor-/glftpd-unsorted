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

# $1 = Name of file.
# $2 = Actual path the file is stored in
# $3 = CRC number
# $PWD = Current Path.
# $USER = Username of uploader

# EXIT codes..
# 0 - Good: 
# 2 - Bad:

echo -e ".--------------------------------------------------."

/bin/zipscript-c "$1" "$2" "$3"

predir=""
predir=`expr "$PWD" : '.*\/_PRE\/*'`

if [ $predir != "0" ]; then
echo -e "| + FILE LOG: pre dir skipped.                     |"
echo -e ".--------------------------------------------------."
exit 0
fi

requestsdir=""
requestsdir=`expr "$PWD" : '.*\/REQUESTS\/*'`

if [ $requestsdir != "0" ]; then
echo -e "| + FILE LOG: requests dir skipped.                |"
echo -e ".--------------------------------------------------."
exit 0
fi

case "$1" in  
	*.mp3)
		/bin/dupeaddchroot -r /etc/bogus.conf "$1" "$USER" > /dev/null 2>&1
		echo -e "| + FILE LOG: mp3 file added.                      |"
		echo -e ".--------------------------------------------------."
		exit 0
        ;;

	*.flac)
		/bin/dupeaddchroot -r /etc/bogus.conf "$1" "$USER" > /dev/null 2>&1
		echo -e "| + FILE LOG: flac file added.                     |"
		echo -e ".--------------------------------------------------."
		exit 0
        ;;

	*)
		echo -e "| + FILE LOG: file skipped.                        |"
		echo -e ".--------------------------------------------------."
        exit 0
        ;;
esac

exit 0
