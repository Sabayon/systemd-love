#!/bin/sh

if [ -e /run/openrc/softlevel ]; then
	# openrc booted the system
	# TODO: how to detect if logind is already started
	# with openrc?
	/usr/bin/rc-config start logind  # ignore failures
	exit 0
else
	# systemd booted the system, the original executable
	# is just /bin/false.
	exec /bin/false
fi
