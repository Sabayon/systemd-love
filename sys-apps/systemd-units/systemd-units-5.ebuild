# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit eutils systemd

DESCRIPTION="Service files for sys-apps/systemd (temporary ebuild)"
HOMEPAGE="https://github.com/Sabayon/systemd-love"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND=""

src_install() {
	# Thanks to the guy who made this possible !

	# !!! all these units must be moved to individual packages !!!
	systemd_dounit "${FILESDIR}"/services-basic/*
	systemd_dounit "${FILESDIR}"/services-server/*
	systemd_dotmpfilesd "${FILESDIR}"/tmpfiles-server/*
	systemd_dounit "${FILESDIR}"/services-desktop/*

	# Files in portage cannot contain a literal '@' character. Therfore,
	# convert the code string "_at" into an '@' before installing.
	rename '_at' '@' "${D}/$(systemd_get_unitdir)"/*
}
