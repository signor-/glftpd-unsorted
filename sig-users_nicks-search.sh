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

USERSDIR="/glftpd/ftp-data/users_nicks"

NUMINPUT=`echo $@ | wc -w`

if [ "$NUMINPUT" != "2" ]; then
        exit 0
fi

if [ "$1" == "FINDNICK" ]; then
	if [ "$2" = "{}" ]; then
		echo "no nickname given!"
		exit 0
	fi
        for USERNAME in `ls $USERSDIR`; do
                FOUNDNICK=`cat $USERSDIR/$USERNAME | grep -w "$2"`
                if [ "$FOUNDNICK" != "" ]; then
                    echo "$FOUNDNICK is linked to user account $USERNAME"
					FOUND=1
				fi
        done
	if [ -z $FOUND ]; then
		echo "nickname $2 not found!"
	fi
fi

if [ "$1" == "SHOWNICK" ]; then
        if [ "$2" = "{}" ]; then
                echo "no username given!"
                exit 0
        fi
        if [ -f $USERSDIR/$2 ]; then
			echo "nicknames for user $2 are..."
			for NICKNAME in `cat $USERSDIR/$2`; do
                echo "$NICKNAME"
			done
		else
			echo "user file for $2 doesn't exist!"
			exit 0
		fi
fi
