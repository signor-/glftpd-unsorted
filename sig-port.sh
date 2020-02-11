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
# SCRIPT WRITTEN BY SIGNOR MARCH 2012, WHY ARE YOU READING THIS? FCK OFF!
################################################################################

date="$(date "+%a %b %d %H:%M:%S %Y")"

gllog="/ftp-data/logs/glftpd.log"
asciiheader="/bin/sig-asciiheader200.sh"

iplog="/ftp-data/iplogs/iplog.log"
ipwhois="/ftp-data/iplogs/whois"

ipblack="/ftp-data/iplogs/blacklist-ip"
ipwhite="/ftp-data/iplogs/whitelist-ip"
netnameblack="/ftp-data/iplogs/blacklist-netname"
strikesblack="/ftp-data/iplogs/blacklist-strikes"

strikelog="YES"
strikelist="/ftp-data/iplogs/strikelist.log"

userpath="/ftp-data/users"
msgspath="/ftp-data/msgs"
byepath="/ftp-data/byefiles"

binpath="/bin"

updateusers="YES"
checkblacklist="YES"
checknetnameblacklist="YES"

resolveip="YES"

instaban="YES"
# case sensitive user names!
instanotify="signor"

# case sensitive user names!
userskip="signor"

# dirskip="/site/MP3/_PRE /site/FLAC/_PRE /site/MVID/_PRE /site/PRIVATE"
dirskip=""
################################################################################

gotip=`echo $1 | awk -F, '{print $1"."$2"."$3"."$4}' | tr -d "PORT " | tr -d '[:space:]'`

################################################################################
# CHECKING IF <IP> IS KNOWN TO THE SYSTEM
################################################################################

foundip=`cat $iplog | grep "$gotip"`

if [ "$foundip" == "" ]; then

        echo "$gotip" >> $iplog

        whois -h whois.arin.net -p 43 $gotip > $ipwhois/$gotip-whois

        if [ ! -f $ipwhois/$gotip-users ]; then
                touch $ipwhois/$gotip-users
                chmod 666 $ipwhois/$gotip-users
        fi

        useruser=`cat $ipwhois/$gotip-users | grep "$USER"`

        if [ "$useruser" == "" ]; then
                echo "$USER" >> $ipwhois/$gotip-users
        fi
        
        inet=`cat $ipwhois/$gotip-whois | grep "netname:" | awk -F: '{print $2}' | tr -d '[:space:]'`
        country=`cat $ipwhois/$gotip-whois | grep "country:" | awk -F: '{print $2}' | tr -d '[:space:]'`

        if [ "$inet" == "" ]; then
        inet="UNKNOWN"
        fi

        if [ "$country" == "" ]; then
        country="UNKNOWN"
        fi
        
		if [ "$resolveip" == "YES" ]; then
			resolve=`host $gotip | awk '{print $(NF-0)}' | sed 's#\.$##'`
			if [ ! -z `echo "$resolve" | grep -i "NXDOMAIN"` ]; then
				echo "$date PORTACTIVITY: $USER $GROUP \"$gotip (null)\" $inet $country" >> $gllog
			else
				echo "$date PORTACTIVITY: $USER $GROUP \"$gotip ($resolve)\" $inet $country" >> $gllog
			fi
		else
			echo "$date PORTACTIVITY: $USER $GROUP $gotip $inet $country" >> $gllog
		fi

fi

################################################################################
# UPDATING USER LIST THAT USE <IP>
################################################################################

if [ "$updateusers" == "YES" ]; then

        if [ ! -f $ipwhois/$gotip-users ]; then
                touch $ipwhois/$gotip-users
                chmod 666 $ipwhois/$gotip-users
        fi

        useruser=`cat $ipwhois/$gotip-users | grep "$USER"`

        if [ "$useruser" == "" ]; then
                echo "$USER" >> $ipwhois/$gotip-users
        fi

fi

################################################################################
# WHITELISTED IP CHECK
################################################################################

	OIFS="$IFS"
	IFS=$'\r'
	whitelistofips=`cat $ipwhite`
	whiteip=`echo $whitelistofips | awk '{print $1}' | grep -F "$gotip"`
	whitereason=`echo $whitelistofips | grep -F "$gotip" | awk -v nr=2 '{ for (x=nr; x<=NF; x++) { printf $x " "; }; print " " }'`
	IFS="$OIFS"
	if [ ! -z "$whiteip" ]; then
	    echo "200.--------------------------------------------------."
            echo "200|           WHITELISTED IP/NETWORK, OK!            |"       
            echo "200\`--------------------------------------------------'"
		exit 0
	fi

################################################################################
# BLACKLISTED IP CHECK
################################################################################

for protected in $userskip; do
	if [ "$USER" = "$protected" ]; then
        echo "200.--------------------------------------------------."
        echo "200|          BLACKLISTED IP/NETWORK SKIPPED!         |"  
        echo "200\`--------------------------------------------------'"
		exit 0
	fi
done

################################################################################

for protected in $dirskip; do
	cpwd=`echo $PWD | grep "$protected"`
	if [ ! -z "$cpwd" ]; then
        echo "200.--------------------------------------------------."
        echo "200|          BLACKLISTED IP/NETWORK SKIPPED!         |"       
        echo "200\`--------------------------------------------------'"
		exit 0
	fi
done

################################################################################

echo "200.--------------------------------------------------."
echo "200|          BLACKLISTED IP/NETWORK CHECK!           |"
echo "200\`--------------------------------------------------'"

if [ "$checkblacklist" == "YES" ]; then

	#bmask=`echo $1 | awk -F, '{print $1"."$2".*.*"}' | tr -d "PORT " | tr -d '[:space:]'`
	cmask=`echo $1 | awk -F, '{print $1"."$2"."$3".*"}' | tr -d "PORT " | tr -d '[:space:]'`
	dmask=`echo $1 | awk -F, '{print $1"."$2"."$3"."$4}' | tr -d "PORT " | tr -d '[:space:]'`

	OIFS="$IFS"
	IFS=$'\r'
	blacklistofips=`cat $ipblack`
	
	blackliststrike=`cat $strikesblack | grep "$USER" | wc -l`
	blackliststrike=$(($blackliststrike + 1))
		
	for ipmask in $dmask $cmask; do
	
		blackip=`echo $blacklistofips | awk '{print $1}' | grep -F "$ipmask"`
		blackreason=`echo $blacklistofips | grep -F "$ipmask" | awk -v nr=2 '{ for (x=nr; x<=NF; x++) { printf $x " "; }; print " " }'`
		
		if [ ! -z "$blackip" ]; then

			if [ "$instaban" = "NO" ]; then
			
				if [ -f $msgspath/$USER ]; then
					[ `cat $msgspath/$USER | grep "blacklisted ip: $blackip"` ] && exit 0
				fi
				
				blackliststrike="warn"
				
				echo "$date BLACKLISTEDPORTACTIVITY: $USER $GROUP $gotip $blackip \"$blackreason\" $blackliststrike" >> $gllog

				# this holds the current themed ascii for use in scripts!
				$asciiheader

				echo "200|  uh ow! you just used a blacklisted ip address!  |"
				echo "200|                   ----------                     |"
				echo "200|    please contact staff to resolve this issue,   |"
				echo "200|  as your account has been temporarily suspended  |"
				echo "200\`--------------------------------------------------'"
				echo "200 "
			
				IFS=$' '
			
				if [ "$strikelog" == "YES" ]; then
				    if [ ! -f $strikelist ]; then
						touch $strikelist
						chmod 666 $strikelist
					fi
					echo "$date : BLACKLISTED IP -> user $USER has struck a blacklisted IP: $blackip, reason: $blackreason." >> $strikelist
				fi
			
				for staffuser in $instanotify; do
				    if [ ! -f $msgspath/$staffuser ]; then
						touch $msgspath/$staffuser
						chmod 666 $msgspath/$staffuser
					fi
					echo "BLACKLISTED IP -> user $USER has struck a blacklisted IP: $blackip, reason: $blackreason. PLEASE MSG $USER REGARDING THIS MATTER!" >> $msgspath/$staffuser
				done
				
				if [ ! -f $msgspath/$USER ]; then
						touch $msgspath/$USER
						chmod 666 $msgspath/$USER
				fi
				
				echo ".------------------------------------------------" >> $msgspath/$USER
				echo "| uh ow! it seems you used a blacklisted ip address!" >> $msgspath/$USER
				echo "| although your account is still currently active" >> $msgspath/$USER
				echo "|------------------------------------------------" >> $msgspath/$USER
				echo "| staff have also been notified of this matter," >> $msgspath/$USER
				echo "| can you please msg a staff member to resolve this issue!" >> $msgspath/$USER
				echo "|------------------------------------------------" >> $msgspath/$USER
				echo "| blacklisted ip: $blackip" >> $msgspath/$USER
				echo "| blacklisted reason: $blackreason" >> $msgspath/$USER
				echo "\`------------------------------------------------" >> $msgspath/$USER

			else
			
				echo "$USER" >> $strikesblack
				echo "$date BLACKLISTEDPORTACTIVITY: $USER $GROUP $gotip $blackip \"$blackreason\" $blackliststrike" >> $gllog

				# this holds the current themed ascii for use in scripts!
				$asciiheader

				echo "200|   uh ow! you just used a blacklisted network!    |"
				echo "200|                   ----------                     |"
				echo "200|    please contact staff to resolve this issue,   |"
				echo "200|  as your account has been temporarily suspended  |"
				echo "200\`--------------------------------------------------'"
				echo "200 "

				IFS=$' '
			
				if [ "$strikelog" == "YES" ]; then
				    if [ ! -f $strikelist ]; then
						touch $strikelist
						chmod 666 $strikelist
					fi
					echo "$date : BLACKLISTED IP -> user $USER has struck a blacklisted IP: $blackip, reason: $blackreason." >> $strikelist
				fi
				
				for staffuser in $instanotify; do
				    if [ ! -f $msgspath/$staffuser ]; then
						touch $msgspath/$staffuser
						chmod 666 $msgspath/$staffuser
					fi
					echo "BLACKLISTED IP -> user $USER has struck a blacklisted IP: $blackip, reason: $blackreason. PLEASE MSG $USER REGARDING THIS MATTER!" >> $msgspath/$staffuser
				done				
				
				IFS=$'\n'
				
				user_flags="$( grep "^FLAGS " $userpath/$USER | awk -F" " '{print $2}')"
				sed -e "s/^FLAGS $user_flags.*/FLAGS "$user_flags"6/" $userpath/$USER > $userpath/$USER.blacklist
				cp -f $userpath/$USER.blacklist $userpath/$USER
				rm -f $userpath/$USER.blacklist

				echo "-------------------------------------------------" > $byepath/$USER.bye
				echo "uh ow! it seems you used a blacklisted ip address" >> $byepath/$USER.bye
				echo "and your account has been temporarily suspended." >> $byepath/$USER.bye
				echo "please contact staff to resolve this issue!" >> $byepath/$USER.bye
				echo "-------------------------------------------------" >> $byepath/$USER.bye
				echo "this is strike $blackliststrike out of 3 [ 3 strikes = purged ] " >> $byepath/$USER.bye
				echo "-------------------------------------------------" >> $byepath/$USER.bye
				echo "blacklisted ip: $blackip" >> $byepath/$USER.bye
				echo "blacklisted reason: $blackreason" >> $byepath/$USER.bye
				echo "-------------------------------------------------" >> $byepath/$USER.bye
				
				userpids=`$binpath/sitewho --raw $USER | awk '{print $(NF-0)}' | tr -d "\""`
				
				for killpid in $userpids; do
					$binpath/kill $killpid
				done

				IFS="$OIFS"

				exit 0				
		
			fi
		fi
	done
fi

################################################################################

if [ "$checknetnameblacklist" == "YES" ]; then

	if [ -f $ipwhois/$gotip-whois ]; then
		netname=`cat $ipwhois/$gotip-whois | grep "netname:" | awk -F: '{print $2}' | tr -d '[:space:]'`
	fi
	
	if [ "$netname" == "" ]; then
		netname="UNKNOWN"
	fi
	
	OIFS="$IFS"
	IFS=$'\r'
	blacknetnamelist=`cat $netnameblack`
	blacknetname=`echo $blacknetnamelist | awk '{print $1}' | grep "$netname"`
	blacknetnamereason=`echo $blacknetnamelist | grep "$netname" | awk -v nr=2 '{ for (x=nr; x<=NF; x++) { printf $x " "; }; print " " }'`

	blackliststrike=`cat $strikesblack | grep "$USER" | wc -l`
	blackliststrike=$(($blackliststrike + 1))

##########################################################################
	
		if [ ! -z "$blacknetname" ]; then

			if [ "$instaban" = "NO" ]; then
			
				if [ -f $msgspath/$USER ]; then
					[ `cat $msgspath/$USER | grep "blacklisted ip: $blackip"` ] && exit 0
				fi
				
				blackliststrike="warn"
			
				#echo "$USER" >> $strikesblack
				echo "$date BLACKLISTEDNAMEACTIVITY: $USER $GROUP $gotip $blacknetname \"$blacknetnamereason\" $blackliststrike" >> $gllog
			
				# this holds the current themed ascii for use in scripts!
				$asciiheader

				echo "200|   uh ow! you just used a blacklisted network!    |"
				echo "200|                   ----------                     |"
				echo "200|    please contact staff to resolve this issue,   |"
				echo "200|      your account is still currently active      |"
				echo "200.--------------------------------------------------'"
				echo "200 "
			
				IFS=$' '

				if [ "$strikelog" == "YES" ]; then
				    if [ ! -f $strikelist ]; then
						touch $strikelist
						chmod 666 $strikelist
					fi
					echo "$date : BLACKLISTED NETNAME -> user $USER has struck a blacklisted network: $blacknetname ($gotip), reason: $blacknetnamereason." >> $strikelist
				fi
				
				for staffuser in $instanotify; do
				    if [ ! -f $msgspath/$staffuser ]; then
						touch $msgspath/$staffuser
						chmod 666 $msgspath/$staffuser
					fi
					echo "BLACKLISTED NETNAME -> user $USER has struck a blacklisted network: $blacknetname ($gotip), reason: $blacknetnamereason. PLEASE MSG $USER REGARDING THIS MATTER!" >> $msgspath/$staffuser
				done
				
				if [ ! -f $msgspath/$USER ]; then
						touch $msgspath/$USER
						chmod 666 $msgspath/$USER
				fi
				
				echo ".------------------------------------------------" >> $msgspath/$USER
				echo "| uh ow! it seems you used a blacklisted network" >> $msgspath/$USER
				echo "| although your account is still currently active " >> $msgspath/$USER
				echo "|------------------------------------------------" >> $msgspath/$USER
				echo "| staff have also been notified of this matter," >> $msgspath/$USER
				echo "| can you please msg a staff member to resolve this issue!" >> $msgspath/$USER
				echo "|------------------------------------------------" >> $msgspath/$USER
				echo "| blacklisted ip: $gotip" >> $msgspath/$USER
				echo "| blacklisted network: $blacknetname" >> $msgspath/$USER
				echo "| blacklisted reason: $blacknetnamereason" >> $msgspath/$USER
				echo "\`------------------------------------------------" >> $msgspath/$USER

			else
			
				echo "$USER" >> $strikesblack
				echo "$date BLACKLISTEDNAMEACTIVITY: $USER $GROUP $gotip $blacknetname \"$blacknetnamereason\" $blackliststrike" >> $gllog
			
				# this holds the current themed ascii for use in scripts!
				$asciiheader

				echo "200|   uh ow! you just used a blacklisted network!    |"
				echo "200|                   ----------                     |"
				echo "200|    please contact staff to resolve this issue,   |"
				echo "200|  as your account has been temporarily suspended  |"
				echo "200.--------------------------------------------------'"
				echo "200 "

				IFS=$' '

				if [ "$strikelog" == "YES" ]; then
				    if [ ! -f $strikelist ]; then
						touch $strikelist
						chmod 666 $strikelist
					fi
					echo "$date : BLACKLISTED NETNAME -> user $USER has struck a blacklisted network: $blacknetname ($gotip), reason: $blacknetnamereason." >> $strikelist
				fi
				
				for staffuser in $instanotify; do
				    if [ ! -f $msgspath/$staffuser ]; then
						touch $msgspath/$staffuser
						chmod 666 $msgspath/$staffuser
					fi
					echo "BLACKLISTED NETNAME -> user $USER has struck a blacklisted network: $blacknetname ($gotip), reason: $blacknetnamereason. PLEASE MSG $USER REGARDING THIS MATTER!" >> $msgspath/$staffuser
				done
				
				IFS=$'\n'
				
				user_flags="$( grep "^FLAGS " $userpath/$USER | awk -F" " '{print $2}')"
				sed -e "s/^FLAGS $user_flags.*/FLAGS "$user_flags"6/" $userpath/$USER > $userpath/$USER.blacklist
				cp -f $userpath/$USER.blacklist $userpath/$USER
				rm -f $userpath/$USER.blacklist

				echo "-------------------------------------------------" > $byepath/$USER.bye
				echo "uh ow! it seems you used a blacklisted network" >> $byepath/$USER.bye
				echo "and your account has been temporarily suspended." >> $byepath/$USER.bye
				echo "please contact staff to resolve this issue." >> $byepath/$USER.bye
				echo "-------------------------------------------------" >> $byepath/$USER.bye
				echo "this is strike $blackliststrike out of 3 [ 3 strikes = purged ] " >> $byepath/$USER.bye
				echo "-------------------------------------------------" >> $byepath/$USER.bye
				echo "blacklisted ip: $gotip" >> $byepath/$USER.bye
				echo "blacklisted network: $blacknetname" >> $byepath/$USER.bye
				echo "blacklisted reason: $blacknetnamereason" >> $byepath/$USER.bye
				echo "-------------------------------------------------" >> $byepath/$USER.bye
				
				userpids=`$binpath/sitewho --raw $USER | awk '{print $(NF-0)}' | tr -d "\""`
				
				for killpid in $userpids; do
					$binpath/kill $killpid
				done

				IFS="$OIFS"

				exit 0			
			fi
		fi
fi

