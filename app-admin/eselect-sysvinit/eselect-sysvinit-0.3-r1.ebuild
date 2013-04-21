# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit sysvinit

SRC_URI=""
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"

DESCRIPTION="Eselect module for switching between sysvinit implementations"
HOMEPAGE="http://www.gentoo.org"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

S="${WORKDIR}"

RDEPEND="app-admin/eselect"
DEPEND="${RDEPEND}"

src_install() {
	cp "${FILESDIR}/sysvinit-${PV}.eselect" sysvinit.eselect || die "cannot copy sysvinit.eselect"
	sed -i "s:%INITS_DIR%:${SYSVINITS_DIR}:" sysvinit.eselect || die "cannot setup INITS_DIR"
	sed -i "s:%INIT_DIR%:${SYSVINIT_DIR}:" sysvinit.eselect || die "cannot setup INIT_DIR"
	sed -i "s:%INIT_PARTS%:${SYSVINIT_PARTS}:" sysvinit.eselect || die "cannot setup INIT_PARTS"

	insinto /usr/share/eselect/modules
	doins sysvinit.eselect
	exeinto /sbin/init.d
	doexe "${FILESDIR}"/exec.sh
}

pkg_postinst() {
	pkg_sysvinit_setup
}
