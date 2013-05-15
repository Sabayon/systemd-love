#!/sbin/runscript
# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

command="/usr/lib/systemd/systemd-logind"
start_stop_daemon_args="--quiet --background"
description="Login Service and ConsoleKit replacement"

depend() {
	need dbus
	use logger
	before xdm
	after tmpfiles.setup
}

start_pre() {
	checkpath -d -o root:root -m 0755 /run/systemd
}
