#! /bin/bash
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
# this script was modified from original by mRmiSta 2010 for deeper dir structure filtering.
#

# Put the full path to metaflac here if it's not in your $PATH.
flacinfo=`which metaflac 2>/dev/null`  

# Wildcard expressions that match the names of all your release dirs.
# Edit these according to the way your site is set.
RLS_DIRS="
/glftpd/site/ARCHIVE/FLAC/[0-9][0-9][0-9][0-9]/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/* 
"

# Where do you want the link trees to go? Set to "" or comment out to disable.
# Note: These dirs need to exist if you intend to use them.
# the dir structure is as follows.
#BY.ARTIST/C/Cannibal_Corpse/Cannibal_Corpse-Kill-Promo-2006-AMRC
#BY.GENRE/Death_Metal/C/Cannibal_Corpse/Cannibal_Corpse-Kill-Promo-2006-AMRC
#BY.GROUP/AMRC/C/Cannibal_Corpse/Cannibal_Corpse-Kill-Promo-2006-AMRC
#BY.YEAR/2006/C/Cannibal_Corpse/Cannibal_Corpse-Kill-Promo-2006-AMRC

ARTIST_DIR="/glftpd/site/ARCHIVE/SORTED/FLAC/BY_ARTIST"
GENRE_DIR="/glftpd/site/ARCHIVE/SORTED/FLAC/BY_GENRE"
GROUP_DIR="/glftpd/site/ARCHIVE/SORTED/FLAC/BY_GROUP"
YEAR_DIR="/glftpd/site/ARCHIVE/SORTED/FLAC/BY_YEAR"

#####################################################
############## You can ignore the rest ##############
#####################################################

function get_metaflac_path () {
        if [ -n $metaflac ]; then
                if [ -f /usr/local/bin/metaflac ]; then
                        metaflac="/usr/local/bin/metaflac"
                else
                        if [ -f /usr/bin/metaflac ]; then
                                metaflac="/usr/bin/metaflac"
                        else
                                if [ -f /bin/metaflac ]; then
                                        metaflac="/bin/metaflac"
                                else
                                        if [ -f /glftpd/bin/metaflac ]; then
                                                metaflac="/glftpd/bin/metaflac"
                                        else
                                                if [ -f /jail/glftpd/bin/metaflac ]; then
                                                        metaflac="/jail/glftpd/bin/metaflac"
                                                fi
                                        fi
                                fi
                        fi
                fi
        fi
}

#####################################################

function correct_case () { 
	IFS="_"
	fullstring=""
	for i in $1; do
		i=`echo $i | tr -d "."`
		case $i in
                    [Ff][Tt]|[Ff][Ee][Aa][Tt]|[Ff][Ee][Aa][Tt][Uu][Rr][Ii][Nn][Gg]) i="ft";;
                    [Vv]|[Vv][Ss]|[Vv][Ee][Rr][Ss][Uu][Ss]) i="vs";;
		[Vv][Aa]|[Vv][.-_][Aa][.-_]|[Vv][Aa][Rr][Ii][Oo][Uu][Ss][.-_][Aa][Rr][Tt][Ii][Ss][Tt][Ss]) i="va";;
                esac
		uprcase=`echo "${i:0:1}" | tr "[:lower:]" "[:upper:]"`;
		lwrcase=`echo "${i:1}" | tr "[:upper:]" "[:lower:]"`;
		fullstring=`echo ${fullstring} ${uprcase}${lwrcase} | tr ' ' '_'`
	done
	echo "$fullstring"              
} 

#####################################################

function link_artist () {
    cd "$1" || return 1
    rlsdir="$PWD"
    base="$(basename "$PWD")"

    sortable="${base#(}"
    case $sortable in
        *[Nn][Uu][Kk][Ee][Dd]*)
            return 0
            ;;
        *[Ii][Nn][Cc][Oo][Mm][Pp][Ll][Ee][Tt][Ee]*)
            return 0
            ;;
		*[Nn][Oo]*[Nn][Ff][Oo]*)
            return 0
            ;;
		*[Nn][Oo]*[Ss][Ff][Vv]*)
            return 0
            ;;
        [vV][aA][-_.]*|[vV]arious[-_.]*|[vV][.-_][aA][.-_]*)
            letter="Various"
            ;;
        *)
            letter=$(echo ${base%${base#?}} | tr '[:lower:]' '[:upper:]')
            ;;
    esac

    artist=`echo $base | grep -e '[-].*[-]' | awk -F'[-].*[-]' '{print $1}' | sed 's/[_\t]*$//'`
    artist=$(correct_case "$artist")

    [ -d "$ARTIST_DIR/$letter/$artist" ] || mkdir -p -m755 "$ARTIST_DIR/$letter/$artist"

    oIFS="$IFS" IFS="/" relpath=
    set -- $rlsdir
    for seg in $ARTIST_DIR; do
        case $relpath$seg in
             "$1") shift ;;
            *) relpath=../$relpath ;;
        esac
    done
    relpath="../../$relpath$*" IFS="$oIFS"
    IFS="$oIFS"
    if [ ! -e "$ARTIST_DIR/$letter/$artist/$base" ]; then
    	ln -s "$relpath/" "$ARTIST_DIR/$letter/$artist/$base"
    fi
    cd -
}

#####################################################

function link_year () {
    cd "$1" || return 1
    rlsdir="$PWD"
    base="$(basename "$PWD")"
    sortable="${base#(}"
    case $sortable in
        *[Nn][Uu][Kk][Ee][Dd]*)
            return 0
            ;;
        *[Ii][Nn][Cc][Oo][Mm][Pp][Ll][Ee][Tt][Ee]*)
            return 0
            ;;
		*[Nn][Oo]*[Nn][Ff][Oo]*)
            return 0
            ;;
		*[Nn][Oo]*[Ss][Ff][Vv]*)
            return 0
            ;;
    esac

    artist=`echo $base | grep -e '[-].*[-]' | awk -F'[-].*[-]' '{print $1}' | sed 's/[_\t]*$//'`
    artist=$(correct_case "$artist")
    letter=$(echo ${base%${base#?}} | tr '[:lower:]' '[:upper:]')

    flac="$(echo *.[Ff][Ll][Aa][Cc] */*.[Ff][Ll][Aa][Cc] | cut -f1 -d ' ')"
    [ -f "$flac" ] || return 1
    year=$($flacinfo --show-tag=DATE $flac | awk -F"=" '{print $2}' | tr -d '[:punct:]' | tr ' ' '_')
    [ -z "$year" ] && year="0000"

    [ -d "$YEAR_DIR/$year/$letter/$artist" ] || mkdir -p -m755 "$YEAR_DIR/$year/$letter/$artist"

    oIFS="$IFS" IFS="/" relpath=
    set -- $rlsdir
    for seg in $YEAR_DIR; do
        case $relpath$seg in
             "$1") shift ;;
            *) relpath=../$relpath ;;
        esac
    done
    relpath="../../../$relpath$*" IFS="$oIFS"
    IFS="$oIFS"
    if [ ! -e "$YEAR_DIR/$year/$letter/$artist/$base" ]; then
    	ln -s "$relpath/" "$YEAR_DIR/$year/$letter/$artist/$base"
    fi
    cd -
}

#####################################################

function link_genre () {
    cd "$1" || return 1
    rlsdir="$PWD"
    base="$(basename "$PWD")"
    case $base in
        *[Nn][Uu][Kk][Ee][Dd]*)
            return 0
            ;;
        *[Ii][Nn][Cc][Oo][Mm][Pp][Ll][Ee][Tt][Ee]*)
            return 0
            ;;
		*[Nn][Oo]*[Nn][Ff][Oo]*)
            return 0
            ;;
		*[Nn][Oo]*[Ss][Ff][Vv]*)
            return 0
            ;;
	esac

    artist=`echo $base | grep -e '[-].*[-]' | awk -F'[-].*[-]' '{print $1}' | sed 's/[_\t]*$//'`
    artist=$(correct_case "$artist")
    letter=$(echo ${base%${base#?}} | tr '[:lower:]' '[:upper:]')

	# metaflac --show-tag=GENRE /glftpd/site/FLAC/2011-11-09/Hedley-Storms-CD-FLAC-2011-PERFECT/04-hedley-we_are_unbreakable.flac | awk -F"=" '{print $2}'
	# Rock
	
    flac="$(echo *.[Ff][Ll][Aa][Cc] */*.[Ff][Ll][Aa][Cc] | cut -f1 -d ' ')"
    [ -f "$flac" ] || return 1
    genre=$($flacinfo --show-tag=GENRE $flac | awk -F"=" '{print $2}' | tr -d '[:punct:]' | tr ' ' '_')
    genre=$(correct_case "$genre")
    [ -z "$genre" ] && genre="Unknown"

    [ -d "$GENRE_DIR/$genre/$letter/$artist" ] || mkdir -p -m755 "$GENRE_DIR/$genre/$letter/$artist"
    
    oIFS="$IFS" IFS="/" relpath=
    set -- $rlsdir
    for seg in $GENRE_DIR; do
        case $relpath$seg in
             "$1") shift ;;
            *) relpath=../$relpath ;;
        esac 
    done     
    relpath="../../../$relpath$*" IFS="$oIFS"
    IFS="$oIFS"

    # A condition added by eur0dance
    if [ ! -e "$GENRE_DIR/$genre/$letter/$artist/$base" ]; then
    	ln -s "$relpath/" "$GENRE_DIR/$genre/$letter/$artist/$base"
    fi
    cd -
}

#####################################################

function link_group () {
    cd "$1" || return 1
    rlsdir="$PWD"
    base="$(basename "$PWD")"
    case $base in
        *[Nn][Uu][Kk][Ee][Dd]*)
            return 0
            ;;
        *[Ii][Nn][Cc][Oo][Mm][Pp][Ll][Ee][Tt][Ee]*)
            return 0
            ;;
		*[Nn][Oo]*[Nn][Ff][Oo]*)
            return 0
            ;;
		*[Nn][Oo]*[Ss][Ff][Vv]*)
            return 0
            ;;
        *)
            group=$(echo "${base##*-}" | tr '[:lower:]' '[:upper:]')
            group=`echo $group | awk -F'[_]' '{print $(NF-1)}'`
            artist=`echo $base | grep -e '[-].*[-]' | awk -F'[-].*[-]' '{print $1}' | sed 's/[_\t]*$//'`
            artist=$(correct_case "$artist")
            letter=$(echo ${base%${base#?}} | tr '[:lower:]' '[:upper:]')
            ;;
    esac

    [ ${#group} -gt 15 ] && return 0

    [ -d "$GROUP_DIR/$group/$letter/$artist" ] || mkdir -p -m755 "$GROUP_DIR/$group/$letter/$artist"

    oIFS="$IFS" IFS="/" relpath=
    set -- $rlsdir
    for seg in $GROUP_DIR; do
        case $relpath$seg in
             "$1") shift ;;
            *) relpath=../$relpath ;;
        esac
    done
    relpath="../../../$relpath$*" IFS="$oIFS"
    IFS="$oIFS"
    
    # A condition added by eur0dance
    if [ ! -e "$GROUP_DIR/$group/$letter/$artist/$base" ]; then
    	ln -s "$relpath/" "$GROUP_DIR/$group/$letter/$artist/$base"
    fi
    cd -
}

#####################################################

function check_dead_links () {
	echo "checking dead symlinks for "$1" please wait..."
	find "$1" -type l | (while read FN ; do test -e "$FN" || ls -ld "$FN"; done) | while read LINE
	do
		bad_sym_link=`echo $LINE | awk '{print $8}'`
		rm "$bad_sym_link"
		echo "found bad symlink $bad_sym_link"
	done
}

#####################################################
#### Main program body ****
#####################################################

allow_null_glob_expansion=1
shopt -s nullglob 2>/dev/null

get_metaflac_path

{ [ -n "$metaflac" ] && $metaflac --help 2>/dev/null | grep "metaflac - Command-line FLAC metadata editor version" > /dev/null; } || {
    echo "Your metaflac binary is missing or incorrect. Exiting." 1>&2
    exit 0
}

for i in ARTIST GENRE GROUP YEAR; do
    if eval [ -d "\"\$${i}_DIR\"" -a -x "\"\$${i}_DIR\"" ]; then
        eval cd \"\$${i}_DIR\"
        eval ${i}_DIR="$PWD"
    else
        eval [ -n \"\$${i}_DIR\" ] &&
            echo "Your ${i}_DIR is invalid. Skipping $i links." 1>&2
        eval ${i}_DIR=""
    fi
done

{ [ -z "$ARTIST_DIR" ] && [ -z "$GENRE_DIR" ] && [ -z "$GROUP_DIR" ] && [ -z "$YEAR_DIR" ]; } &&
    exit 1

#echo `date "+%a %b %d %T %Y"` SORTED: \"FLAC\" >> /glftpd/ftp-data/logs/glftpd.log  

check_dead_links "$ARTIST_DIR"
check_dead_links "$GENRE_DIR"
check_dead_links "$GROUP_DIR"
check_dead_links "$YEAR_DIR"

for i in $RLS_DIRS; do
	[ -d "$i" -a -x "$i" ] || continue
        [ -n "$ARTIST_DIR" ] && link_artist "$i"
        [ -n "$GENRE_DIR" ] && link_genre "$i"
	[ -n "$GROUP_DIR" ] && link_group "$i"
	[ -n "$YEAR_DIR" ] && link_year "$i"
done

exit 0


