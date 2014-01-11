# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils toolchain-funcs flag-o-matic eselect-init

DESCRIPTION="/sbin/init - parent of all processes"
HOMEPAGE="http://savannah.nongnu.org/projects/sysvinit"
SRC_URI="mirror://nongnu/${PN}/${P}dsf.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="selinux ibm static kernel_FreeBSD"

RDEPEND="selinux? ( >=sys-libs/libselinux-1.28 )
	>=app-admin/eselect-init-0.5"
DEPEND="${RDEPEND}
	virtual/os-headers"

S=${WORKDIR}/${P}dsf

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.86-kexec.patch #80220
	epatch "${FILESDIR}"/${PN}-2.86-shutdown-single.patch #158615
	epatch "${FILESDIR}"/${P}-makefile.patch #319197
	epatch "${FILESDIR}"/${P}-selinux.patch #326697
	epatch "${FILESDIR}"/${P}-shutdown-h.patch #449354
	sed -i '/^CPPFLAGS =$/d' src/Makefile || die

	# eselect-init support, rename INIT #define
	sed -i "/^#define INIT/ s:/sbin/init:/${INITS_DIR}/${INIT_NAME}/${INITS_REAL_DIR_NAME}/init:" \
		"${S}/src/paths.h" || die "cannot replace /sbin/init path"
	sed -i "/^#define PATH_DEFAULT/ s;/sbin:;/${INITS_DIR}/${INIT_NAME}/${INITS_REAL_DIR_NAME}:/sbin:;" \
		"${S}/src/init.h" || die "cannot replace /sbin/init path"

	# mesg/mountpoint/sulogin/utmpdump/wall have moved to util-linux
	sed -i -r \
		-e '/^(USR)?S?BIN/s:\<(mesg|mountpoint|sulogin|utmpdump|wall)\>::g' \
		-e '/^MAN[18]/s:\<(mesg|mountpoint|sulogin|utmpdump|wall)[.][18]\>::g' \
		src/Makefile || die

	# pidof has moved to >=procps-3.3.9
	sed -i -r \
		-e '/\/bin\/pidof/d' \
		-e '/^MAN8/s:\<pidof.8\>::g' \
		src/Makefile || die

	# Mung inittab for specific architectures
	cd "${WORKDIR}"
	cp "${FILESDIR}"/inittab-2.87 inittab || die "cp inittab"
	local insert=()
	use ppc && insert=( '#psc0:12345:respawn:/sbin/agetty 115200 ttyPSC0 linux' )
	use arm && insert=( '#f0:12345:respawn:/sbin/agetty 9600 ttyFB0 vt100' )
	use hppa && insert=( 'b0:12345:respawn:/sbin/agetty 9600 ttyB0 vt100' )
	use s390 && insert=( 's0:12345:respawn:/sbin/agetty 38400 console' )
	if use ibm ; then
		insert+=(
			'#hvc0:2345:respawn:/sbin/agetty -L 9600 hvc0'
			'#hvsi:2345:respawn:/sbin/agetty -L 19200 hvsi0'
		)
	fi
	(use arm || use mips || use sh || use sparc) && sed -i '/ttyS0/s:#::' inittab
	if use kernel_FreeBSD ; then
		sed -i \
			-e 's/linux/cons25/g' \
			-e 's/ttyS0/cuaa0/g' \
			-e 's/ttyS1/cuaa1/g' \
			inittab #121786
	fi
	if use x86 || use amd64 ; then
		sed -i \
			-e '/ttyS[01]/s:9600:115200:' \
			inittab
	fi
	if [[ ${#insert[@]} -gt 0 ]] ; then
		printf '%s\n' '' '# Architecture specific features' "${insert[@]}" >> inittab
	fi
}

src_compile() {
	local myconf

	tc-export CC
	append-lfs-flags
	export DISTRO= #381311
	use static && append-ldflags -static
	use selinux && myconf=WITH_SELINUX=yes
	emake -C src ${myconf} || die
}

src_install() {
	emake -C src install ROOT="${D}"
	dodoc README doc/*

	insinto /etc
	doins "${WORKDIR}"/inittab

	doinitd "${FILESDIR}"/{reboot,shutdown}.sh

	# add support for eselect init, rename paths
	local init_dir="${INITS_DIR}/${INIT_NAME}"
	local parts=( ${INIT_PARTS} )
	dodir "/${init_dir}/${INITS_REAL_DIR_NAME}"
	for part in "${parts[@]}"; do
		mv "${D}/${INIT_DIR}/${part}" "${D}/${init_dir}/${INITS_REAL_DIR_NAME}/${part}" || die
		ln -s "../exec.sh" "${D}/${init_dir}/${part}" || die
	done
}

pkg_postinst() {
	eselect-init_setup

	# Reload init to fix unmounting problems of / on next reboot.
	# This is really needed, as without the new version of init cause init
	# not to quit properly on reboot, and causes a fsck of / on next reboot.
	if [[ ${ROOT} == / ]] ; then
		# Do not return an error if this fails
		/sbin/telinit U &>/dev/null
	fi

	elog "The mesg/mountpoint/sulogin/utmpdump/wall tools have been moved to sys-apps/util-linux."
	elog "The pidof tool has been moved to sys-apps/procps."
}

pkg_prerm() {
	eselect-init_setup
}

pkg_postrm() {
	eselect-init_setup
}
