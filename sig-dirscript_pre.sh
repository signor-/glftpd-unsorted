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

# check to make sure dirname is 128 characters or less, 1 = on, 0 = off
NAMELENGTH=1

FORCEALLOWEDSUBDIRS="1"
# /site/<SECTION>/_PRE/<GROUP>/<RELEASE>, reldir is #5 in the list.
RELDIRNUMBER="5"
# /site/<SECTION>/_PRE/<GROUP>/<RELEASE>/<SUBDIR>, subdir is #6 in the list.
SUBDIRNUMBER="6"
ALLOWEDSUBDIRS="SUBS SAMPLE PROOF"
FORCESUBDIRCASE="YES"

GLLOGFILE="/ftp-data/logs/glftpd.log"
##############################################################

BINS="date expr ls"

PREGROUP=$(echo $2 | awk -F/ '{print $(NF-0)}')

function correct_case () { 
	IFS="_"
	fullstring=""
	for i in $1; do
		uprcase=`echo "${i:0:1}" | tr "[:lower:]" "[:upper:]"`;
		lwrcase=`echo "${i:1}" | tr "[:upper:]" "[:lower:]"`;
		fullstring=`echo ${fullstring} ${uprcase}${lwrcase} | tr ' ' '_'`
	done
	echo "$fullstring"              
} 

function logexit () {
	#echo "`date +%Y-%m-%d`: Denied $1 to user $USER ($2)" >> $LOGFILE
	exit 2
}

[ -w /dev/null ] || { echo "/dev/null must be writable. Exiting."; exit 0; }

for bin in $BINS; do 
    type $bin > /dev/null 2>&1 || {
        echo "The '$bin' binary must be installed in glftpd's bin dir."
        logexit $2/$1 "Required bin not found"
    }
done

##############################################################

# if the dir already exists, it's obviously not right to create it
[ -d "$2/$1" ] && {
	echo ".--------------------------------------------------."
	echo "| + Directory already exists!                      |"
	echo ".--------------------------------------------------'"
	logexit $2/$1 "Dir Already Existing"
}	

# check to make sure its an allowed group variation
[ -n "$2" ] && cd $2
RELDIRSEC=$(echo $PWD | cut -d/ -f3) # should contain the site section of MKD path, eg MP3 or FLAC or MVID
RELDIRPWD=$(echo $PWD | sed 's/\//\n/g' | wc -l) # counts path to make sure were in the correct directory
[ "$RELDIRPWD" = "$RELDIRNUMBER" ] && {
	echo $1 | egrep -i "[-](${PREGROUP}$|${PREGROUP}_INT$|${PREGROUP}X$|${PREGROUP}X_INT$|${PREGROUP}[-_]WEB$|${PREGROUP}[-_]WEB_INT$|${PREGROUP}LIVE|${PREGROUP}LIVE_INT)" > /dev/null || {
		echo ".--------------------------------------------------."
		echo "| + The directory is not a group pre release!      |"
		echo "|                                                  |"
		echo "|   Group name and variations allowed are...       |"
		echo "|   -GROUP                                         |"
		echo "|   -GROUP_INT                                     |"
		echo "|   -GROUPx                                        |"		
		echo "|   -GROUPx_INT                                    |"
		echo "|   -GROUP_WEB                                     |"
		echo "|   -GROUP_WEB_INT                                 |"		
                echo "|   -GROUPLIVE                                     |"
                echo "|   -GROUPLIVE_INT                                 |"
		echo "|     (all group checks are case insensitivte)     |"
		echo ".--------------------------------------------------'"
		logexit $2/$1 "Group name variation check failed"
	}
# deny -FLAC- and -x264- uploads in MP3 pre dir
	[ "$RELDIRSEC" == "MP3" ] && {
		echo $1 | egrep -i "[-](FLAC|x264)[-]" > /dev/null && {
			echo ".--------------------------------------------------."
			echo "| + This is NOT a MP3 release!                     |"
			echo ".--------------------------------------------------'"
			logexit $2/$1 "Tried FLAC MKD in MP3 section"
		}
	}
# make sure FLAC MKD has FLAC in the dirname for pre dir section FLAC
	[ "$RELDIRSEC" == "FLAC" ] && {
		echo $1 | egrep -i "[-]FLAC[-]" > /dev/null || {
			echo ".--------------------------------------------------."
			echo "| + This is NOT a FLAC release!                    |"
			echo ".--------------------------------------------------'"
			logexit $2/$1 "Missing -FLAC- in dir name in FLAC section"
		}
	}
# make sure MVID MKD has x264 in the dirname for pre dir section MVID
	[ "$RELDIRSEC" == "MVID" ] && {
		echo $1 | egrep -i "[-]x264[-]" > /dev/null || {
			echo ".--------------------------------------------------."
			echo "| + This is NOT a MVID release!                    |"
			echo ".--------------------------------------------------'"
			logexit $2/$1 "Missing -FLAC- in dir name in FLAC section"
		}
	}
}
##############################################################

# Make sure name is <= 64 chars
[ "$NAMELENGTH" = "1" ] && {
	[ "${#1}" -gt "128" ] && {
	echo ".--------------------------------------------------."
	echo "| + The directory name is too long! (128 char max) |"
	echo ".--------------------------------------------------'"
		logexit $2/$1 "Directory name too long"
	}
}

##############################################################

[ "$FORCEALLOWEDSUBDIRS" = "1" ] && {
	RELDIRPWD=$(echo $PWD | sed 's/\//\n/g' | wc -l)
	[ "$RELDIRPWD" = "$SUBDIRNUMBER" ] && {
		BADSUBDIR=$(echo $1 | grep -Ei "(`echo $ALLOWEDSUBDIRS | sed 's/ /|/g'`)$")
		[ $BADSUBDIR ] || {
		echo ".--------------------------------------------------."
		echo "| + ${1} is not a valid sub directory!"
		echo "| + valid subdirs are ${ALLOWEDSUBDIRS}."
		echo ".--------------------------------------------------'"
		logexit $2/$1 "Invalid Sub Directory"
		}
	}
}

##############################################################

if [ "$FORCESUBDIRCASE" = "YES" ]; then
	BEDIR=$(echo $1)
	case $1 in
		[Cc][Dd][0-9]*)
			SUBDIRCASE="U"
			[ "$SUBDIRCASE" == "C" ] && CHDIR=`correct_case $1`
			[ "$SUBDIRCASE" == "U" ] && CHDIR=$(echo $1 | tr '[:lower:]' '[:upper:]')
			[ "$SUBDIRCASE" == "L" ] && CHDIR=$(echo $1 | tr '[:upper:]' '[:lower:]')
		;;
		[Pp][Rr][Oo][Oo][Ff]*)
			SUBDIRCASE="C"
			[ "$SUBDIRCASE" == "C" ] && CHDIR=`correct_case $1`
			[ "$SUBDIRCASE" == "U" ] && CHDIR=$(echo $1 | tr '[:lower:]' '[:upper:]')
			[ "$SUBDIRCASE" == "L" ] && CHDIR=$(echo $1 | tr '[:upper:]' '[:lower:]')
		;;
		[Ss][Uu][Bb]*)
			SUBDIRCASE="C"
			[ "$SUBDIRCASE" == "C" ] && CHDIR=`correct_case $1`
			[ "$SUBDIRCASE" == "U" ] && CHDIR=$(echo $1 | tr '[:lower:]' '[:upper:]')
			[ "$SUBDIRCASE" == "L" ] && CHDIR=$(echo $1 | tr '[:upper:]' '[:lower:]')
		;;
		[Ss][Aa][Mm][Pp][Ll][Ee]*)
			SUBDIRCASE="C"
			[ "$SUBDIRCASE" == "C" ] && CHDIR=`correct_case $1`
			[ "$SUBDIRCASE" == "U" ] && CHDIR=$(echo $1 | tr '[:lower:]' '[:upper:]')
			[ "$SUBDIRCASE" == "L" ] && CHDIR=$(echo $1 | tr '[:upper:]' '[:lower:]')
		;;
		[Mm]2[Tt][Ss]*)
			SUBDIRCASE="U"
			[ "$SUBDIRCASE" == "C" ] && CHDIR=`correct_case $1`
			[ "$SUBDIRCASE" == "U" ] && CHDIR=$(echo $1 | tr '[:lower:]' '[:upper:]')
			[ "$SUBDIRCASE" == "L" ] && CHDIR=$(echo $1 | tr '[:upper:]' '[:lower:]')
		;;
		*)
			CHDIR=$(echo $1)
		;;
	esac

	if [ "$BEDIR" != "$CHDIR" ]; then
		mkdir $2/$CHDIR
		echo `date +"%a %b %d %T %Y"` NEWDIR: \"$2/$CHDIR\" \"$USER\" \"$GROUP\" \"$TAGLINE\" >> $GLLOGFILE
		echo ".--------------------------------------------------."
		echo "| + Sub Dir Invalid Case, Using $CHDIR instead."
		[ -d "$2/$CHDIR" ] && echo "| + MKD $CHDIR Successful."
		echo ".--------------------------------------------------."
		logexit $2/$1 "Changed Directory Case"
	fi
	
fi
##############################################################
exit 0



