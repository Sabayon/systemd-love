# Copyright 1999-2013 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit init

SRC_URI=""
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"

DESCRIPTION="Eselect module for switching between /sbin/init implementations"
HOMEPAGE="http://www.sabayon.org"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

S="${WORKDIR}"

RDEPEND="app-admin/eselect"
DEPEND="${RDEPEND}"

src_install() {
	cp "${FILESDIR}/init-${PV}.eselect" init.eselect || die "cannot copy init.eselect"
	sed -i "s:%INITS_DIR%:${INITS_DIR}:" init.eselect || die "cannot setup INITS_DIR"
	sed -i "s:%INIT_DIR%:${INIT_DIR}:" init.eselect || die "cannot setup INIT_DIR"
	sed -i "s:%INIT_PARTS%:${INIT_PARTS}:" init.eselect || die "cannot setup INIT_PARTS"

	insinto /usr/share/eselect/modules
	doins init.eselect
}
