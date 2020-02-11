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
############################################################################### -
#DESCRIPTION
#This little script will scan your user database and report back any users
#who have not logged on for a specified number of days or users who have
#logged on today or never.  You may also exempt users and/or groups.
#After any scan you have the ability to purge some or all of the users.

#KNOWN PROBLEMS
# - The EXCEPT_* variables could cause problems, if you enter "dn", and you
#   have a user that contains those letters in that order, they will be exempt
#   as well
# - A user in two groups will show up twice, unless one of the groups is on the
#   exempt list then the user will only show up once
# - If you enter +1 or 1_ or some other fucked up option, the script will fuckup,
#   just learn to read, as those aren't valid options! :)

#THANK YOU's
# - bsugar for original idea and beta testing
# - ju7 for his guidance and training in helping make the script run faster
# - de5ign for some code help

#INSTRUCTIONS
# - Make sure the following bins are in your /glftpd/bin dir and that they are
#   chmod 755
#   echo tr grep date cat
# - You will also need to add the following lines to your glftpd.conf
#   site_cmd last           EXEC    /bin/userlaston.sh
#   custom-last =STAFF
# - Please create the tmp dir and make sure it matches the TEMPPATH variable
#   below and that it is chmod 777.  This dir can be anywhere inside the
#   glftpd rootpath.
# - In order to use the purge features all your users in the user directory 
#   must be chmod 666, take note this is a security risk.  In order to keep 
#   all the users chmod 666 you can add the following to your crontab:
#   0,30 * * * * /path/to/chmod 666 /path/to/glftpd/ftp-data/users/*
#   You will get an error if a specific user does not have this chmod.
# - Use 'site last' on its own for the HELP MENU

#----------------------------------------------------------------------------#

#VARIABLES
#The path to your glftpd users directory, relative to /glftpd
USERPATH="/ftp-data/users"

#The temp path needed to execute the purge options.  The dir can exist
#anywhere inside the glftpd rootpath.  I suggest /glftpd/tmp.  This dir must
#be chmod 777
TEMPPATH="/tmp" #The temp dir, must reside with the glftpd rootpath

#Enter any user(s) you want to exempt. All users must be separated by a |. 
#There is no need for a | if you enter only one user.  Use "" for none.
#User names are case sensitive.
EXEMPT_names="signor|bnc|vip|XXX|default"

#Enter any group(s) you want to exempt. All groups must be separated by a |.
#There is no need for a | if you enter only one user.  Use "" for none.
#Group names are case senstive.
EXEMPT_groups="VIP|STAFF|SITEOP|NUKER"

#----------------------------------------------------------------------------#

#DO NOT EDIT THE BELOW
VER="v5.10"
if [ -z $1 ]; then 
	echo -e " .------------------------"
	echo -e "| User Last On"
	echo -e " \`------------------------"
	echo -e "|        HELP MENU"
	echo -e " \`------------------------"
	echo "You must use one of the following options:"
	echo "Use 1 through 365 to list all users who have not logged on since then"
	echo "Use 0 to list all users and the number of days since they last logged on"
	echo "Use -1 to list all users who logged on today"
	echo "Use 10000 to list all users who have never logged on"
	echo "Use "purge" for the PURGE HELP MENU"
	echo "NOTE: "purge" is only a valid option after a scan"
	echo "NOTE: Exempt users and groups will be ignored in all searches"
	exit 0

else 

if [ $1 != "purge" ]; then
		if [ ! -z "`echo $1 | grep [a-zA-Z]`" ]; then
		echo -e "Invalid option ..."
		echo -e " .------------------------"   
		echo -e "| User Last On"
        	echo -e " \`------------------------"
		echo -e "|        HELP MENU"        
	        echo -e " \`------------------------" 
		echo "You must use one of the following options:"
	        echo "Use 1 through 365 to list all users who have not logged on since then"
	        echo "Use 0 to list all users and the number of days since they last logged on"
	        echo "Use -1 to list all users who logged on today"
        	echo "Use 10000 to list all users who have never logged on"
	        echo "Use "purge" for the PURGE HELP MENU"
	        echo "NOTE: "purge" is only a valid option after a scan"   
        	echo "NOTE: Exempt users and groups will be ignored in all searches"
		exit 0
	else
	if [ $1 -lt -1 ] || [ $1 -gt 10000 ] ; then
		echo -e "Invalid option ..."
        echo -e " .------------------------"
		echo -e "| User Last On"
        echo -e " \`------------------------"
		echo -e "|        HELP MENU"        
        echo -e " \`------------------------" 
		echo "You must use one of the following options:"
	        echo "Use 1 through 365 to list all users who have not logged on since then"
        	echo "Use 0 to list all users and the number of days since they last logged on"
	        echo "Use -1 to list all users who logged on today"
	        echo "Use 10000 to list all users who have never logged on"
	        echo "Use "purge" for the PURGE HELP MENU"
        	echo "NOTE: "purge" is only a valid option after a scan"   
	        echo "NOTE: Exempt users and groups will be ignored in all searches"
                exit 0
	        fi
	fi

	echo -e " .------------------------" 
        echo -e "| User Last On"
        echo -e " \`------------------------"  
	echo "Scanning users, please be patient this may take a few seconds..." 
	echo ""
	
	if [ -a $TEMPPATH/$USER.ulo ]; then
	  rm $TEMPPATH/$USER.ulo
	fi

	#ALL_USERS=`(cd $USERPATH && grep -w ^GROUP * | sed "s/GROUP //" )`
	#updated for glftpd 2.0 by signor
    ALL_USERS=`(cd $USERPATH && grep -w ^GROUP * | sed "s/GROUP //" | awk '{print $1}')`

	if [ -z "$EXEMPT_groups" ] && [ -z "$EXEMPT_names" ]; then
	  USERS_TO_CHECK=`echo $ALL_USERS | tr ' ' '\n'`
	else
	  if [ ! -z "$EXEMPT_groups" ] && [ -z "$EXEMPT_names" ]; then
	    USERS_TO_CHECK=`echo $ALL_USERS | tr ' ' '\n' | grep -Ewv "$EXEMPT_groups"`
	  else
	    if [ -z "$EXEMPT_groups" ] && [ ! -z "$EXEMPT_names" ]; then
	      USERS_TO_CHECK=`echo $ALL_USERS | tr ' ' '\n' | grep -Ewv "$EXEMPT_names"`
	    else
	      if [ ! -z "$EXEMPT_groups" ] && [ ! -z "$EXEMPT_names" ]; then
	        ALL_USERS=`echo $ALL_USERS | tr ' ' '\n' | grep -Ewv "$EXEMPT_groups"`
		USERS_TO_CHECK=`echo $ALL_USERS | tr ' ' '\n' | grep -Ewv "$EXEMPT_names"`
	      fi
  	    fi
	  fi
	fi	

	CURTIME=`date +%s`
	NUMDAYS="$1"
	
	TU="0"

#	for user in `echo $USERS_TO_CHECK | tr ' ' '\n' | cut -d":" -f1`; do
        for user in `echo $USERS_TO_CHECK | tr ' ' '\n' | cut -d":" -f1 | sort -uf`; do
	#for user in `echo $USERS_TO_CHECK | tr ' ' '\n' | cut -d":" -f1 | sort -u | grep -v "^0$" | grep -v "^1$"`; do
		USERTIME=`grep -w ^TIME $USERPATH/$user | cut -d" " -f3`
		DAYS=`echo $[($CURTIME - $USERTIME) / 86400]`
		GROUP=`grep -w ^GROUP $USERPATH/$user | cut -d" " -f2 | head -1`
		CREDZk=`grep -w ^CREDITS $USERPATH/$user | cut -d " " -f2`
	        CREDZ=`echo $[$CREDZk / 1024]`
			if [ $NUMDAYS -eq "-1" ]; then
				if [ $DAYS -eq "0" ]; then
				TU=$[TU + 1]
				echo $TU":"$user"|" >> $TEMPPATH/$USER.ulo
				echo "$TU.) $user ($GROUP) logged on today (Credits = $CREDZ"MB")"
				fi
			else
				if [ $NUMDAYS -eq "0" ]; then
					if [ $DAYS -gt "10000" ]; then 
					TU=$[TU + 1]
					echo $TU":"$user"|" >> $TEMPPATH/$USER.ulo
	                               	echo "$TU.) $user ($GROUP) has never logged on (Credits = $CREDZ"MB")"
					else
						if [ $DAYS -eq "0" ]; then
						TU=$[TU + 1]
						echo $TU":"$user"|" >> $TEMPPATH/$USER.ulo
						echo "$TU.) $user ($GROUP) logged on today (Credits = $CREDZ"MB")"
						else
						TU=$[TU + 1]
						echo $TU":"$user"|" >> $TEMPPATH/$USER.ulo
                        echo "$TU.) $user ($GROUP) last logged on $DAYS days ago (Credits = $CREDZ"MB")"
						fi
                                	fi
				else
					if [ $DAYS -gt $NUMDAYS ]; then
						if [ $DAYS -gt "10000" ]; then
						TU=$[TU + 1]
						echo $TU":"$user"|" >> $TEMPPATH/$USER.ulo
						echo "$TU.) $user ($GROUP) has never logged on (Credits = $CREDZ"MB")"
						else
						TU=$[TU + 1]
						echo $TU":"$user"|" >> $TEMPPATH/$USER.ulo
						echo "$TU.) $user ($GROUP) last logged on $DAYS days ago (Credits = $CREDZ"MB")"
						fi
					fi
				fi
			fi
	done


else
if [ -z $2 ]; then
	echo -e " .------------------------"
        	echo -e "| User Last On"
        echo -e " \`------------------------"
	echo -e "|     PURGE HELP MENU"
        echo -e " \`------------------------"
	echo -e "You must use one of the following options:"
	echo -e "Use the users # to purge individual users based on the last scan"
	echo -e "FORMAT: site last purge # # # #"
	echo -e ""all" to purge all users based on the last scan"
	echo -e "FORMAT: site last purge all"
	echo -e "NOTE: You can enter as many individual users as you want"
 exit 0
fi

	echo -e " .------------------------"    
        	echo -e "| User Last On"
        echo -e " \`------------------------"   
        echo "Purging users, this shouldn't take but a moment..." 
	echo ""	

TPU="0"

if [ "$2" = "all" ]; then
for user in `cat $TEMPPATH/$USER.ulo | tr -d '|'`; do
PUSER=`echo $user | cut -d':' -f2`
TPU=$[TPU + 1]
echo "Purging $PUSER"
chmod 666 $USERPATH/$PUSER
echo "FLAGS 6" >> $USERPATH/$PUSER
done
echo ""
echo "$TPU Users Purged"
echo ""
echo "You must still do a 'site purge' to make this official"
echo "Remember you can always do a 'site readd <user>' to unpurge a user"
exit 0
else

PLIST=`cat $TEMPPATH/$USER.ulo`
shift
while [ "$1" != "" ]; do
PUSER=`echo $PLIST | tr -d ' ' | tr '|' '\n' | grep -w "$1" | cut -d':' -f2`
TPU=$[TPU + 1]
echo "Purging $PUSER"
chmod 666 $USERPATH/$PUSER
echo "FLAGS 6" >> $USERPATH/$PUSER
shift
done

echo ""
echo "$TPU Users Purged"
echo ""
echo "You must still do a 'site purge' to make this official"
echo "Remember you can always do a 'site readd <user>' to unpurge a user"
fi
exit 0
fi
fi
echo ""
echo "Total Users = $TU"

exit 0

