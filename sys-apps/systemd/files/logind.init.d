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
	export SYSTEMD_LOG_TARGET=syslog
	checkpath -d -o root:root -m 0755 /run/systemd
	if ! mountpoint -q /sys/fs/cgroup/systemd; then
		checkpath -d -o root:root -m 0755 /sys/fs/cgroup/systemd
		mount -t cgroup -o nosuid,noexec,nodev,none,name=systemd systemd /sys/fs/cgroup/systemd
	fi
}
