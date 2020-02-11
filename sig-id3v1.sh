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

#Shell script to read ID3v1.x Tag from an mp3 audio file
#Known Issue: Because the '\0' are replaced with ' ' blankspaces. The Genre value 0 will be replaced by 32
#To get it right instead of storing the tag string in a variable direct access is needed

while [ -n "$1" ]
 do

  file="$1"

  if [ ! -f "$file" ]
    then
    echo "File \"$file\" does not exist"
    shift 1
    continue
  fi  

  tag=$(tail -c128 "$file" | tr '\0' ' ') # Replace NULL with spaces
  id3=$(head -c10 "$file" | tr '\0' ' ') # NULLs are being omitted

  id3v1_sig=${tag:0:3}

  id3v2_sig=${id3:0:3}

  id3v2_ver=${id3:3:1}
  id3v2_ver=$(printf "%d" "'$id3v2_ver")

  id3v2_rev=${id3:4:1}
  id3v2_rev=$(printf "%d" "'$id3v2_rev")

  if [ "$id3v2_sig" = "ID3" ]
    then
      echo "ID3v2.$id3v2_ver.$id3v2_rev Tag present"
    else
      echo "ID3v2 Tag present Not present"
  fi

  if [ "$id3v1_sig" = "TAG" ]
    then
      echo "ID3v1.x Tag present"
  fi

  if [ "$id3v1_sig" = "TAG" ]
    then
      
      song_name=${tag:3:30}
      artist=${tag:33:30}
      album=${tag:63:30}
      year=${tag:93:4}
      comment=${tag:97:28}
      #The second last byte of the Comment field ie the 126th byte of the tag is always zero in ID3v1.1
      album_track=${tag:126:1} #Last two bytes of comment field was reserved for album track no. in ID3v1.1
      album_track=$(printf "%d" "'$album_track") #Convert Album Track ASCII to value
      genre=${tag:127:1}
      genre=$(printf "%d" "'$genre") #Convert Genre to ASCII value
      
      #Reads the genre string from the file id3v1_genre_string
      if [ -f id3v1_genre_list ]
	then
#	  genre_string=$(grep "\<$genre\>" id3v1_genre_list)
genre_string=$(grep "\<$genre\>" id3v1_genre_list | awk -F= '{print $2}' | sed 's/^ //';)
	else
	  genre_string="Genre Code = $genre"
      fi
      
      
      echo -e "Displaying ID3v1 Tag of file \"$file\"\n"
      echo "Song Name   : $song_name"
      echo "Artist      : $artist"
      echo "Album       : $album"
      echo "Year        : $year"
      echo "Comment     : $comment"
      echo "Album Track : $album_track"
      echo "Genre       : $genre_string"
      
    else
	echo "The file \"$file\" does not contain an ID3v1 tag"
  fi

shift 1
done
