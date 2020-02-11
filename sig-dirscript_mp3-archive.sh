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
# original script by jehsom - modded by signor

NOCHECK_TREES="/site/REQUESTS/ /site/STAFF/ /site/SPEEDTEST/"
DAYSBACK="5"
#ALLOWINTERNAL, 0 = DISALLOW, 1 = ALLOW
ALLOWINTERNAL="1"
BANNEDGRP=""
BANNEDSOURCE="RADIO LINE CABLE DAB DAT SBD SAT FM DVB DVBC DVBS DVBT"
BANNEDLANG=""
#BANNEDLANG="AF AM AR ARA AU BA BHANGRA BE BG BR BZH BY CH CI CO COR CPOP CRO CV CZ DE DK DU DZ EE EH EP ES FI FR GER GN GP GR HE HEB HI HL HR HU HT IL IN IS IT JP JPOP KPOP KR KYA LB LT MA ML MY NE NL NO NU PL PT PU RK RO RU SD SI SK SP SPA TL TR TURK TV TZ UA YU GH"
ANALDUPECHECK="0"
DATAPATH="/ftp-data"
ALLOWPARENS="0"
RIAA_UNDERSCORES="0"
RIAA_NAMELENGTH="0"
#ALLOWED_YEARS="1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010"
ALLOWED_YEARS=""
LOGFILE="/ftp-data/logs/dirscript.log"
LIVE_OK="0"

AFFILS=""
PRE_DIRS=""
#######################
### Ignore the rest ###
#######################

BINS="date expr ls"

function logexit () {
	echo "`date +%Y-%m-%d`: Denied $1 to user $USER ($2)" >> $LOGFILE
	exit 2
}

[ -w /dev/null ] || { echo "/dev/null must be writable. Exiting."; exit 0; }

for bin in $BINS; do 
    type $bin > /dev/null 2>&1 || {
        echo "The '$bin' binary must be installed in glftpd's bin dir."
        logexit $2/$1 "Required bin not found"
    }
done

# If we're in an excepted directory tree, allow the dir without checking it
for tree in $NOCHECK_TREES; do
	case $2 in
	    ${tree}*)
		exit 0
		;;
	    *)
		;;
	esac
done

# If the dir already exists, it's obviously not right to create it
[ -d "$2/$1" ] && {
        echo ".--------------------------------------------------."
	echo "| + Directory already exists!                      |"
	echo ".--------------------------------------------------'"
	logexit $2/$1 "Dir Already Existing"
}	

for predir in $PRE_DIRS; do
	[ -d "$predir/$1" ] && {
        echo ".--------------------------------------------------."
	echo "| + Release already exists in groups predir!       |"
	echo ".--------------------------------------------------'"
		logexit $2/$1 "About to be pre'd"
	}
done	

[ "$ALLOWINTERNAL" = "0" ] && {
	echo $1 | egrep -i "_INT$" > /dev/null && {
        echo ".--------------------------------------------------."
	echo "| + Internal releases not allowed here!            |"
	echo ".--------------------------------------------------'"
	logexit $2/$1 "Internal releases not allowed"
	}
}


# Make sure name is <= 64 chars
[ "$RIAA_NAMELENGTH" = "1" ] && {
	[ "${#1}" -gt "64" ] && {
        echo ".--------------------------------------------------."
	echo "| + Directoy doesn't follow RIAA conventions!      |"
	echo "| + The name should be 64 characters or less!      |"
	echo ".--------------------------------------------------'"
		logexit $2/$1 "Name too long"
	}
}

# Check for RIAA naming compliance
[ "$RIAA_UNDERSCORES" = "1" ] && {
	echo $1 | grep -E "^[^_]+\.[^_]+\.[^_]+\.[^_]*$" | grep "[-]-" > /dev/null && {
        echo ".--------------------------------------------------."
	echo "| + Directoy doesn't follow RIAA conventions!      |"
	echo "| + Underscores, not periods must be used!         |"
	echo ".--------------------------------------------------'"
	logexit $2/$1 "Name not RIAA conformant"
	}
}

# Disallow banned groups.
[ -n "$2" ] && cd $2
for grp in $BANNEDGRP; do
	echo $1 | egrep -i "[-](${grp}$|${grp}_INT$)" > /dev/null && {
        echo ".--------------------------------------------------."
	echo "| + ${grp} releases are not accepted here!         |"
	echo ".--------------------------------------------------'"
	logexit $2/$1 "Unallowed Group"
	}
done

# Disallow upload of affil groups.               
[ -n "$2" ] && cd $2
for grp in $AFFILS; do
        echo $1 | egrep -i "[-](${grp}$|${grp}_INT$)" > /dev/null && {
        echo ".--------------------------------------------------."
	echo "| + ${grp} is an affil group, DONT race affils!    |"
	echo ".--------------------------------------------------'"
    logexit $2/$1 "Tried to race Affil Group"
        }         
done            

# Disallow banned source.
[ -n "$2" ] && cd $2
for source in $BANNEDSOURCE; do
	echo $1 | grep -i "[-]${source}[-]" > /dev/null && {
        echo ".--------------------------------------------------."
	echo "| + ${source} releases are not accepted here!      |"
	echo ".--------------------------------------------------'"
	logexit $2/$1 "Unallowed source"
	}
done

# Disallow banned languages.
[ -n "$2" ] && cd $2
for lang in $BANNEDLANG; do
	echo $1 | grep -i "[-]${lang}[-]" > /dev/null && {
        echo ".--------------------------------------------------."
	echo "| + ${lang} releases are not accepted here!        |"
	echo ".--------------------------------------------------'"
	logexit $2/$1 "Unallowed Language"
	}
done

# Check against dupelog
[ "$ANALDUPECHECK" = "1" ] && {
	# Don't check if it's a "CD1" or similar dir
	{ [ ${#1} -le 8 ] && echo $1 | grep -iE "^(cd[1-9]|sample)" > /dev/null; } || {
		if [ -f $DATAPATH/logs/dupelog ]; then
			grep -i " $1$" $DATAPATH/logs/dupelog > /dev/null && {
			echo "Dupe detected! SITE DUPE $1 returns:"
			grep -i " $1$" $DATAPATH/logs/dupelog | head -10
			logexit $2/$1 "Dupe"
    		}
	   	else
		echo 'Could not locate dupelog for anal dupechecking!'
		echo "Verify your DATAPATH setting and try again."
    	fi
	}	
}

# Check that the rls has a required year in the name, unless
# it's an affil, in which case we forget about it.
[ -n "$ALLOWED_YEARS" ] && {
	yearok="0"; shortname="0"
	echo $1 | grep -Ei "[-](`echo $AFFILS | sed 's/ /|/g'`)$" > /dev/null && 
		yearok=1
	[ ${#1} -le 8 ] || echo $1 | grep -iE "^(cd[1-9]|.*approved)" > /dev/null &&
		shortname="1"
	for year in $ALLOWED_YEARS; do
		echo $1 | grep -E "(${year}|[-\.]${year#??}\b|\b${year#??}[-\.]|\b${year#??}[0-9]{4}\b|\b[0-9]{4}${year#??}\b)" > /dev/null && 
			yearok="1"
	done
	[ "$yearok" = "0" -a "$shortname" = "0" ] && {
        echo ".--------------------------------------------------."
	echo "| + Unallowed year!                                |"
	echo ".--------------------------------------------------'"
	logexit $2/$1 "Unallowed Year"
    }
}

{ [ "$LIVE_OK" -eq "1" ] || 
	echo $1 | grep -Ei "[-](`echo $AFFILS | sed 's/ /|/g'`)$" > /dev/null; } || {
	echo $1 | grep -Ei "([(]live[)]|[-_.]live[_.](in|at|on)[^[:alpha:]]|[0-9][0-9][-_.][0-9][0-9][-_.][0-9][0-9])" > /dev/null && {
		echo "Live releases not allowed."
		logexit $2/$1 "Live"
	}
}	

ago=0
# force year OK! no check
yearok="0"
shortname="0"

[ "$shortname" = "0" ] && while [ $ago -le $DAYSBACK ]; do
	date=`date --date "$ago days ago" +%Y-%m-%d`
	ls ../$date 2>/dev/null | grep -i "\b$1\b" > /dev/null 2>&1 && {
        echo ".--------------------------------------------------."
	echo "| + \"$1\" already exists in the                   |"
	echo "| directory dated $date. Looks like a dupe!   |"
	echo ".--------------------------------------------------'"
	logexit $2/$1 "In recent dated dir"
	}
	ago=$(($ago + 1))
done
exit 0


