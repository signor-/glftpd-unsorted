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

#this script is ran from invite.sh as chroot

USERSDIR="/ftp-data/users_nicks"

NUMINPUT=`echo $@ | wc -w`

if [ "$NUMINPUT" != "2" ]; then
	exit 0
fi

USERNAME=`echo $@ | awk '{print $1}'`
NICKNAME=`echo $@ | awk '{print $2}'`

if [ -f $USERSDIR/$USERNAME ]; then
	FOUNDNICK=`cat $USERSDIR/$USERNAME | grep "$NICKNAME"`
	if [ -z "$FOUNDNICK" ]; then
		echo "$NICKNAME" >> $USERSDIR/$USERNAME
	fi
else
	echo "$NICKNAME" > $USERSDIR/$USERNAME
fi
