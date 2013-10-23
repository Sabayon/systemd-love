# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eselect-init

SRC_URI=""
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"

DESCRIPTION="Eselect module for switching between /sbin/init implementations"
HOMEPAGE="http://www.gentoo.org"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

S="${WORKDIR}"

RDEPEND="app-admin/eselect
	sys-apps/coreutils"
DEPEND="${RDEPEND}"

src_install() {
	cp "${FILESDIR}/init-${PV}.eselect" init.eselect || die "cannot copy sysvinit.eselect"
	sed -i "s:%INITS_DIR%:${INITS_DIR}:" init.eselect || die "cannot setup INITS_DIR"
	sed -i "s:%INIT_DIR%:${INIT_DIR}:" init.eselect || die "cannot setup INIT_DIR"
	sed -i "s:%INIT_PARTS%:${INIT_PARTS}:" init.eselect || die "cannot setup INIT_PARTS"

	insinto /usr/share/eselect/modules
	doins init.eselect
	dosym init.eselect /usr/share/eselect/modules/sysvinit.eselect
	# backward compatibility with the old "sysvinit" name
	exeinto /sbin/init.d
	doexe "${FILESDIR}"/exec.sh
}

pkg_postinst() {
	eselect-init_setup
}
