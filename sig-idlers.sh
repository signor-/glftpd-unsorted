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

# site_cmd IDLERS         EXEC    /bin/coz-idlers.sh           #
# custom-idlers           *                                    #
#grep -Ei "[-](`echo $ALLOWINTGRPS | sed 's/ /|/g'`)$"
skipusers="default.user XXX bnc"

days="10"					# how many days before marked as idle?           

if [ "$FLAGS" ]; then
  users_dir="/ftp-data/users"
else
  users_dir="/glftpd/ftp-data/users"		# specify whole path to your users dir (used when run from shell)
fi

# no changes below needed

ver="1.1"
nr="0";
currtime=$(date +%s)

if [ ! -d $users_dir ]; then
echo "could not change to $users_dir"; exit 1; fi

tot=`ls $users_dir/* | grep -v default.user | wc -l | tr -d " "`
for i in `ls $users_dir/* | grep -v default.user | sort -f`; do
user=`basename $i`

laston=$(grep "^TIME " $i | cut -f3 -d ' ')
ago=$(( ($currtime - $laston) / 86400 ))
ratio=`cat $i| grep RATIO | awk '{ print $2 }'`

if [ "$ratio" -ne "0" ]; then
        ratio="ratio"
fi

if [ "$ratio" = "0" ]; then
        ratio="leech"
fi

group=$(grep "^GROUP " $i | cut -f2 -d ' ' | tr '\n' ' ')

if [ "$ago" -gt "$days" ]; then
nr=$[nr + 1];

echo "$ago days -> $user/$group($ratio)"
fi
done

echo ""
echo "$nr out of $tot total users were found idle"

