#!/bin/sh

if [ -e /run/openrc/softlevel ]; then
	# openrc booted the system, do not hide possible ENOENT
	exec /usr/libexec/systemd-shim
else
	# systemd booted the system, the original executable
	# is just /bin/false.
	exec /bin/false
fi
