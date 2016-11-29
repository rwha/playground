# Get a sane screen width
[ -z "${COLUMNS:-}" ] && COLUMNS=80

[ -z "${CONSOLETYPE:-}" ] && CONSOLETYPE="`/sbin/consoletype`"

if [ -f /etc/sysconfig/i18n -a -z "${NOLOCALE:-}" ] ; then
	. /etc/profile.d/lang.sh
fi

# Read in our configuration
if [ -z "${BOOTUP:-}" ]; then
	if [ -f /etc/sysconfig/init ]; then
		. /etc/sysconfig/init
	else
		# This all seem confusing? Look in /etc/sysconfig/init,
		# or in /usr/doc/initscripts-*/sysconfig.txt
		BOOTUP=color
		RES_COL=60
		MOVE_TO_COL="echo -en \\033[${RES_COL}G"
		SETCOLOR_SUCCESS="echo -en \\033[1;32m"
		SETCOLOR_FAILURE="echo -en \\033[1;31m"
		SETCOLOR_WARNING="echo -en \\033[1;33m"
		SETCOLOR_NORMAL="echo -en \\033[0;39m"
		LOGLEVEL=1
	fi
	if [ "$CONSOLETYPE" = "serial" ]; then
		BOOTUP=serial
		MOVE_TO_COL=
		SETCOLOR_SUCCESS=
		SETCOLOR_FAILURE=
		SETCOLOR_WARNING=
		SETCOLOR_NORMAL=
	fi
fi

echo_success() {
	[ "$BOOTUP" = "color" ] && $MOVE_TO_COL
	echo -n "["
	[ "$BOOTUP" = "color" ] && $SETCOLOR_SUCCESS
	echo -n $"  OK  "
	[ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
	echo -n "]"
	echo -ne "\r"
	return 0
}

echo_failure() {
	[ "$BOOTUP" = "color" ] && $MOVE_TO_COL
	echo -n "["
	[ "$BOOTUP" = "color" ] && $SETCOLOR_FAILURE
	echo -n $"FAILED"
	[ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
	echo -n "]"
	echo -ne "\r"
	return 1
}

echo_warning() {
	[ "$BOOTUP" = "color" ] && $MOVE_TO_COL
	echo -n "["
	[ "$BOOTUP" = "color" ] && $SETCOLOR_WARNING
	echo -n $"WARNING"
	[ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
	echo -n "]"
	echo -ne "\r"
	return 0
}
