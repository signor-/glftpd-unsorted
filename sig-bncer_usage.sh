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

BNCERS="
ca.XXX.biz#127.0.0.1
ro.XXX.biz#127.0.0.1
li.XXX.biz#127.0.0.1
nl.XXX.biz#127.0.0.1
"

CNT=0
TOTAL=0
for BNC in $BNCERS; do
	CNT=$(( $CNT + 1 ))
	BDNS=$(echo $BNC | awk -F# '{print $1}')
	BIP=$(echo $BNC | awk -F# '{print $2}')
	NUM=$(tbis -i -n 2>/dev/null | grep -E "^glftpd" | grep "ESTABLISHED" | grep -E ":glftpd->" | grep "0u" | grep "$BIP" | wc -l)
	echo "$BDNS has $NUM current connections in use."
	TOTAL=$(( $NUM + $TOTAL ))
done

AVG=$(echo "scale=2;$TOTAL/$CNT" | bc )

echo "$TOTAL connections in use, an average of $AVG per bouncer."
