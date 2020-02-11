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
# A script by eur0dance to add affils the site (makes an existing group
# on the site to be an affil) via "SITE ADDAFFIL" command.
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
   echo "Adding $1 ..."
   if [ `grep "privpath $pre_path" $glftpd_conf | grep -c $1` -gt 0 ]; then
	echo "The $pre_path/$1 line already exists in $glftpd_conf."
   else
	echo "Trying to add $pre_path/$1 to $glftpd_conf ..."
	/bin/addaffil $glftpd_conf $1 $pre_path
   fi
   if [ -d "$pre_path/$1" ]; then
	echo "The dir $pre_path/$1 already exists, making sure it has permissions set to 777 ..."
	chmod 777 "$pre_path/$1"
	echo "Couldn't create $pre_path/$1 dir since it already existed. permissions got updated to 777."
        /bin/chown 0:0 "$pre_path/$1"      
        echo "Couldn't create $pre_path/$1 dir since it already existed. user/group got updated."
	echo "Group $1 can start preing now!!!"
   else
	mkdir -m777 "$pre_path/$1" >/dev/null 2>&1
	mkdirres=$?
	if [ $mkdirres -ne 0 ]; then
		echo "Error! Couldn't create $pre_path/$1."
		echo "Removing the $pre_path/$1 dir from $glftpd_conf ..." 
		lines_num=`cat $glftpd_conf | wc -l`
		/bin/delaffil $glftpd_conf $1 $pre_path $lines_num
		echo "Group $1 wasn't set as an affil and it can't pre."
	else
                /bin/chown 0:0 "$pre_path/$1"
		echo "The $pre_path/$1 dir has been created."
		echo "Group $1 can start preing now!!!"
	fi
   fi  
else
   echo "Syntax: SITE ADDAFFIL <group> [pre_dir_path]"
fi

exec "mr-affil_dirscript.sh" ADD $1 MVID
