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
################################################################################

chan="1234567890"
chanarchive="1234567890"
chanprivate="1234567890"
chanstaff="1234567890"

echo " "
echo "Checking $USER user flag(s) and group(s) for invite privleges..."
echo " "
echo "irc server (SSL) = irc.mythnet.org:+7000"
echo " "
echo "#chan blowfish key =		$chan"
echo "#chan-archive blowfish key =     $chanarchive"

nukerflag=`echo $FLAGS | grep A`

if [ "$nukerflag" != "" ]; then
        echo "#chan-private blowfish key =      $chanprivate"
fi

siteopflag=`echo $FLAGS | grep 1`

if [ "$siteopflag" != "" ]; then
        echo "#chan-staff blowfish key =	$chanstaff"
fi
