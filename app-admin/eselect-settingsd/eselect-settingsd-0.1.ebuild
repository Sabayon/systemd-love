# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit settingsd

SRC_URI=""
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"

DESCRIPTION="Eselect module for switching between settingsd implementations"
HOMEPAGE="http://www.gentoo.org"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

S="${WORKDIR}"

RDEPEND="app-admin/eselect
	sys-apps/findutils"
DEPEND="${RDEPEND}"

src_install() {
	dodir /etc/env.d/eselect-settingsd
	keepdir /etc/env.d/eselect-settingsd
	cp "${FILESDIR}/settingsd-${PV}.eselect" \
		settingsd.eselect || die "cannot copy settingsd.eselect"
	sed -i "s:%SETTINGSD_DIR%:${SETTINGSD_DIR}:" \
		settingsd.eselect || die "cannot setup SETTINGSD_DIR"
	insinto /usr/share/eselect/modules
	doins settingsd.eselect
}
