# Copyright 2004-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $

# @ECLASS-VARIABLE: SETTINGSD_DIR
# @DESCRIPTION:
# Directory where eselect settingsd must install root directory trees
# whose files will be symlinked onto the real system. It must be prefixed
# with ${ROOT}.
SETTINGSD_DIR="usr/lib/eselect-settingsd"

# @ECLASS-VARIABLE: SETTINGSD_NAME
# @DESCRIPTION:
# Name of the settingsd implementation that is being installed/removed.
SETTINGSD_NAME="${SETTINGSD_NAME:-${PN}}"

# FUNCTION: pkg_settingsd_setup
# @USAGE: pkg_settingsd_setup
# DESCRIPTION:
# This function must be called by every ebuild installing a settingsd
# implementation and configures the initial implementation by calling
# eselect settingsd. It must be called in pkg_postinst, pkg_prerm, pkg_postrm.
pkg_settingsd_setup() {
	"${ROOT}"/usr/bin/eselect settingsd set "${SETTINGSD_NAME}" --use-old
}

