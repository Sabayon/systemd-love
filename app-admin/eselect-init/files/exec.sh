#!/bin/sh
# /sbin/init-exec.sh is a wrapper that can be used
# to call the currently running /sbin/init implementation.

# Keep in sync with the eselect module
RUNNING_INIT="/run/.eselect-init.run"

WRAPPING_COMMAND=$(readlink "${0}")
COMMAND_DIR=$(dirname "${WRAPPING_COMMAND}")
COMMAND_NAME=$(basename "${WRAPPING_COMMAND}")

# Symlinks above may be relative to "${0}" directory
cd "$(dirname "${0}")" || exit 1

# Redirect calls?
if [ -f "${RUNNING_INIT}" ]; then
	RUNNING_COMMAND_DIR=$(cat "${RUNNING_INIT}" 2>/dev/null)
	RUNNING_FINAL_COMMAND="${RUNNING_COMMAND_DIR}/final/${COMMAND_NAME}"
	# /run may have not been cleared
	if [ -x "${RUNNING_FINAL_COMMAND}" ]; then
		# redirect
		exec "${RUNNING_FINAL_COMMAND}" "${@}"
	else
		echo "${RUNNING_FINAL_COMMAND} not found" >&2
		echo "Ignoring ${RUNNING_INIT} content" >&2
		# fall through
	fi
fi

FINAL_COMMAND="${COMMAND_DIR}/final/${COMMAND_NAME}"
exec "${FINAL_COMMAND}" "${@}"
