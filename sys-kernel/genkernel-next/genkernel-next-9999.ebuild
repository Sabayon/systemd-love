# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

if [[ "${PV}" != "9999" ]]; then
	SRC_URI="http://dev.gentoo.org/~lxnay/genkernel-next/${P}.tar.xz"
else
	EGIT_REPO_URI="git://github.com/Sabayon/genkernel-next.git"
	inherit git-2
fi
inherit bash-completion-r1 eutils

if [[ "${PV}" == "9999" ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~arm ~x86"
fi

DESCRIPTION="Gentoo automatic kernel building scripts ('next' branch)"
HOMEPAGE="http://www.gentoo.org"

LICENSE="GPL-2"
SLOT="0"
RESTRICT=""
IUSE="crypt cryptsetup dmraid gpg ibm iscsi plymouth selinux"  # Keep 'crypt' in to keep 'use crypt' below working!

DEPEND="app-text/asciidoc
	sys-fs/e2fsprogs
	selinux? ( sys-libs/libselinux )"
RDEPEND="${DEPEND}
	!sys-kernel/genkernel
	cryptsetup? ( sys-fs/cryptsetup )
	dmraid? ( sys-fs/dmraid )
	gpg? ( app-crypt/gnupg )
	iscsi? ( sys-block/open-iscsi )
	plymouth? ( sys-boot/plymouth )
	app-portage/portage-utils
	app-arch/cpio
	>=app-misc/pax-utils-0.2.1
	!<sys-apps/openrc-0.9.9
	sys-block/thin-provisioning-tools
	sys-fs/dmraid
	sys-fs/lvm2"

src_prepare() {
	use selinux && sed -i 's/###//g' "${S}"/gen_compile.sh

	sed -i "/^GK_V=/ s:GK_V=.*:GK_V=${PV}:g" "${S}/genkernel" || \
		die "Could not setup release"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	doman "${S}"/genkernel.8 || die "doman"
	dodoc "${S}"/AUTHORS "${S}"/README || die "dodoc"

	use ibm && cp "${S}"/ppc64/kernel-2.6-pSeries "${S}"/ppc64/kernel-2.6 || \
		cp "${S}"/arch/ppc64/kernel-2.6.g5 "${S}"/arch/ppc64/kernel-2.6

	newbashcomp "${S}"/genkernel.bash "${PN}"
}

pkg_postinst() {
	elog "You are using a forked version of genkernel called genkernel-next"
	elog "It contains cool stuff (like proper udev/systemd and plymouth support)"
	elog
	elog "Crufty features like cross compiler, unionfs, tuxonice were dropped"
	elog "because their code quality was really low."
	elog
	if use crypt && ! use cryptsetup ; then
		ewarn "Local use flag 'crypt' has been renamed to 'cryptsetup' (bug #414523)."
		ewarn "Please set flag 'cryptsetup' for this very package if you would like"
		ewarn "to have genkernel create an initramfs with LUKS support."
		echo
	fi
}
