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
# custom nuke script (replacement)
###############################################################################
#site_cmd NUKE          EXEC    /bin/sig-nuke.sh NUKE
#custom-nuke !8 1A
#site_cmd UNNUKE          EXEC    /bin/sig-nuke.sh UNNUKE
#custom-unnuke !8 1B
###############################################################################
#site root
SITEROOT="/site"
# nuke binary
NUKER="/bin/nuker"
# nuke user
NUKEUSER=$USER
# bogus.conf location (for use in chroot environment)
GLCONF="/etc/bogus.conf"
# glftpd.log location
GLLOG="/ftp-data/logs/glftpd.log"
# bad words
BADWORDS="cunt dick dickhead fail failure fuck fucking idiot tool wanker"
# replace dot with underscore and white space with dot?
REPLACE="YES"
# nuke directory tag
NUKETAG="(nuked)-"
###############################################################################
# (17:50:34) [1] site nuke Rmak_and_Kema_Mc-Super_Heros-WEB-FR-2013-K0K 3 release still incomplete
# (17:50:34) [1] 200- NUKE Rmak_and_Kema_Mc-Super_Heros-WEB-FR-2013-K0K 3 release still incomplete

umask 000

ACTION=$(echo $@ | awk -F" " '{print $1}' | tr [:upper:] [:lower:])
RELEASE=$( echo $@ | awk -F" " '{print $2}')

if [ -z $RELEASE ]; then
	echo "site NUKE <RELEASE> <multiplier> <reason>"
	exit 0
fi

function check_bad_words () {
	for WORD in $BADWORDS; do
		echo $@ | grep -wi "${WORD}" > /dev/null && {
		echo "BADWORD: Reason Contains Bad Word \"$WORD\", Exiting"
		exit 0
		}
	done
}

if [ -d "$PWD/$RELEASE" ] || [ -d "$PWD/$NUKETAG$RELEASE" ]; then
	case $ACTION in
		nuke)
			# site nuke Rmak_and_Kema_Mc-Super_Heros-WEB-FR-2013-K0K 3 release incomplete username SITEOP
			MULTIPLIER=$(echo $@ | awk -F" " '{print $3}')
			if [ -z $MULTIPLIER ]; then
				echo "site NUKE <release> <MULTIPLIER> <reason>"
				exit 0
			fi
			check_bad_words $(echo $@ | cut -d' ' -f4-)
			if [ "$REPLACE" == "YES" ]; then
				REASON=$(echo $@ | cut -d' ' -f4- | tr "." "_" | tr " " "." | sed 's#\_\.#\_#')
			else
				REASON=$(echo $@ | cut -d' ' -f4-)
			fi
			if [ -z "$REASON" ]; then
				echo "site NUKE <release> <multiplier> <REASON>"
				exit 0
			fi
			$NUKER -r $GLCONF -N $NUKEUSER -n {$PWD/$RELEASE} $MULTIPLIER $REASON
			# echo "$RELEASE: Successfully Nuked ($REASON) $USER"
			exit 0
			;;
		unnuke)
			# site unnuke Rmak_and_Kema_Mc-Super_Heros-WEB-FR-2013-K0K release complete username SITEOP
			check_bad_words $(echo $@ | cut -d' ' -f3-)
			if [ "$REPLACE" == "YES" ]; then
				REASON=$(echo $@ | cut -d' ' -f3- | tr "." "_" | tr " " "." | sed 's#\_\.#\_#')
			else
				REASON=$(echo $@ | cut -d' ' -f3-)
			fi
			if [ -z "$REASON" ]; then
				echo "site NUKE <release> <REASON>"
				exit 0
			fi
			$NUKER -r $GLCONF -N $NUKEUSER -u {$PWD/$RELEASE} $REASON
			# echo "$RELEASE: Successfully Unnuked ($REASON) $USER"
			exit 0
			;;
	esac
else
	echo "ERROR: Invalid Directory"
	exit 0
fi
