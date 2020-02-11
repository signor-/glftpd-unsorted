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
#
# UserCleaner v1.01                                 Copyright 2002 [Jedi]
#
# This simple script scans userdir and delete users who havent been
# around for too long, in other word, inactive users.
# 
# Installation: edit configuration
#               chmod +x usercleaner.sh
#               and ./usercleaner.sh
# you can add to crontab at any appropriate intervals and drivert output
# to a log file...
#
#########################################################################
### Configuration:
#
# Set the path to your userdir, without a trailing slash
USERDIR=/glftpd/ftp-data/users

# Set the flags for users who are exempted from test.
# ALWAYS put flag number 6 to make sure not to test already deleted users
EXEMPT="146"

# Maximal number of days the user can be offsite, if a user hasnt
# logged in for MAXTIME days he will be deleted.
MAXTIME=30

# This is a safe mechanism, which only output the users who need
# to be deleted, set to 0 to actually delete, set to 1 to print only.
PRINTONLY=1

### End of configuration...
#########################################################################

NOW=`date +%s`
let "MAXTIME*=86400"
total=0
for USERFILE in $(ls $USERDIR); do
        if [ "`echo $USERFILE  | grep "^default\."`" = "$USERFILE" ]; then
                continue
        fi
        UserFlags=`cat $USERDIR/$USERFILE | grep ^FLAGS | awk '{print $2}'`
        if [ "`echo $UserFlags | grep [$EXEMPT]`" = "$UserFlags" ]; then
                continue
        fi
        LastOnline=`cat $USERDIR/$USERFILE | grep "^TIME " | awk '{print $3}'`
        let "Interval = $NOW - $LastOnline"
        if [ "$Interval" -gt "$MAXTIME" ]; then
                let "DaysOff = $Interval / 86400"
                let "total++"
                echo "$USERFILE has been away $DaysOff days"
                if [ "$PRINTONLY" = "0" ]; then 
                        cat $USERDIR/$USERFILE | sed '/^FLAGS/s/$/6/' > $USERDIR/$USERFILE
                fi
        fi

done

echo "--- $total total users ---"


