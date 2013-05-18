#!/bin/bash
# sysvinit exec wrapper that redirects the calls
# to the currently running sysvinit implementation if
# /run/running.sysvinit is found.
# Call this from your sysvinit command part, with the
# following arguments:
# /sbin/init.d/exec.sh "<command name>" <exec and args to call>

. /usr/share/eselect/modules/sysvinit.eselect

COMMAND="${1}"
shift

if [ -f "${RUNNING_INIT}" ]; then
	running=$(cat "${RUNNING_INIT}")
	cmd_path="${INITS_DIR}/${running}/${COMMAND}"
	if [ -x "${cmd_path}" ] && [ -n "${running}" ]; then
		exec "${cmd_path}"
	fi
	if [ -z "${running}" ]; then
		echo "Cannot determine the currently running sysvinit" >&2
	fi
	if [ ! -x "${cmd_path}" ]; then
		echo "${cmd_path} not found, cannot redirect" >&2
	fi
fi

exec "${@}"
