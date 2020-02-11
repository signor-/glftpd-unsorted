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
# cant find a file? eg a mp3 file inside a va- album and don't want to search manually
# then this find function is for you :P
# site search only finds directories with the match criteria, this finds files :)
#

# set your glftpd site dir here, as we will want to search under this dir :)
glftpdsitedir="
/site/MP3/
/site/ARCHIVE/MP3/2010/
/site/ARCHIVE/MP3/2011/
/site/ARCHIVE/MP3/2012/
"

# set the file extention we want to search for
fileextention="mp3"

# min string search length
minsearchlength="8"

# dont edit below here, k thx bai
###################################################################

OIFS="$IFS"
IFS=$'\n'

input=${*//[^a-z,A-Z,0-9]/ } #only keep a-z, A-Z and 0-9 chars, omit the rest
input=${input//[\,]/} #omit any other chars here
input=`echo $input | tr -s ' ' '*'` #now trim all the spaces and replace with one *

if [ "$input" == "" ]; then
echo "nothing to search"
exit 0
fi

inputlength=${#input}
if [ "$inputlength" -lt "$minsearchlength" ]; then
echo "minimum search string length is $minsearchlength chars, your search was only $inputlength chars"
exit 0
fi

fullinput=`echo "*$input*.$fileextention"`

echo "searching for $fullinput"


for glftpdsearchdir in $glftpdsitedir; do

	found=`find "$glftpdsearchdir" -name "$fullinput" 2>/dev/null`

	i=0

	for foundit in $found; do
#		filefound=`echo $foundit | awk -F$glftpdsearchdir '{print $2}'`
		filefound=`echo $foundit | sed "s/^\/site\///"`
		echo "/$filefound"
		i=$(($i + 1))
	done

done

echo "found $i file(s)"

IFS="$OIFS"
