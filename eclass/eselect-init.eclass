# Copyright 2004-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $

#
# Assumption: the "init" variable of /sbin/init can be changed
# via ${ESELECT_INIT_EXEC_NAME}. If unset, the default value is "init".
# This documentation assumes that ${ESELECT_INIT_EXEC_NAME}="init".
#
# Wrapping a /sbin/init is tricky. Firstly, we want to minimize the
# amount of wrapper code required at runtime, because less code means
# less bugs and failures.
# This eclass supports wrapping more than just /sbin/init, but for now
# this is all it offers.
#
# Below is the explanation of how eselect-init compatible init systems
# work:
#
# /sbin/init is managed by the eselect-init module and consists of a
# symlink.
# The symlink /sbin/init points to is the wrapper script for the given
# selected init implementation. For instance, if the system is configured
# to use systemd, /sbin/init will point to /sbin/init.d/systemd/init.
# eselect-init compatible init systems shall install their wrapper scripts
# into /sbin/init.d/<init impl>/ and their wrapped executables into
# /sbin/init.d/<init impl>/final/.
# At first, this may sound a bit odd (the double symlink level) but is
# for a reason: the init wrapper script is just one simple piece of code,
# /sbin/init.d/exec.sh, which gets symlinked into
# /sbin/init.d/<init impl>/init. exec.sh will detect what is the currently
# running init system and the implementation for which it's been called for
# in a simple way: it resolves itself (${0}) using /usr/bin/readlink.
# The currently running init system is the one /sbin/init points to unless
# /run/.eselect-init.run exists. This /run trick is used to redirect calls
# to /sbin/init to the currently running init system (so that you can reboot
# your system reliably).
# Have a look at the example below:
#
# Scenario: the system is configured to boot systemd.
# /sbin/init points to /sbin/init.d/systemd/init.
#
# When /sbin/init is called, the following happens:
# 1. /sbin/init points to /sbin/init.d/systemd/init and the shell
#    interpreter gets there.
# 2. /sbin/init.d/systemd/init points to /sbin/init.d/exec.sh, which
#    is a regular executable file.
# 3. /sbin/init.d/exec.sh gets executed.
# 4. /sbin/init.d/exec.sh determines the caller implementation by
#    resolving the itself (${0} is /sbin/init !) to /sbin/init.d/systemd/init.
# 5. /sbin/init.d/exec.sh determines if /run/.eselect-init.run exists, which
#    is expected to contain the currently running init implementation
#    (/sbin/init.d/systemd).
# 6. if /run/.eselect-init.run does not exist, /sbin/init.d/exec.sh executes
#    /sbin/init.d/systemd/final/init directly using exec <path> "${@}".
# 7. if /run/.eselect-init.run does exist, /sbin/init.d/exec.sh rewrites
#    the path to the final init executable and executes it: exec <new path> "${@}".

# @ECLASS-VARIABLE: INIT_DIR
# @DESCRIPTION:
# Directory where eselect init must install the symlinks, from INITS_DIR.
# This directory must be a parent of INITS_DIR.
INIT_DIR="sbin"

# @ECLASS-VARIABLE: ESELECT_INIT_EXEC_NAME
# @DESCRIPTION:
# The executable name inside /sbin to handle as part of eselect-init, by
# default it is "init". Please rebuild eselect-init and all its direct
# reverse dependencies if you plan to change it.
ESELECT_INIT_EXEC_NAME="${ESELECT_INIT_EXEC_NAME:-init}"

# @ECLASS-VARIABLE: INITS_DIR
# @DESCRIPTION:
# Directory where eselect-able init implementations must install their
# own executable wrappers, it must be prefixed with ${ROOT}. This variable
# is shared with the eselect-init module. This directory must contain
# only directories, whose names are the name of the init implementation.
INITS_DIR="${INIT_DIR}/init.d"

# @ECLASS-VARIABLE: INITS_REAL_DIR
# @DESCRIPTION:
# Directory name inside ${INITS_DIR}/${INIT_NAME} where to place real
# executable files that shall be called by the wrappers in the parent
# directory.
INITS_REAL_DIR_NAME="final"

# @ECLASS-VARIABLE: INIT_NAME
# @DESCRIPTION:
# Name of the init implementation that is being installed/removed.
INIT_NAME="${INIT_NAME:-${PN}}"

# @ECLASS-VARIABLE: DEFAULT_INIT
# @DESCRIPTION:
# Current distribution default init implementation
DEFAULT_INIT="sysvinit"

# @ECLASS-VARIABLE: INIT_PARTS
# @DESCRIPTION:
# List of init executables that must be placed inside ${INITS_DIR}/${PN}
INIT_PARTS="${ESELECT_INIT_EXEC_NAME}"

# FUNCTION: eselect-init_setup
# @USAGE: eselect-init_setup
# DESCRIPTION:
# This function must be called by every ebuild installing an init
# implementation and configures the initial symlinks by calling
# eselect init. It must be called in pkg_postinst, pkg_prerm, pkg_postrm.
eselect-init_setup() {
	"${ROOT}"/usr/bin/eselect init set "${DEFAULT_INIT}" --use-old
}
