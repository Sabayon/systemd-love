#!/bin/sh

if [ -e /run/openrc/softlevel ]; then
	# openrc booted the system, redirect the call to
	# openrc-settingsd
	exec /usr/libexec/openrc-settingsd --update-rc-status
else
	# default to the original systemd executable
	exec /bin/false
fi
