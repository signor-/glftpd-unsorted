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
#########################################################################################
# DONT GiVE THiS SCRiPT OUT.!!!!
# rescripted by mRmiSta
#
# 0/10 * * * * /glftpd/bin/sig-nuked_delete.sh >/dev/null 2>&1
#########################################################################################
#
# dir style of your nuked dirs
dir_style="(nuked)-"
# dir that has been nuked after this time will get removed
nuke_time="1440"
# where is your glftpd log file
glftpd_log="/glftpd/ftp-data/logs/glftpd.log"
#
# temp nuke file
tmp_file="/glftpd/tmp/nukelist"
#
# glftpd site dir
site_dirs="/glftpd/site/MP3 /glftpd/site/FLAC /glftpd/site/MVID"
#/glftpd/site/FLAC
#########################################################################################
# DONT EDiT BELOW!!
#########################################################################################
rm -f $tmp_file

for check_dir in $site_dirs; do
	echo "compiling $dir_style list for $check_dir, please wait..."
	find $check_dir -name "$dir_style*" -print >> $tmp_file
done

echo "compiling done, comparing datestamps please wait..."

cattmp=$( cat $tmp_file )

for ndir_fpath in $cattmp; do
echo "found $ndir_fpath comparing timestamps..."
del_dir=`echo "$ndir_fpath" | cut -f4- -d"/"`
tmp=`date -d "\`ls -ltd "$ndir_fpath" | awk '{print $6" "$7}'\`" +%s`
rel_time=$(( ( `date +%s` - $tmp ) / 60 ))
if [ $rel_time -gt $nuke_time ]; then
        del_dir_size=`du -sm $ndir_fpath | awk '{print $1}'`
        rm -fr $ndir_fpath
        echo `date "+%a %b %d %T %Y"` NUKEDDIRDEL: \"$del_dir_size\" \"$del_dir\" \"$rel_time\" \"$nuke_time\"
#        echo `date "+%a %b %d %T %Y"` NUKEDDIRDEL: \"$del_dir_size\" \"$del_dir\" \"$rel_time\" \"$nuke_time\" >> $glftpd_log
fi
done
exit

