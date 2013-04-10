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

# @ECLASS-VARIABLE: DEFAULT_SETTINGSD
# @DESCRIPTION:
# # Current distribution default settingsd implementation
DEFAULT_SETTINGSD="openrc"

# FUNCTION: pkg_settingsd_setup
# @USAGE: pkg_settingsd_setup
# DESCRIPTION:
# This function must be called by every ebuild installing a settingsd
# implementation and configures the initial implementation by calling
# eselect settingsd. It must be called in pkg_postinst, pkg_prerm, pkg_postrm.
pkg_settingsd_setup() {
	"${ROOT}"/usr/bin/eselect settingsd set "${DEFAULT_SETTINGSD}" --use-old
}

# FUNCTION: settingsd_setup_install
# @USAGE: settingsd_setup_install
# DESCRIPTION:
# Setup files in ${D} for eselect-settingsd support purposes.
# settingsd services will be moved from /usr/share/{dbus-1,polkit-1}
# to ${SETTINGSD_DIR}/${SETTINGSD_NAME} so that users will be able
# to switch between them at runtime.
settingsd_setup_install() {
	local settingsd_dir="${SETTINGSD_DIR}/${SETTINGSD_NAME}"
	local services=( hostname1 locale1 timedate1 )
	local srv=
	local s=
	local d=

	# add support for eselect settingsd, rename paths
	# intersection between openrc-settingsd and systemd:
	# /usr/share/dbus-1/interfaces/org.freedesktop.hostname1.xml
	# /usr/share/dbus-1/interfaces/org.freedesktop.locale1.xml
	# /usr/share/dbus-1/interfaces/org.freedesktop.timedate1.xml
	# /usr/share/dbus-1/system-services/org.freedesktop.hostname1.service
	# /usr/share/dbus-1/system-services/org.freedesktop.locale1.service
	# /usr/share/dbus-1/system-services/org.freedesktop.timedate1.service
	# /usr/share/polkit-1/actions/org.freedesktop.hostname1.policy
	# /usr/share/polkit-1/actions/org.freedesktop.locale1.policy
	# /usr/share/polkit-1/actions/org.freedesktop.timedate1.policy

	dodir "/${settingsd_dir}"

	for srv in "${services[@]}"; do
		# dbus interfaces
		s="/usr/share/dbus-1/interfaces/org.freedesktop.${srv}.xml"
		d="/${settingsd_dir}${s}"
		dodir $(dirname "${d}")
		einfo "eselect-settingsd: moving ${s} to ${d}"
		mv "${D}${s}" "${D}${d}" || die \
			"${s} not found, something is broken"

		# dbus system-services
		s="/usr/share/dbus-1/system-services/org.freedesktop.${srv}.service"
		d="/${settingsd_dir}${s}"
		dodir $(dirname "${d}")
		einfo "eselect-settingsd: moving ${s} to ${d}"
		mv "${D}${s}" "${D}${d}" || \
			die "${s} not found, something is broken"

		# polkit actions
		s="/usr/share/polkit-1/actions/org.freedesktop.${srv}.policy"
		d="/${settingsd_dir}${s}"
		dodir $(dirname "${d}")
		einfo "eselect-settingsd: moving ${s} to ${d}"
		mv "${D}${s}" "${D}${d}" \
			|| die "${s} not found, something is broken"
	done
}