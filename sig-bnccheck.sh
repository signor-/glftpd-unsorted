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

# name:host:port:user:password:section:ssl

site[0]="CA:ca.xxx.biz:9999:bnc:password:section:yes";
site[1]="LI:li.xxx.biz:9999:bnc:password:section:yes";
site[2]="RO:ro.xxx.biz:9999:bnc:password:section:yes";
site[3]="NL:nl.xxx.biz:9999:bnc:password:section:yes";

numsites=4; #[site + 1]

declare -i i=0;
while [ $i -lt $numsites ]; do
        sitename=`echo ${site[$i]} | awk -F: '{ print $1 }'`;
        sitehost=`echo ${site[$i]} | awk -F: '{ print $2 }'`;
        siteport=`echo ${site[$i]} | awk -F: '{ print $3 }'`;
        siteuser=`echo ${site[$i]} | awk -F: '{ print $4 }'`;
        sitepass=`echo ${site[$i]} | awk -F: '{ print $5 }'`;
        sitesections=`echo ${site[$i]} | awk -F: '{ print $6 }'`;
        sitessl=`echo ${site[$i]} | awk -F: '{ print $7 }'`;
        if [ $sitessl = "yes" ]; then
          sitestatus=`curl -s -u $siteuser:$sitepass ftp://$sitehost:$siteport --output "/dev/null" --ftp-ssl-control --insecure -w %{time_total}`
        else
          sitestatus=`curl -s -u $siteuser:$sitepass ftp://$sitehost:$siteport --output "/dev/null" -w %{time_total}`
        fi

if [ "$sitestatus" == "0.000" ]; then
echo "$sitename ($sitesections) -> DOWN -> $sitehost:$siteport"
else
echo "$sitename ($sitesections) -> UP ($sitestatus"s") -> $sitehost:$siteport"
fi
i=$(( $i +1 ))
done
