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

gllog=
glroot=/glftpd/site
section=/MP3
duration=day
euroweek=FALSE
newmod=777
oldmod=755
datebin="date"
sectionname="MP3"

symlinks="
/MP3_TODAY
"

day="$( $datebin +%Y-%m-%d )"
week="$( $datebin +%Y-WEEK_%V )"
month="$( $datebin +%Y-%B )"

lastday="$( $datebin --date "-1 day" +%Y-%m-%d )"
lastweek="$( $datebin --date "-1 week" +%Y-WEEK_%V )"
lastmonth="$( $datebin --date "-1 month" +%Y-%B )"

#-[ Script Start. No changes should be needed below here ]---------#

## Has to run AFTER midnight, so..
sleep 1

## Check if first or second argument is 'debug'
if [ "$1" = "debug" -o "$2" = "debug" -o "$1" = "DEBUG" -o "$2" = "DEBUG" ]; then
  DEBUG=TRUE
fi

## Check if first argument is 'force'.
if [ "$1" = "force" -o "$1" = "FORCE" ]; then
  if [ "$duration" = "day" ]; then
    echo "Force is only needed when running in week or month mode."
    exit 0
  else
    FORCE="TRUE"
  fi
fi

## Check if first argument is 'close'.
if [ "$1" = "close" -o "$1" = "CLOSE" ]; then
  CLOSE=TRUE
fi

## Generic path check.
if [ ! -d "$glroot$section" ]; then
  echo "MVID WEEK error: $glroot$section does not exist."
  exit 0
fi

## Procedure to check if its the last day of the month.
proc_monthly() {
  if [ "$FORCE" != "TRUE" ]; then
    DAYOFMONTH="$( $datebin +%d )"
    if [ "$DAYOFMONTH" != "01" ]; then
      if [ "$DEBUG" = "TRUE" ]; then
        echo "Not the first day of the month. Daynow is $DAYOFMONTH, not 01. Debug, so continuing."
      else
        exit 0
      fi
    fi
  fi
}

## Procedure to check if its the last day of the week.
proc_weekly() {
 if [ "$FORCE" != "TRUE" ]; then
   DAYNOW="$( $datebin +%w )"
    if [ "$euroweek" = "FALSE" ]; then
      CHECKDAY="0"
    else
      CHECKDAY="1"
    fi
    if [ "$CHECKDAY" != "$DAYNOW" ]; then
      if [ "$DEBUG" = "TRUE" ]; then
        echo "Not the first day of the week. Daynow is $DAYNOW, not $CHECKDAY. Debug, so continuing."
      else
        exit 0
      fi
    fi
  fi
}

## Print this if its in debug mode.
if [ "$DEBUG" = "TRUE" ]; then
  echo "Debug on. Not actually doing anything. Duration is set to '$duration'"
fi

## Procedure for creating a new dated dir.
proc_createnew() {
  ## Check that it dosnt already exist, and quit if so, unless its in debug mode.
  if [ -d "$glroot$section/$TARGET" ]; then
    echo "D-WK-MTH SCRIPT error. $glroot$section/$TARGET already exists."
    if [ "$DEBUG" = "TRUE" ]; then
      echo "Since this is just a test, we'll continue anyway.."
    else
      if [ "$FORCE" != "TRUE" ]; then
        exit 0
      fi
    fi
  fi

  ## Make the actual dir
  if [ "$DEBUG" = "TRUE" ]; then
    echo "Create dir: $glroot$section/$TARGET"
  else
 mkdir "$glroot$section/$TARGET"

    ## Announce stuff.
    ## Remove /site/ from output. Dont want to show that.
    if [ "$gllog" ]; then
      nicename="$( echo "$section" | sed -e 's/\/site\///' )"
      echo `$datebin "+%a %b %e %T %Y"` WEEK: \"$nicename/$TARGET\" \"$OLDTARGET\" \"$sectionname\" >> $gllog
    fi
  fi

  ## Chmod new dir ?
  if [ "$newmod" ]; then
    if [ "$DEBUG" = "TRUE" ]; then
      echo "chmod $newmod $glroot$section/$TARGET"
    else
      chmod $newmod "$glroot$section/$TARGET"
    fi
  fi

  ## Make symlink(s)
  for symlink in $symlinks; do
    unset today
    unset yesterday

    ## Check if theres a : in the symlink, meaning it should use 'yesterday' as well.
    if [ -z "$( echo "$symlink" | grep ':' )" ]; then
      today="$symlink"
    else
      today="$( echo $symlink | cut -d ':' -f1 )"
      yesterday="$( echo $symlink | cut -d ':' -f2 )"
    fi

    ## Move today to yesterday or del it.
    if [ "$yesterday" ]; then
      if [ -L "$glroot$today" ]; then
        if [ "$DEBUG" = "TRUE" ]; then
          echo "Moving $glroot$today to $glroot$yesterday"
        else
          mv -f "$glroot$today" "$glroot$yesterday"
        fi
      fi
    else
     rm -f "$glroot$today"
    fi

    ## Make the new symlink
    if [ "$DEBUG" = "TRUE" ]; then
      echo "Making symlink $glroot$today pointing to .$section/$TARGET"
    else
      ln -f -s ".$section/$TARGET" "$glroot$today"
    fi
  done
}

## Go go. If CLOSE is TRUE, then it was started with argument 'close'
if [ "$CLOSE" != "TRUE" ]; then
  ## Close wasnt specified so creating new dir.

  case $duration in
    [dD][aA][yY]) OLDTARGET="$lastday"; TARGET="$day";;
    [wW][eE][eE][kK]) OLDTARGET="$lastweek"; TARGET="$week"; proc_weekly;;
    [mM][oO][nN][tT][hH]) OLDTARGET="$lastmonth"; TARGET="$month"; proc_monthly;;
    *) echo "D-WK-MTH SCRIPT error. duration not set right (day/week/month)."; exit 0;;
  esac
  proc_createnew
  exit 0

else
  ## Close was specified. Closing last periods dir.

  case $duration in
    [dD][aA][yY]) NEWTARGET="$day"; TARGET="$lastday";;
    [wW][eE][eE][kK]) NEWTARGET="$week"; TARGET="$lastweek";;
    [mM][oO][nN][tT][hH]) NEWTARGET="$month"; TARGET="$lastmonth";;
    *) echo "D-WK-MTH SCRIPT error. duration not set right (day/week/month)."; exit 0;;
  esac

  ## Check if 'old' is set.
  if [ -z "$oldmod" ]; then
    echo "D-WK-MTH SCRIPT error. Set to close last dir, but 'old' is not set."
    exit 0
  else
    if [ ! -d "$glroot$section/$TARGET" ]; then
      echo "D-WK-MTH SCRIPT error. Was going to chmod $oldmod $glroot$section/$TARGET, but dir not found."
      exit 0
    fi
    if [ "$DEBUG" = "TRUE" ]; then
      echo "Setting chmod $oldmod on $glroot$section/$TARGET"
    else
      chmod $oldmod "$glroot$section/$TARGET"

      ## Announce stuffs.
      ## Remove /site/ from output. Dont want to show that.
      if [ "$gllog" ]; then
        nicename="$( echo "$section" | sed -e 's/\/site\///' )"
        echo `$datebin "+%a %b %e %T %Y"` WEEKC: \"$nicename/$TARGET\" \"$NEWTARGET\" \"$sectionname\" >> $gllog
      fi
    fi
  fi

  exit 0

fi

