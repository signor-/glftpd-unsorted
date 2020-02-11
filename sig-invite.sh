#!/bin/sh
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
################################################################################

log="/ftp-data/logs/glftpd.log"

if [ -z "$1" ] || [ ! -z "$2" ] ; then
 echo "Usage: SITE INVITE <irc-nick>"
 exit 0
fi

badchars=`echo -n "$1" | tr -d "[a-z][A-Z][0-9]|\-_^]["`
if [ ! -z "$badchars" ]; then
 echo "\nERROR - Invalid characters in nick: $badchars\n"
 exit 0
fi

echo `/bin/date '+%a %b %d %X %Y'` INVITE: \"$1\" \"$USER\" \"$GROUP\" \"$FLAGS\" \"$TAGLINE\" >> "$log"
echo "Invited $USER with nick $1"
sig-showkeys.sh
sig-users_nicks.sh $USER $1
