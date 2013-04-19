#!/bin/sh
# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ret=0 opts="${1}"
shift
for c in $(cpufreq-info -o | awk '$1 == "CPU" { print $2 }') ; do
	cpufreq-set -c ${c} ${opts}
	: $(( ret += $? ))
done

if [ $# -gt 0 ] ; then
	c=1
	if cd /sys/devices/system/cpu/cpufreq ; then
		for o in "${@}"; do
			v=${o#*=}
			o=${o%%=*}
			echo ${v} > ${o} || break
		done
		c=0
	fi
	: $(( ret += c ))
fi

exit ${ret}
