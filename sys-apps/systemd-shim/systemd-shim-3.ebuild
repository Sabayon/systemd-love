# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="A systemd emulation layer for Gentoo running with OpenRC"
HOMEPAGE="https://github.com/desrt/systemd-shim"
SRC_URI="mirror://sabayon/sys-apps/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="systemd"  # if systemd is used as device manager

DEPEND=">=dev-libs/glib-2.36:2"
RDEPEND="${DEPEND}
	sys-power/pm-utils
	systemd? ( sys-apps/systemd )"

src_prepare() {
	epatch "${FILESDIR}/0001-Move-all-the-debian-specific-ntp-calls-to-macros.patch"
	epatch "${FILESDIR}/0002-Make-ntp-unit.c-work-in-a-Gentoo-OpenRC-system.patch"
	default
}

src_install() {
	default
	if use systemd; then
		# drop files provided by systemd
		rm "${D}"/etc/dbus-1/system.d/org.freedesktop.systemd1.conf || die
		rm "${D}"/usr/share/dbus-1/system-services/org.freedesktop.systemd1.service || die
	fi
}
