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

# cd /glftpd/ftp-data/logs
# ln -s /home/eggdrop/eggdrop/data.news data.news

NEWSFILE="/ftp-data/eggdrop/data.news"

echo "--------------------------------------------------------------------------------"
#cat $NEWSFILE | while read LINE; do
tail -50 $NEWSFILE | while read LINE; do
	NEWSDATE=`echo "$LINE" | awk '{print $1}'`
	NEWSDATE=$(date --date "1970-01-01 UTC $NEWSDATE seconds" "+%Y-%m-%d")
	NEWSAUTHOR=`echo "$LINE" | awk '{print $2}'`
	NEWSNEWS=`echo "$LINE" | awk '{ print substr($0, index($0,$3)) }'`
	for NEWSLINE in "$NEWSNEWS"; do
		NEWSLINE="[NEWS] [ $NEWSDATE ] $NEWSAUTHOR -> $NEWSLINE"
		NEWSLINE=`echo $NEWSLINE | sed -e 's/.\{78\} /&\n/g'`
		echo "$NEWSLINE"
		echo " "
	done
done
echo "--------------------------------------------------------------------------------"
