#!/sbin/runscript
# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

command="/usr/lib/systemd/systemd-logind"
start_stop_daemon_args="--quiet --background"
description="Login Service and ConsoleKit replacement"

depend() {
	need dbus udev-mount
	use logger
	after tmpfiles.setup
}
