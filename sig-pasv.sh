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
################################################################################
# SCRIPT WRITTEN BY SIGNOR MARCH 2012, WHY ARE YOU READING THIS? FCK OFF!
################################################################################

date="$(date "+%a %b %d %H:%M:%S %Y")"

gllog="/ftp-data/logs/glftpd.log"

iplog="/ftp-data/iplogs/iplog.log"
iplogdir="/ftp-data/iplogs"

        if [ ! -f $iplogdir/pasv ]; then
                touch $iplogdir/pasv
                chmod 666 $iplogdir/pasv
        fi

echo "$USER/$GROUP $HOST - $1 $2 $3" >> $iplogdir/pasv
echo "200$USER/$GROUP $HOST - $1 $2 $3"

exit 0

#(14:40:59) [1] PASV
#(14:41:00) [1] 200- signor/SITEOP signor@127.0.0.1 - PASV signor SITEOP
#(14:41:00) [1] 227 Entering Passive Mode (111,222,333,444,55,666)
#(14:41:00) [1] Opening data connection IP: 111.222.333.444 PORT: 555
