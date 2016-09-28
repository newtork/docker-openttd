#!/bin/bash
#title           : openttd.wrapper.sh
#description     : This script acts as a STDIN/STDOUT wrapper and provides additional arguments to the server startup routine.
#author		     : newtork / Alexander Dümont
#date            : 2016-09-28
#version         : 0.1
#usage		     : bash openttd.wrapper.sh help
#notes           : required to run inside docker image "newtork/openttd"
#bash_version    : 4.3.42(3)-release
#==============================================================================

#
# Notice:
# -------
# 
# 	$1	=	Save game file, suffix ".sav" is optional
#	$2	=	Additional settings to be written before server start
#	$3	=	Server name setting
#


SAVE_DIR="/root/.openttd/save/"
SAVE_EXT=".sav"
SERVER="/usr/games/openttd"
CONF_UPDATER="cfg.update.sh"

BASENAME="docker run -dit -p 3979:3979/tcp -p 3979:3979/udp newtork/openttd"
#BASENAME=basename $0

if [ "$1" == "help" ]; then
	echo "Usage: `` [ savefile [ settings [ servername ] ] ]

Examples:

 $BASENAME
 Start server with default options and default savegame. Forward required tcp/udp ports. Use interactive but detached terminal.
 
 $BASENAME save1
 Start server with default options and custom savegame.
 
 $BASENAME save2 \"\$(</local/openttd.cfg)\"
 Start server with custom settings from local host file
 
 $BASENAME save3 \"map_x=4 \n map_y=5 \n server_password=p455w03d\" \"My Favorit Server\"
 Start Server with additional map dimension settings, password and custom server name."
	exit 0
fi


# default save file is "save.sav"
savefile="save"	


if [ $# -gt 0 ] ; then savefile=${1%$SAVE_EXT} ; fi
if [ $# -gt 1 ] ; then /root/$CONF_UPDATER "$2"; fi
if [ $# -gt 2 ] ; then /root/$CONF_UPDATER "server_name=$3" ; fi


# start and run fifo pipeline with server
mkfifo myfifa
cat > myfifa &
pid_cat=$!
setsid $SERVER -D < myfifa &
pid_ottd=$!

# get server status, 0=running, 1=terminated
running() {
	if ps -p $pid_ottd > /dev/null
	then return 0
	else return 1
	fi
}

# trap function to execute commands after CTRL-C
savelyexit() {
	if running ; then
		echo "save $savefile" > myfifa
		echo "quit" > myfifa
	fi

	kill $pid_cat &> /dev/null
	rm -f myfifa
	
	# sleep for short period of time to let trap quit smoothly
	sleep 1
	exit 0
}
trap savelyexit SIGINT SIGTERM EXIT
# additional signals could be INT SIGHUP

# load game if save file is already existing
if [ -e "$SAVE_DIR$savefile$SAVE_EXT" ]
	then echo "load $savefile$SAVE_EXT" > myfifa ; echo "Loading game..."
	else echo "Started new save game: $savefile"
fi

# check whether server has started and is still running
if running
then

	# read from stdin and redirect to fifo pipe while server is running
	while read line && running
	do echo "$line" > myfifa
	done < /dev/stdin
fi

exit 0