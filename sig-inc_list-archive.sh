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

gl_root="/glftpd"
site_root="/site"
inc_dir="/ARCHIVE/INCOMPLETE"
inc_labels="
(incomplete)-
(no-sfv)-
(no-nfo)-
"
nuker_bin="/glftpd/bin/nuker"

# nuke_limit must be in minutes!
nuke_limit="180"
nuke_user="XXX"

function delete_links () {
        echo "deleting current symlinks for "$1" please wait..."              
		rm -rf $1/*
}

function find_inc_links () {
        cd $gl_root$site_root
        echo "checking incomplete symlinks for "$1" please wait..."
		for cur_label in $inc_labels; do
			find "$1" -type l -name "$cur_label*" -regextype posix-egrep -regex ".*/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/.*" | while read LINE
			do
					inc_sym_link=`echo $LINE`
					real_dir=`echo $inc_sym_link | sed 's/'$cur_label'//g;'`
#					nuke_it "$real_dir" "$inc_sym_link"
					real_dir=${real_dir#$gl_root$site_root}
					inc_release=`basename $real_dir`
					inc_sym_dir=`basename $inc_sym_link`
					inc_section=`basename $1`
					if [ ! -d "$gl_root$site_root$inc_dir/$inc_section" ]; then
							mkdir -m777 -p "$gl_root$site_root$inc_dir/$inc_section"
					fi
									if [ ! -e "$gl_root$site_root$inc_dir/$inc_section/$inc_release" ]; then
											ln -s "../../..$real_dir" "$gl_root$site_root$inc_dir/$inc_section/$inc_release"
											echo "found $cur_label release $real_dir"
									fi
			done
		done
}

function nuke_it () {
		if [ -d "$1" ]; then
			currtime=`date --date "now" +"%Y-%m-%d %T"`
			datetime=`stat -c %y "$1" | awk -F. '{print $1}'`
			nukeelapsed=`echo $"(( $(date --date="$currtime" +%s) - $(date --date="$datetime" +%s) ))/60" | bc`
			nukepath=${1#$gl_root$site_root}
			if [ "$nukeelapsed" -gt "$nuke_limit" ]; then
				$nuker_bin -N $nuke_user -n "$site_root$nukepath" 3 auto.nuke_still.incomplete.after.$nukeelapsed.minutes_limit.is.$nuke_limit.minutes.old
				rm -f "$2"
			fi
		fi
}

delete_links "/glftpd/site/ARCHIVE/INCOMPLETE/MP3"
delete_links "/glftpd/site/ARCHIVE/INCOMPLETE/FLAC"

find_inc_links "/glftpd/site/ARCHIVE/MP3"
find_inc_links "/glftpd/site/ARCHIVE/FLAC"


