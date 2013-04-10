# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

SETTINGSD_NAME="openrc"
inherit settingsd

DESCRIPTION="System settings D-Bus service for OpenRC"
HOMEPAGE="http://gnome.gentoo.org/openrc-settingsd.xml"
SRC_URI="http://dev.gentoo.org/~tetromino/distfiles/${PN}/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

COMMON_DEPEND=">=dev-libs/glib-2.30:2
	dev-libs/libdaemon
	sys-apps/dbus
	sys-apps/openrc:=
	sys-auth/polkit"
RDEPEND="${COMMON_DEPEND}
	app-admin/eselect-settingsd
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
	settingsd_setup_install
}

pkg_preinst() {
	pkg_settingsd_setup
}

pkg_postinst() {
	pkg_settingsd_setup
}

pkg_prerm() {
	pkg_settingsd_setup
}

pkg_postrm() {
	pkg_settingsd_setup
}

