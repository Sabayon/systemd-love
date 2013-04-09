# Copyright 2004-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $

# @ECLASS-VARIABLE: INIT_DIR
# @DESCRIPTION:
# Directory where eselect init must install the symlinks, from INITS_DIR.
# This directory must be a parent of INITS_DIR.
INIT_DIR="sbin"

# @ECLASS-VARIABLE: INITS_DIR
# @DESCRIPTION:
# Directory where eselect-able init implementations must install their
# own executables, it must be prefixed with ${ROOT}. This variable
# is shared with the eselect-init module. This directory must contain
# only directories, whose names are the name of the init implementation.
INITS_DIR="${INIT_DIR}/init.d"

# @ECLASS-VARIABLE: INIT_NAME
# @DESCRIPTION:
# Name of the init implementation that is being installed/removed.
INIT_NAME="${INIT_NAME:-${PN}}"

# @ECLASS-VARIABLE: INIT_PARTS
# @DESCRIPTION:
# List of init executables that must be placed inside ${INITS_DIR}/${PN}
INIT_PARTS="halt init poweroff reboot"

# FUNCTION: pkg_init_setup
# @USAGE: pkg_init_setup
# DESCRIPTION:
# This function must be called by every ebuild installing an init
# implementation and configures the initial symlinks by calling
# eselect init. It must be called in pkg_postinst, pkg_prerm, pkg_postrm.
pkg_init_setup() {
	"${ROOT}"/usr/bin/eselect init set --use-old "${INIT_NAME}"
}
