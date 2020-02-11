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
###############################################################################
#
# this program pings a host and takes the ip value returned and places it
# as the pasv_addr in glftpd.conf. it checks to see if the ip have changed
# since the last time, and if it has, it executes the change. 
#
# glftpd dynamic ip address translator. 
#
# for best effect run every 5 minutes in crontab
#
# */5 * * * *  gldynamicip.sh
#
###############################################################################

####################################################
################### CONFIG #########################
####################################################

GLFTPDCONFPATH="/glftpd/etc"
GLFTPDCONF="glftpd.conf"

# The internet host you want the ip from to be in glftpd.conf
DYNAMICHOST="XXX.ftp.net"

# The passive mode mode you want to use ( more information in the glftpd.docs )
PASSIVEMODE="1"

###################################################
######## NO NEED TO EDIT PAST THIS LINE ###########
###################################################

ipadress=""
ipadress=`ping -c 1 $DYNAMICHOST`

case $ipadress in
    *unknown*)
	echo "Could not find host. Please check parameters"
	;;
    PING*)
        cd ${GLFTPDCONFPATH}
        ipadress=`ping -c 1 $DYNAMICHOST | grep "PING $DYNAMICHOST" | awk '{ printf("%s", $3) }' | sed -e "s/^(//" | sed -e "s/)//" `
        oldipadress=`more $GLFTPDCONF | grep pasv_addr | awk '{ printf("%s", $2) }'`
        if [ $ipadress == $oldipadress ] ;then
            exit 0;
        fi
        sed -e "s/^pasv_addr.*/pasv_addr $ipadress $PASSIVEMODE/" $GLFTPDCONF > gldynamic.temp
        mv -f gldynamic.temp $GLFTPDCONF
      	exit 1
	;;
    *)
        echo "Not able to find out ip. Please check parameters"
       ;;
esac

