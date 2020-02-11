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

df -P | grep "/dev/" | grep -vE '^Filesystem|none|cdrom' | while read OUTPUT;
do

	DEVICE=$(echo $OUTPUT | awk '{print $1}')

	MOUNT=$(echo $OUTPUT | awk '{print $6}')

	SIZEUSED=$(echo $OUTPUT | awk '{print $3}')
	SIZEUSEDGB=$(echo "scale=2; $SIZEUSED / 1024 / 1024" | bc) #GB

	SIZEFREE=$(echo $OUTPUT | awk '{print $4}')
	SIZEFREEGB=$(echo "scale=2; $SIZEFREE / 1024 / 1024" | bc) #GB

	SIZETOTAL=$(echo "scale=2; $SIZEUSED + $SIZEFREE" | bc) #GB)
	SIZETOTALGB=$(echo "scale=2; $SIZETOTAL / 1024 / 1024" | bc) #GB

	PERCENTUSED=$(echo "scale=2; $SIZEUSED*100/$SIZETOTAL" | bc) #PERCENT
	PERCENTFREE=$(echo "scale=2; $SIZEFREE*100/$SIZETOTAL" | bc) #PERCENT

	# echo "$DEVICE has ${SIZETOTALGB}GB total, ${SIZEUSEDGB}GB in use (${PERCENTUSED}%), ${SIZEFREEGB}GB free (${PERCENTFREE}%), mounted on $MOUNT"
	echo "${SIZEUSEDGB}GB of ${SIZETOTALGB}GB (${PERCENTUSED}% used, ${PERCENTFREE}% available) [$MOUNT]"
	
done

# bind pub -|- [set cmdpre]adf adf
       # proc adf {nick uhost hand chan args} {  
       # global cmdpre sitename     
       # if { "$chan" != "#rocksolid-staff" } { return 0 }
           # set output [exec /glftpd/bin/mr-disk_free.sh]
           # foreach line [split $output "\n"] {                 
           # set line [lrange $line 0 end]
		   # regsub -all "{|}" $line "" line
           # set line [string trim $line "\n"]
           # putserv "PRIVMSG $chan :\002\[\00310FREE\003\]\002 -> $line"                      
       # }
# }
