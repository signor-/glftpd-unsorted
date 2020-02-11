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

# config #
##########

# Where do I find your logs?
logdir=/glftpd/ftp-data/logs

# Enter here the names of the logs you wish trimmed.
# The format is: <logname>:<# of lines to keep>
logfiles="error.log:500 glftpd.log:10000 login.log:10 request.log:100 xferlog:100 dirscript.log:1000 system.log:1000"
today="`date +"%a %b %d %H:%M:%S %Y"`"

#################
# end of config #

for logline in $logfiles; do
  logfile=`echo $logline | cut -d ':' -f 1`
  loglines=`echo $logline | cut -d ':' -f 2`
  echo "trimming $logfile to the last $loglines"
  tail -n $loglines ${logdir}/${logfile} > ${logdir}/${logfile}.temp
  echo "$today -- Logfile turned over --" >> ${logdir}/${logfile}.temp
  cat ${logdir}/${logfile}.temp > ${logdir}/${logfile}
  rm -f ${logdir}/${logfile}.temp
done


