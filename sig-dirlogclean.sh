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
VER=1.6.1

glconf="/glftpd/etc/glftpd.conf"

cleanold="/glftpd/bin/olddirclean2"
cleanlog="/glftpd/ftp-data/logs/olddirclean.log"

glupdate="/glftpd/bin/glupdate"

dirlog="/glftpd/ftp-data/logs/dirlog"
keepchmod=666

glroot="/glftpd/site"

sections="
$glroot/MP3:DEEP
$glroot/FLAC:DEEP
$glroot/MVID:DEEP
$glroot/ARCHIVE/MP3:DEEP
$glroot/ARCHIVE/FLAC:DEEP
$glroot/ARCHIVE/MVID:DEEP
"
exclude="^\_PRE$|^GROUPS$|^lost\+found$|^All$|^\[SITE\].*|^\(.*\)\-.*"

#####################################################

if [ "$1" = "debug" ]; then
  echo "Verifying existance of required bins.."
fi

if [ ! -x "$cleanold" ]; then
  echo "Error. Cant execute $cleanold. Check existance and perms."
  exit 1
fi
if [ ! -x "$glupdate" ]; then
  echo "Error. Cant execute $glupdate. Check existance and perms."
  exit 1
fi
if [ ! -r "$glconf" ]; then
  echo "Error. Cant read $glconf. Check existance and perms."
  exit 1
fi

if [ "$1" = "debug" ]; then
  echo "Checking for new or moved files to add to db."
fi

for section in $sections; do
  section="`echo "$section" | sed -e 's/\[\:space\:\]/ /g'`"
  dated="$( echo $section | cut -d ':' -f2 )"
  if [ "$dated" != "DEEP" ] && [ "$dated" != "2xDEEP" ] && [ "$dated" != "3xDEEP" ]; then
    if [ "$1" = "debug" ]; then
      echo "Entering \"$section\""
    fi
    $glupdate -r ${glconf} "$section" >> $cleanlog
  else
    section="$( echo $section | cut -d ':' -f1 )"
    if [ ! -d "$section" ]; then
      echo "Error. \"$section\" does not exist. Skipping."
    else
      cd "$section"
      LIST="$( ls -1 | egrep -vi "$exclude" )"
      for folder in $LIST; do

        if [ "$dated" = "2xDEEP" ]; then
          LIST2="$( ls -1 $folder | egrep -vi "$exclude" )"
          for folder2 in $LIST2; do
            if [ ! -d "$section/$folder/$folder2" ]; then
              if [ "$1" = "debug" ]; then
                echo "Not a dir: $section/$folder/$folder2 - Skipping."
              fi
            else
              if [ "$1" = "debug" ]; then
                echo "Entering (2xDEEP) \"$section/$folder/$folder2\""
              fi
              $glupdate -r ${glconf} "$section/$folder/$folder2" >> $cleanlog
            fi
          done

        elif [ "$dated" = "3xDEEP" ]; then
          LIST2="$( ls -1 $folder | egrep -vi "$exclude" )"
          for folder2 in $LIST2; do
            if [ ! -d "$section/$folder/$folder2" ]; then
               if [ "$1" = "debug" ]; then
                 echo "Not a dir: $section/$folder/$folder2 - Skipping."
               fi
            else
              LIST3="$( ls -1 $folder/$folder2 | egrep -vi "$exclude" )"
              for folder3 in $LIST3; do
                if [ ! -d "$section/$folder/$folder2/$folder3" ]; then
                   if [ "$1" = "debug" ]; then
                     echo "Not a dir: $section/$folder/$folder2/$folder3 - Skipping."
                   fi
                else
                  if [ "$1" = "debug" ]; then
                    echo "Entering (3xDEEP) \"$section/$folder/$folder2/$folder3\""
                  fi
                  $glupdate -r ${glconf} "$section/$folder/$folder2/$folder3" >> $cleanlog
                fi
              done
            fi
          done

        else
          if [ ! -d "$section/$folder" ]; then
            if [ "$1" = "debug" ]; then
              echo "Not a dir: $section/$folder - Skipping."
            fi
          else
            if [ "$1" = "debug" ]; then
              echo "Entering (DEEP) \"$section/$folder\""
            fi
            $glupdate -r ${glconf} "$section/$folder" >> $cleanlog
          fi
        fi

      done
    fi
  fi
done

if [ "$keepchmod" ]; then
  if [ "$1" = "debug" ]; then
    echo "Running chmod $keepchmod $dirlog"
  fi
  chmod $keepchmod $dirlog
fi

echo "" >> $cleanlog

## Run olddircleaner.
if [ "$1" = "debug" ]; then
  echo "Checking for files that does not exist anymore / sorting dirlog. This could take some time."
fi

$cleanold -P -D -r${glconf} > $cleanlog

if [ "$keepchmod" ]; then
  if [ "$1" = "debug" ]; then
    echo "Running chmod $keepchmod $dirlog"
  fi
  chmod $keepchmod $dirlog
fi

exit 0
