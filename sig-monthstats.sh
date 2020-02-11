#!/bin/sh
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
## add to crontab for root.
## 57 23 * * * [ $(cal|awk '{print $2,$3,$4,$5,$6}'| tr -s '[:blank:]' '\n'|tail -1) = $(date +%d) ] && /glftpd/bin/sig-monthstats.sh >/dev/null 2>&1

sitename="XXX"
glftpd='/glftpd'
glftpd_conf='/glftpd/etc/glftpd.conf'
glftpd_log='/glftpd/ftp-data/logs/glftpd.log'
stats="/glftpd/site/STATS/`date +%Y-%B`"

[ ! -d $stats ] && mkdir -m777 $stats

month=`date +%B`
uprmonth=`date +%B | tr '[:lower:]' '[:upper:]'`
year=`date +%Y`

cd $glftpd/bin

echo "------------------------------------------------------------------------" > $stats/$year-$month\_Month_Stats.txt
echo "                  $sitename STATS FOR $uprmonth $year                      " >> $stats/$year-$month\_Month_Stats.txt
echo "     --------------------------------------------------------------     " >> $stats/$year-$month\_Month_Stats.txt
echo " " >> $stats/$year-$month\_Month_Stats.txt
echo "------------------------------------------------------------------------" >> $stats/$year-$month\_Month_Stats.txt
echo "                           SECTION: MP3                                 " >> $stats/$year-$month\_Month_Stats.txt
echo "     --------------------------------------------------------------     " >> $stats/$year-$month\_Month_Stats.txt
echo " " >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf -e glftpd -e bnc -e XXX -m -u -x 200 -s 1 >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf -e glftpd -e bnc -e XXX -m -d -x 200 -s 1 >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf -e glftpd -e bnc -e XXX -M -u -x 200 -s 1 >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf -e glftpd -e bnc -e XXX -M -d -x 200 -s 1 >> $stats/$year-$month\_Month_Stats.txt
echo " " >> $stats/$year-$month\_Month_Stats.txt
echo "------------------------------------------------------------------------" >> $stats/$year-$month\_Month_Stats.txt
echo "                           SECTION: FLAC                                " >> $stats/$year-$month\_Month_Stats.txt
echo "     --------------------------------------------------------------     " >> $stats/$year-$month\_Month_Stats.txt
echo " " >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf -e glftpd -e bnc -e XXX -m -u -x 200 -s 2 >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf -e glftpd -e bnc -e XXX -m -d -x 200 -s 2 >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf -e glftpd -e bnc -e XXX -M -u -x 200 -s 2 >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf -e glftpd -e bnc -e XXX -M -d -x 200 -s 2 >> $stats/$year-$month\_Month_Stats.txt
echo " " >> $stats/$year-$month\_Month_Stats.txt
echo "------------------------------------------------------------------------" >> $stats/$year-$month\_Month_Stats.txt
echo "                           SECTION: MVID                                " >> $stats/$year-$month\_Month_Stats.txt
echo "     --------------------------------------------------------------     " >> $stats/$year-$month\_Month_Stats.txt
echo " " >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf -e glftpd -e bnc -e XXX -m -u -x 200 -s 3 >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf -e glftpd -e bnc -e XXX -m -d -x 200 -s 3 >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf -e glftpd -e bnc -e XXX -M -u -x 200 -s 3 >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf -e glftpd -e bnc -e XXX -M -d -x 200 -s 3 >> $stats/$year-$month\_Month_Stats.txt

echo " " >> $stats/$year-$month\_Month_Stats.txt
echo "EOF" >> $stats/$year-$month\_Month_Stats.txt
echo "------------------------------------------------------------------------" >> $stats/$year-$month\_Month_Stats.txt
