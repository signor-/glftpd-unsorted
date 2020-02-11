#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################################
# SCRiPT WRiTTEN BY signor, March 2012.
##############################################################################################

original_login="3 0 2 2" #total logins, from same ip, sim downloads, sim uploads
special_login="6 0 3 3" #total logins, from same ip, sim downloads, sim uploads

special_group='UWT' # 'UserWeekTop' group to add to for easy search on who currently has the reward
special_flag='L' # flag to give for special reward
special_top_num='3' # will reward top # users

send_privmsg="YES" # use YES or NO here!

special_log='/glftpd/ftp-data/logs/user_week_top.log'
glftpd_bin='/glftpd/bin'
msgs_path='/glftpd/ftp-data/msgs'
user_path='/glftpd/ftp-data/users'
back_path='/glftpd/ftp-data/users_special'

##############################################################################################
#### DON'T TOUCH BELOW HERE FUCKER!
##############################################################################################

today=`date "+(%b %d %Y)"`
week=`date "+WEEK %W"`
full=`date | sed -e 's/CET //'`

##############################################################################################

echo "--------------------------------------------------------------------------------" >> $special_log

if [ -e $back_path/topthisuploaders ]; then
	mv -f $back_path/topthisuploaders $back_path/toplastuploaders
	echo "backed up last weeks top uploaders"
fi

touch $back_path/topthisuploaders

##############################################################################################

last_special_top_uploaders=`tail -$special_top_num $back_path/toplastuploaders`

suser_allu=""

for suser_name in $last_special_top_uploaders; do

	if [ "$suser_allu" = "" ]; then
		suser_allu="$suser_name"
	else
		suser_allu="${suser_allu}, ${suser_name}"
	fi

	suser_flag=`grep "^FLAGS " $user_path/$suser_name | awk -F"^FLAGS " '{print $2}' | tr -d "$special_flag"` # gets the users flags and removes special_flag from the list
	grep -v "^FLAGS\|^LOGINS\|^GROUP $special_group 0" $user_path/$suser_name > $user_path/$suser_name.special # removes "FLAGS/LOGINS/GROUP $special_group" from userfile
	echo "FLAGS $suser_flag" >> $user_path/$suser_name.special # echos original FLAGS into userfile
	echo "LOGINS $original_login" >> $user_path/$suser_name.special # echos original LOGINS into userfile
	mv -f $user_path/$suser_name $back_path/$suser_name # moves original userfile to backup path, just in case!
	mv -f $user_path/$suser_name.special $user_path/$suser_name # moves special userfile to original userfile
done

echo "reset users are -> $suser_allu"

##############################################################################################

#special_top_uploaders=`$glftpd_bin/stats -u -w -x$special_top_num | grep -e "^\[[0-9][0-9]\]" |tr -d "\[" | tr -d "\]" | awk '{print $1"#"$2"#"$NF-3"#"$NF-2}'`

#section 1 = mp3
special_top_uploaders=`$glftpd_bin/stats -e glftpd -e bnc -e XXX -u -w -x$special_top_num -s 3 | grep -e "^\[[0-9][0-9]\]" |tr -d "\[" | tr -d "\]" | awk '{print $1"#"$2"#"$NF-3"#"$NF-2}'`

suser_allu=""

for uwt in $special_top_uploaders; do
	suser_rank=`echo $uwt | awk -F# '{ print $1 }'`
	suser_name=`echo $uwt | awk -F# '{ print $2 }'`
	suser_file=`echo $uwt | awk -F# '{ print $3 }'`
	suser_megb=`echo $uwt | awk -F# '{ print $4 }'`

	if [ "$suser_allu" = "" ]; then
		suser_allu="$suser_name"
	else
		suser_allu="${suser_allu}, ${suser_name}"
	fi

	suser_flag=`grep "^FLAGS " $user_path/$suser_name | awk -F"^FLAGS " '{print $2}' | tr -d "$special_flag"` # gets the users flags and removes special_flag from the list
	grep -v "^FLAGS\|^LOGINS\|^GROUP $special_group 0" $user_path/$suser_name > $user_path/$suser_name.special # removes "FLAGS/LOGINS/GROUP $special_group" from userfile
	echo "FLAGS ${suser_flag}${special_flag}" >> $user_path/$suser_name.special # echos new FLAGS including special_flag into userfile
	echo "LOGINS $special_login" >> $user_path/$suser_name.special # echos new LOGINS into userfile
	echo "GROUP $special_group 0" >> $user_path/$suser_name.special # echos new GROUP into userfile
	mv -f $user_path/$suser_name $back_path/$suser_name # moves original userfile to backup path, just in case!
	mv -f $user_path/$suser_name.special $user_path/$suser_name # moves special userfile to original userfile
	echo "$suser_name" >> $back_path/topthisuploaders
	echo "$week - $suser_rank - $suser_name with ${suser_file}f ${suser_megb}mb - ${suser_flag}${special_flag} flags" >> $special_log

	if [ "$send_privmsg" = "YES" ]; then
		touch $msgs_path/$suser_name
		chmod 666 $msgs_path/$suser_name
		echo " "  >> $msgs_path/$suser_name
		echo "From: WEEK TOP UPLOAD REWARD (${full})" >> $msgs_path/$suser_name
		echo "--------------------------------------------------------------------------" >> $msgs_path/$suser_name
		echo "Thank you for your upload support and congratulations on making the" >> $msgs_path/$suser_name
		echo "top $special_top_num week uploaders. For your contributions, you now have triple" >> $msgs_path/$suser_name
		echo "upload and triple download privileges (6 logins at once) as well as" >> $msgs_path/$suser_name
		echo "leech access in the archive (via special flags) for one week!" >> $msgs_path/$suser_name
		echo "--------------------------------------------------------------------------" >> $msgs_path/$suser_name
		echo "Note: This reward is reset and regiven to the top $special_top_num week uploaders" >> $msgs_path/$suser_name
		echo "on a week to week basis. Keep up the great support! We thank you, SITE Staff!" >> $msgs_path/$suser_name
		echo "--------------------------------------------------------------------------" >> $msgs_path/$suser_name
		echo " "  >> $msgs_path/$suser_name
	fi
	
done

echo `date "+%a %b %e %T %Y"` UWT: \"$special_top_num\" \"$suser_allu\" >> /glftpd/ftp-data/logs/glftpd.log

echo "$week priveledged users are -> $suser_allu"

##############################################################################################
