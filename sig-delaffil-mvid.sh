#! /bin/sh
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
# A script by eur0dance to remove affils from site (makes an existing group
# on the site not to be an affil anymore) via "SITE DELAFFIL" command.
# Version 1.0 - modded by signor

### CONFIG ###

# Location of your glftpd.conf file, the path is CHROOTED to your glftpd dir.
# In other words, if your glftpd dir is /glftpd then this path will probably be
# /etc/glftpd.conf, the actual file will be /glftpd/etc/glftpd.conf and there
# will be a symlink /etc/glftpd.conf pointing to /glftpd/etc/glftpd.conf.
glftpd_conf="/etc/glftpd.conf"

# Locations of the base pre path - if the second parameter ('pre_dir_path') won't
# be specified during exection of this script then this path will be used as
# the default pre path.
base_pre_path="/site/MVID/_PRE"


### CODE ###

if [ $# -ge 1 ]; then
   if [ $# -eq 2 ]; then
        pre_path=$2
   else
        pre_path=$base_pre_path
   fi
   if [ `expr substr $pre_path 1 5`  != "/site" ]; then
        if [ `expr substr $pre_path 1 1`  != "/" ]; then
           pre_path="/site/$pre_path"
        else
           pre_path="/site$pre_path"
        fi
   fi
   echo "Removing $1 ..."
   echo "Trying to remove $pre_path/$1 from the $glftpd_conf file ..."
   lines_num=`cat $glftpd_conf | wc -l`
   /bin/delaffil $glftpd_conf $1 $pre_path $lines_num
   if [ -d "$pre_path/$1" ]; then
   	rm -rf "$pre_path/$1"
  	echo "Success! $pre_path/$1 has been removed."
	echo "Group $1 is NO LONGER affiled on this site!!!"
   else
	echo "The $1 directory doesn't exist, there is no pre dir to remove."
	echo "Group $1 wasn't fully set or didn't exist, however it got fully removed now!"
   fi   
else
   echo "Syntax: SITE DELAFFIL <group> [pre_dr_path]"
fi

exec "mr-affil_dirscript.sh" DEL $1 MVID
