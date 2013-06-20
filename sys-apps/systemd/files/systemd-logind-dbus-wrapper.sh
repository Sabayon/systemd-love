#!/bin/sh

if [ -e /run/openrc/softlevel ]; then
	# openrc booted the system
	# TODO: how to detect if logind is already started
	# with openrc?
	exec /usr/lib/systemd/systemd-logind
else
	# systemd booted the system, the original executable
	# is just /bin/false.
	exec /bin/false
fi
