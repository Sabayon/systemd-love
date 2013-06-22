# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="System settings D-Bus service for OpenRC"
HOMEPAGE="http://gnome.gentoo.org/openrc-settingsd.xml"
SRC_URI="http://dev.gentoo.org/~tetromino/distfiles/${PN}/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="systemd"

COMMON_DEPEND=">=dev-libs/glib-2.30:2
	dev-libs/libdaemon
	sys-apps/dbus
	sys-apps/openrc:=
	sys-auth/polkit"
RDEPEND="${COMMON_DEPEND}
	systemd? ( >=sys-apps/systemd-204-r6[openrc] )
	|| ( sys-auth/nss-myhostname >=sys-apps/systemd-197 )"
DEPEND="${COMMON_DEPEND}
	app-arch/xz-utils
	dev-util/gdbus-codegen
	virtual/pkgconfig"

src_configure() {
	econf \
		--with-pidfile="${EPREFIX}"/var/run/openrc-settingsd.pid
}

src_install() {
	default

	if use systemd; then
		elog "Removing dbus and polkit configuration files shared with systemd."
		elog "systemd is expected to be used as device manager and settingsd dbus"
		elog "services provider. In case of openrc booting the system, openrc-settingsd"
		elog "will be the implementation used by org.freedestkop.{hostname1,locale1,timedate1}."
		for name in hostname1 locale1 timedate1; do
			rm "${ED}"/usr/share/dbus-1/interfaces/org.freedesktop.${name}.xml || die
			rm "${ED}"/usr/share/dbus-1/system-services/org.freedesktop.${name}.service || die
			rm "${ED}"/usr/share/polkit-1/actions/org.freedesktop.${name}.policy || die
		done
	fi
}
