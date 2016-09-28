#!/bin/bash
#title           : dl.checked.sh
#description     : This script reads a link from provided url, downloads a matching item link and verifies its checksum
#author		     : newtork / Alexander Dümont
#date            : 2016-09-28
#version         : 0.1
#usage		     : bash dl.checked.sh "https://example.org/list/" "//div[contains(@id, 'download')]" /tmp/a.txt
#notes           : matching item needs to contain a "sha256sum 0123456789abcdf..." checksum
#bash_version    : 4.3.42(3)-release
#==============================================================================

#
# Notice:
# -------
# 
# 	$1	=	source download#
# 	$2 	=	html item xpath
#	$3	=	file destination
#

item_html=$(curl -s "$1" | xmllint --noout --html --xpath "$2" - 2>/dev/null)


# read checksum from html item
item_checksum=$(echo $item_html | sed -n 's/.*sha256sum\W\+\([0-9a-f]\{64\}\).*/\1/p')

# read first valid link from html item
item_link=$(echo $item_html | xmllint --html --xpath "string(//a[@href][1]/@href)" - 2>/dev/null)

# download item to temporary destination
item_temp=$(mktemp)
curl -L -s -o $item_temp "https:$item_link"

# validate checksum
if [[ 0 -eq $( echo $item_checksum $item_temp | sha256sum -c | grep -q "OK" ; echo $?) ]] ; then
        mv $item_temp $3
else
        rm $item_temp
        echo "Checksum validation failed. The downloaded file has been removed."
        exit 1
fi