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

userfilepath="/ftp-data/users"
byefilepath="/ftp-data/byefiles"

if [ "$1" == "" ]; then
	echo "Please provide a username"
	exit 0
fi

OIFS="$IFS"
IFS='
'

if [ ! -f "$userfilepath/$1" ]; then
	echo "User $1 does not exist!"
	exit 0
else
	delreason=$(cat "$byefilepath/$1.bye")

if [ "$delreason" = "%!/ftp-data/byefiles/default.bye" ]; then
	delreason="You have been deleted."
fi

	echo "$1 was deleted for the following reason..."

	for line in $delreason; do
		echo "$line"
	done
fi

exit 0
