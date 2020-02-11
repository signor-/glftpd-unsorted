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

#glftpd log
GLLOG="/glftpd/ftp-data/logs/glftpd.log"

REWLOG="/glftpd/ftp-data/logs/randomreward.log"

#userfile path
USERPATH="/glftpd/ftp-data/users"

#userfile backup path
BUPATH="/glftpd/ftp-data/users_backups"

#skip what userfiles?
SKIPUSERS="default\.user|bnc|glftpd|signor"

#number of times to loop reward?
NUMLOOP="10000"

#reward? in kbytes (divide by 1024000 for gb)
CREDITRANGE="10240000-102400000"

###############################################################################
BUDATE=`date "+%Y_%B_%d"`

echo "[RW] BACKING UP USER DIR into $BUPATH/USERBACKUP-$BUDATE.tar.gz"
tar -zcvf "$BUPATH/USERBACKUP-$BUDATE.tar.gz" "$USERPATH" 1> /dev/null 2> /dev/null

USERS=$(ls -la "$USERPATH" | grep -Ewv "^total|\.|\.\.|$SKIPUSERS" | awk '{print $(NF-0)}')

RATIOLIST=""
for USER in $USERS; do
	USERLEECH=$(cat "$USERPATH/$USER" | grep -E "^RATIO 0")
	if [ -z "$USERLEECH" ]; then
		USERDELETED=$(cat "$USERPATH/$USER" | grep -E "^FLAGS" | grep "6")
		if [ -z "$USERDELETED" ]; then
			if [ -z "$RATIOLIST" ]; then
				RATIOLIST="$USER"
			else
				RATIOLIST="$RATIOLIST $USER"
			fi
		fi
	fi
done

RATIOLIST=$(echo $RATIOLIST | tr " " "\n" | sort -R)
NUMUSERS=$(echo "$RATIOLIST" | wc -l)

if [ "$NUMLOOP" -gt "$NUMUSERS" ]; then
	NUMLOOP="$NUMUSERS"
fi

echo "[RW] ($NUMLOOP OF $NUMUSERS) RANDOM REWARD!"

for (( i = 1; i <= $NUMLOOP; i++)); do
	RANDNUM=$(shuf -i 1-$NUMUSERS -n 1)
	REWARD=$(shuf -i $CREDITRANGE -n 1)
	REWARDUSER=$(echo "$RATIOLIST" | head -$RANDNUM | tail -1)
	CURRCRED=$(cat "$USERPATH/$REWARDUSER" | grep -E "^CREDITS" | awk '{print $2}' | awk '{print $1}')
	CURRMB=$(echo "scale=2; $CURRCRED /1024" | bc)
	CURRGB=$(echo "scale=2; $CURRMB /1024" | bc)
	NEWCRED=$(( $CURRCRED + $REWARD ))
	NEWMB=$(echo "scale=2; $NEWCRED /1024" | bc)
	NEWGB=$(echo "scale=2; $NEWMB /1024" | bc)
	REWARDMB=$(echo "scale=2; $REWARD /1024" | bc)
	REWARDGB=$(echo "scale=2; $REWARDMB /1024" | bc)
	# sed -e "s/^CREDITS.*/CREDITS $NEWCRED 0 0 0 0 0 0 0 0/" "$USERPATH/$REWARDUSER" > "$USERPATH/$REWARDUSER.reward"
	# mv -f "$USERPATH/$REWARDUSER.reward" "$USERPATH/$REWARDUSER"
	[ $i -lt 10 ] && p="0" || p="";
	echo "[RW] $p$i - `date "+%a %b %d %T %Y"` - ($RANDNUM/$NUMUSERS) $REWARDUSER - ${REWARDGB}GB [OLD ${CURRGB}GB/${CURRCRED}KB + NEW ${NEWGB}GB/${NEWCRED}KB]"
	echo "[RW] $p$i - `date "+%a %b %d %T %Y"` - ($RANDNUM/$NUMUSERS) $REWARDUSER - ${REWARDGB}GB [OLD ${CURRGB}GB/${CURRCRED}KB + NEW ${NEWGB}GB/${NEWCRED}KB]" >> $REWLOG
	# echo `date "+%a %b %d %T %Y"` REWARD: \"$REWARDUSER\" \"$REWARDMB\" >> $GLLOG
	RATIOLIST=$(echo "$RATIOLIST" | grep -wv "$REWARDUSER")
	NUMUSERS=$(( $NUMUSERS -1 ))
done

echo "-------------------------------------------------------------------------------" >> $REWLOG

# ./stats -u -m -x 100 -s 1 | grep -wv "0MB Unknown" | grep -E "^\[.*\]" | awk '{print $2}'
