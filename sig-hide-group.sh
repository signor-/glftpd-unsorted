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
#
# cscript SITE[:space:]adduser post /bin/sig-hide-group.sh
# cscript SITE[:space:]gadduser post /bin/sig-hide-group.sh
# cscript SITE[:space:]chgrp post /bin/sig-hide-group.sh

###############################################################################
######################### CONFiGURATiON #######################################
###############################################################################
#path to the user files
usersdir="/ftp-data/users"
#tmp dir
tmpdir="/tmp"
#name of the group that will be 1st group of "hidden users"
#this group also has to be the 1st group of the gadmin for the script to work
#you don't want anyone to be gadmin of this group ($hidegroup) !!!
hidegroup="XXX"

###############################################################################
###################### SCRiPT STARTS HERE #####################################
###############################################################################

adduser () {
    newuser=`echo "$1" | awk '{print $3}'`
#echo "$newuser 1=$1 2=$2 3=$3 4=$4" >> /bin/sig-hide-group.debug
#testadduser 1=SITE ADDUSER testadduser 12345 *@12.34.56.78 2=signor 3=SITEOP 4=
    #passwdfile
    grep -ve "^$newuser" /etc/passwd > $tmpdir/passwd.tmp
    grep -e "^$newuser" /etc/passwd | awk -F ":" '{print $1":"$2":"$3":0:"$5":"$6":"$7}' >> $tmpdir/passwd.tmp
    cp /etc/passwd /etc/passwd.bak
    mv $tmpdir/passwd.tmp /etc/passwd
    chmod 644 /etc/passwd*
    chown 0:0 /etc/passwd*
    echo "masked group"
}

gadduser () {
    newuser=`echo "$1" | awk '{print $4}'`
#echo "$newuser 1=$1 2=$2 3=$3 4=$4" >> /bin/sig-hide-group.debug
#testgadduser 1=SITE GADDUSER IND testgadduser 12345 *@12.34.56.78 2=signor 3=SITEOP 4=
    #passwdfile
    grep -ve "^$newuser" /etc/passwd > $tmpdir/passwd.tmp
    grep -e "^$newuser" /etc/passwd | awk -F ":" '{print $1":"$2":"$3":0:"$5":"$6":"$7}' >> $tmpdir/passwd.tmp
    cp /etc/passwd /etc/passwd.bak
    mv $tmpdir/passwd.tmp /etc/passwd
    chmod 644 /etc/passwd*
    chown 0:0 /etc/passwd*
    echo "masked group"
}

chgrp () {
    newuser=`echo "$1" | awk '{print $3}'`
#echo "$newuser 1=$1 2=$2 3=$3 4=$4" >> /bin/sig-hide-group.debug
#testgadduser 1=SITE CHGRP testgadduser IND 2=signor 3=SITEOP 4=
    #passwdfile
    grep -ve "^$newuser" /etc/passwd > $tmpdir/passwd.tmp
    grep -e "^$newuser" /etc/passwd | awk -F ":" '{print $1":"$2":"$3":0:"$5":"$6":"$7}' >> $tmpdir/passwd.tmp
    cp /etc/passwd /etc/passwd.bak
    mv $tmpdir/passwd.tmp /etc/passwd
    chmod 644 /etc/passwd*
    chown 0:0 /etc/passwd*
    echo "masked group"
}

sitecmd=`echo "$1" | awk '{print $2}'`

if [[ $sitecmd == [Aa][Dd][Dd][Uu][Ss][Ee][Rr] ]];then
  adduser "$1" "$2" "$3"
elif [[ $sitecmd == [Gg][Aa][Dd][Dd][Uu][Ss][Ee][Rr] ]];then
  gadduser "$1" "$2" "$3"
elif [[ $sitecmd == [Cc][Hh][Gg][Rr][Pp] ]];then
  chgrp "$1" "$2" "$3"
else
  exit
fi


