# Copyright 2004-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $

# @ECLASS-VARIABLE: SYSVINIT_DIR
# @DESCRIPTION:
# Directory where eselect sysvinit must install the symlinks, from INITS_DIR.
# This directory must be a parent of SYSVINITS_DIR.
SYSVINIT_DIR="sbin"

# @ECLASS-VARIABLE: SYSVINITS_DIR
# @DESCRIPTION:
# Directory where eselect-able sysvinit implementations must install their
# own executables, it must be prefixed with ${ROOT}. This variable
# is shared with the eselect-sysvinit module. This directory must contain
# only directories, whose names are the name of the sysvinit implementation.
SYSVINITS_DIR="${SYSVINIT_DIR}/init.d"

# @ECLASS-VARIABLE: SYSVINIT_NAME
# @DESCRIPTION:
# Name of the sysvinit implementation that is being installed/removed.
SYSVINIT_NAME="${SYSVINIT_NAME:-${PN}}"

# @ECLASS-VARIABLE: DEFAULT_SYSVINIT
# @DESCRIPTION:
# Current distribution default sysvinit implementation
DEFAULT_SYSVINIT="sysvinit"

# @ECLASS-VARIABLE: SYSVINIT_PARTS
# @DESCRIPTION:
# List of sysvinit executables that must be placed inside ${SYSVINITS_DIR}/${PN}
SYSVINIT_PARTS="halt init poweroff reboot"

# FUNCTION: pkg_sysvinit_setup
# @USAGE: pkg_sysvinit_setup
# DESCRIPTION:
# This function must be called by every ebuild installing an sysvinit
# implementation and configures the initial symlinks by calling
# eselect sysvinit. It must be called in pkg_postinst, pkg_prerm, pkg_postrm.
pkg_sysvinit_setup() {
	"${ROOT}"/usr/bin/eselect sysvinit set "${DEFAULT_SYSVINIT}" --use-old
}
