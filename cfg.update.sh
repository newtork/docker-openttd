#!/bin/bash
#title           : cfg.update.sh
#description     : This script updates a config file, by replacing lines of matching keys
#author		     : newtork / Alexander Dümont
#date            : 2016-09-28
#version         : 0.1
#usage		     : bash cfg.update.sh "hello=world"
#notes           : required to run inside docker image "newtork/openttd"
#bash_version    : 4.3.42(3)-release
#==============================================================================


# Notice:
# -------
# 
# 	$1	=	configuration updates file or string

# target definition
DEFAULT_LOCATION_CONFIG="/root/.openttd/openttd.cfg"


# if it is an existing file, read inputs
input=$1
if [ -e "$input" ]
then input="$(<$input)"
fi


#options
key_allowed="A-Za-z_-"
key_delimiter="\s*="

# Read only clean parameter definitions and trim leading whitespaces
lines=$(printf "$input" | sed "s/^[ \t]*//" | grep -E "^\s*[$key_allowed]+$key_delimiter")

# iterate $line = "key = value"
while read -r line
do
	# Get key from parameter item
	key=$(echo $line | sed -n "s/^\([][$key_allowed]*\).*/\1/p")
	
	# Escape the line for "sed"-usage	
	item=$(echo $line | sed -r "s/[\\/&]/\\\\&/g")

	# Replace any possibly multiple occurrence of fitting parameter key line with updated parameter line
	# Overwrite old configuration file
	sed -i "s/^$key$key_delimiter.*$/$item/g" $DEFAULT_LOCATION_CONFIG
done <<< "$lines"
