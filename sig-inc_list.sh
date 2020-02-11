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
data_path="/glftpd/ftp-data"
inc_dir="/INCOMPLETE"
inc_labels="
(incomplete)-
(no-sfv)-
(no-nfo)-
"
# full path to the nuker binary
nuker_bin="/glftpd/bin/nuker"

# nuke_warn must be in minutes, and only 15 30 60 is valid!
nuke_warn="30"
# nuke_limit must be in minutes, 3 hours / 60 = 180
nuke_limit="120"
# make sure this is a valid user on site with +AB flags (and =NUKER if needed)
nuke_user="XXX"

nuke_mult="5"

####################################################

# dont touch this!
nuke_warn_time=`date +%M`

function delete_links () {
        echo "deleting current symlinks for "$1" please wait..."              
		rm -rf $1/*
}

function find_inc_links () {
        cd $gl_root$site_root
        echo "checking incomplete symlinks for "$1" please wait..."
		for cur_label in $inc_labels; do
			find "$1" -mindepth 2 -maxdepth 2 -type l -name "$cur_label*" -not -path "*/_PRE/*"| while read LINE
			do
					inc_sym_link=`echo $LINE`
					real_dir=`echo $inc_sym_link | sed 's/'$cur_label'//g;' | sed 's/([Cc][Dd][1-2])\-//g;'`
					nuke_section=`basename $1`
					nuke_it "$real_dir" "$inc_sym_link" "$nuke_section"
					real_dir=${real_dir#$gl_root$site_root}
					inc_release=`basename $real_dir`
					inc_sym_dir=`basename $inc_sym_link`
					# inc_section=`basename $1`
					# new inc_section keeps the proper dir structure in /INCOMPLETES to match site.
					inc_section=`echo "$1" | cut -d/ -f4-`
					if [ ! -d "$gl_root$site_root$inc_dir/$inc_section" ]; then
							mkdir -m777 -p "$gl_root$site_root$inc_dir/$inc_section"
					fi
									if [ ! -e "$gl_root$site_root$inc_dir/$inc_section/$inc_release" ]; then
											ln -s "../..$real_dir" "$gl_root$site_root$inc_dir/$inc_section/$inc_release"
											echo "found $cur_label release $real_dir"
									fi
			done
		done
}

function nuke_it () {
		if [ -d "$1" ]; then
			curr_time=`date --date "now" +"%Y-%m-%d %T"`
			date_time=`stat -c %y "$1" | awk -F. '{print $1}'`
			nuke_elapsed=`echo $"(( $(date --date="$curr_time" +%s) - $(date --date="$date_time" +%s) ))/60" | bc`
			nuke_time_left=$(( $nuke_limit - $nuke_elapsed ))
			nuke_path=${1#$gl_root$site_root}
			nuke_rel=`basename $nuke_path`
			nuke_sec=`echo "$3"`
			if [ "$nuke_elapsed" -gt "$nuke_limit" ]; then
				$nuker_bin -N $nuke_user -n "$site_root$nuke_path" $nuke_mult auto.nuke_still.incomplete.after.$nuke_elapsed.minutes_limit.is.$nuke_limit.minutes.old
				rm -f "$2"
			fi
			if [ "$nuke_elapsed" -lt "$nuke_limit" -a "$nuke_elapsed" -gt "$(( $nuke_warn - 1 ))" ]; then

				if [ "$nuke_warn" == "15" ]; then
					if [ "$nuke_warn_time" == "00" -o "$nuke_warn_time" == "15" -o "$nuke_warn_time" == "30" -o "$nuke_warn_time" == "45" ]; then
						echo `date "+%a %b %d %T %Y"` NUKEWARN: \"$nuke_sec\" \"$nuke_rel\" \"$nuke_elapsed\" \"$nuke_time_left\" \"$nuke_limit\" >> $data_path/logs/glftpd.log
					fi
				fi

				if [ "$nuke_warn" == "30" ]; then
					if [ "$nuke_warn_time" == "00" -o "$nuke_warn_time" == "30" ]; then
						echo `date "+%a %b %d %T %Y"` NUKEWARN: \"$nuke_sec\" \"$nuke_rel\" \"$nuke_elapsed\" \"$nuke_time_left\" \"$nuke_limit\" >> $data_path/logs/glftpd.log
					fi
				fi

				if [ "$nuke_warn" == "60" ]; then
					if [ "$nuke_warn_time" == "00" ]; then
						echo `date "+%a %b %d %T %Y"` NUKEWARN: \"$nuke_sec\" \"$nuke_rel\" \"$nuke_elapsed\" \"$nuke_time_left\" \"$nuke_limit\" >> $data_path/logs/glftpd.log
					fi
				fi
			fi
		fi
}

function check_dead_links () {
echo "searching dead symlinks for "$1" please wait..."
	find "$1" -type l | (while read FN ; do test -e "$FN" || ls -ld "$FN"; done) | while read LINE
	do
		bad_sym_link=`echo $LINE | awk '{print $(NF-2)}'`
		rm -f "$bad_sym_link"
		echo "found bad symlink, deleted -> $bad_sym_link"
	done
}

delete_links "/glftpd/site/INCOMPLETE/MP3"
delete_links "/glftpd/site/INCOMPLETE/FLAC"

check_dead_links "/glftpd/site/MP3"
check_dead_links "/glftpd/site/FLAC"

find_inc_links "/glftpd/site/MP3"         
find_inc_links "/glftpd/site/FLAC"

check_dead_links "/glftpd/site/INCOMPLETE/MP3"
check_dead_links "/glftpd/site/INCOMPLETE/FLAC"

check_dead_links "/glftpd/site/REQUESTS/"
