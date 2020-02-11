#! /bin/sh

### CODE ###

if [ "$1" = "sitecmd" ]; then 
        dirpath="/bin"
else
        dirpath="/glftpd/bin"
fi

# find affil list in dirscript for each section
dirscripts="
$dirpath/dirscript_mp3.sh:MP3
$dirpath/dirscript_flac.sh:FLAC
$dirpath/dirscript_mvid.sh:MVID
"

for dirscript in $dirscripts; do
        filename=$(echo $dirscript | awk -F: '{print $1}')
        section=$(echo $dirscript | awk -F: '{print $2}')
        affillist=$(cat $filename | grep ^AFFILS= | awk -F= '{print $2}' | tr -d "\"" | tr " " "\n" | sort -u | tr "\n" " ")
	number=$(echo $affillist | wc -w)

if [ "$1" = "sitecmd" ]; then 
        echo "${section} -> $affillist(${number})"
else
        echo "\002\00037${section}\002\003 -> $affillist(${number})"
fi
done

exit 0
