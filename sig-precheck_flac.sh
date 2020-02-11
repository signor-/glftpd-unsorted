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

#FLAC DIR!

VERIFY_FLAC_WITH_SFV="TRUE"

ALLOWED="\.m3u$ \.nfo$ \.sfv$ \.jpg$ \.flac$ \.cue$"

BANNED="^5a\.nfo$ ^aks\.nfo$ ^atl\.nfo$ ^atlvcd\.nfo$ ^bar\.nfo$ ^cas\-pre\.jpg$ ^cmt\.nfo$ ^coke\.nfo$ ^dim\.nfo$ ^dkz\.nfo$ ^echobase\.nfo$ ^firesite\.nfo$ ^fireslut\.nfo$ ^ifk\.nfo$ ^lips\.nfo$ ^magfields\.nfo$ ^mfmfmfmf\.nfo$ ^mm\.nfo$ ^mob\.nfo$ ^mod\.nfo$ ^pbox\.nfo$ ^ph\.nfo$ ^pike\.nfo$ ^pre\.nfo$ ^release\.nfo$ ^sexy\.nfo$ ^tf\.nfo$ ^twh\.nfo$ ^valhalla\.nfo$ ^zn\.nfo$ ^imdb\.nfo$ ^vdrlake\.nfo$ ^dm\.nfo$ ^nud\.nfo$ ^thecasino\.nfo$ ^dtsiso21\.jpg$ ^dagger\.jpg$"

NODOUBLESFV="TRUE"
NOSAMENAME="TRUE"
NODOUBLENFO="TRUE"
NOFTPRUSHNFOS="TRUE"

DENY_WHEN_NO_SFV="\.flac$"

EXCLUDEDDIRS="/REQUESTS/ /ARCHIVE/ /ARCHIVE2/ /PRIVATE/ /FLAC/_PRE/ /STATS/ /SPEEDTEST/ /RULES/ /SORTED/"

#--[ Script Start ]--------------------------------#

if [ "$EXCLUDEDDIRS" ]; then
	EXCLUDEDDIRS=`echo "$EXCLUDEDDIRS" | tr -s ' ' '|'`
		if [ "`echo "$2" | egrep -i "$EXCLUDEDDIRS"`" ]; then
			exit 0
		fi
fi

case "$1" in

	*.[fF][lL][aA][cC])
		if [ "$VERIFY_FLAC_WITH_SFV" ]; then
			sfv_file="`ls -1 "$2" | grep -i "\.sfv$"`"
			if [ -z "$sfv_file" ]; then
				echo -e ".--------------------------------------------------."
				echo -e "| + You must upload .sfv first!                    |"
				echo -e "\`--------------------------------------------------'"
				exit 2
			else
				if [ -z "`grep -i "^$1\ " "$sfv_file"`" ]; then
					echo -e ".--------------------------------------------------."
					echo -e "| + File does not exist in sfv!                    |"
					echo -e "\`--------------------------------------------------'"
					exit 2
				fi
			fi
		fi
	;;

esac

if [ "$ALLOWED" ]; then
	ALLOWED=`echo "$ALLOWED" | tr -s ' ' '|'`
	if [ -z "`echo "$1" | egrep -i "$ALLOWED"`" ]; then
		echo -e ".--------------------------------------------------."
		echo -e "| + Invalid file extention. Skipping!              |"
		echo -e "\`--------------------------------------------------'"
		exit 2
	fi
fi

if [ "$DENY_WHEN_NO_SFV" ]; then
	DENY_WHEN_NO_SFV=`echo "$DENY_WHEN_NO_SFV" | tr -s ' ' '|'`
	if [ "`echo "$1" | egrep -i "$DENY_WHEN_NO_SFV"`" ]; then
		if [ -z "`ls -1 "$2" | grep -i "\.sfv$"`" ]; then
			echo -e ".--------------------------------------------------."
			echo -e "| + You must upload the .sfv file first!           |"
			echo -e "\`--------------------------------------------------'"
			exit 2
		fi
	fi
fi

if [ "$BANNED" ]; then
	BANNED=`echo "$BANNED" | tr -s ' ' '|'`
	if [ "`echo "$1" | egrep -i "$BANNED"`" ]; then
		echo -e ".--------------------------------------------------."
		echo -e "| + Banned filename. Add it to your skiplist!      |"
		echo -e "\`--------------------------------------------------'"
		exit 2
	fi
fi

if [ "$NOSAMENAME" = "TRUE" ]; then
	if [ "`ls -1 "$2" | grep -i "^$1$"`" ]; then
		if [ -z "`ls -1 "$2" | grep "^$1$"`" ]; then
			echo -e ".--------------------------------------------------."
			echo -e "| + File already exists with a different case!     |"
			echo -e "\`--------------------------------------------------'"
			exit 2
		fi
	fi
fi

if [ "$NODOUBLESFV" = "TRUE" ]; then
	if [ "`echo "$1" | grep -i "\.sfv$"`" ]; then
		if [ -e $2/*.[sS][fF][vV] ]; then
			echo -e ".--------------------------------------------------."
			echo -e "| + File .sfv already exists!                      |"
			echo -e "\`--------------------------------------------------'"
			exit 2
		fi
	fi
fi

if [ "$NODOUBLENFO" = "TRUE" ]; then
	if [ "`echo "$1" | grep "\.[nN][fF][oO]$"`" ]; then
		if [ -e $2/*.[nN][fF][oO] ]; then
			echo -e ".--------------------------------------------------."
			echo -e "| + File .nfo already exists!                      |"
			echo -e "\`--------------------------------------------------'"
			exit 2
		fi
	fi
fi

if [ "$NOFTPRUSHNFOS" = "TRUE" ]; then
	if [ "`echo "$1" | grep "\.[nN][fF][oO]$"`" ]; then
		if [ "`echo "$1" | grep "([0-9].*)\.[nN][fF][oO]$"`" ]; then
			echo -e ".--------------------------------------------------."
			echo -e "| + Invalid nfo file format!                       |"
			echo -e "\`--------------------------------------------------'"
			exit 2      
		fi
	fi
fi

exit 0

