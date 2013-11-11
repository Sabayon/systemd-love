# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

AUTOTOOLS_PRUNE_LIBTOOL_FILES=all
AUTOTOOLS_AUTORECONF=yes
PYTHON_COMPAT=( python2_7 )
inherit autotools-utils bash-completion-r1 linux-info multilib pam python-single-r1 systemd toolchain-funcs udev user eselect-init

DESCRIPTION="System and service manager for Linux"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/systemd"
SRC_URI="http://www.freedesktop.org/software/systemd/${P}.tar.xz
	http://dev.gentoo.org/~pacho/${PN}/${P}-patches.tar.xz"

LICENSE="GPL-2 LGPL-2.1 MIT"
SLOT="0"
KEYWORDS="amd64 arm ppc ppc64 x86"
IUSE="acl audit consolekit cryptsetup doc +firmware-loader gcrypt gudev http introspection
	+logind keymap +kmod lzma openrc pam policykit python qrcode selinux static-libs
	tcpd test vanilla xattr"
REQUIRED_USE="!consolekit? ( logind )"

MINKV="2.6.32"

COMMON_DEPEND="
	>=sys-apps/dbus-1.6.8-r1
	>=sys-apps/util-linux-2.20
	sys-libs/libcap
	acl? ( sys-apps/acl )
	audit? ( >=sys-process/audit-2 )
	!consolekit? ( !sys-auth/consolekit )
	cryptsetup? ( >=sys-fs/cryptsetup-1.4.2 )
	gcrypt? ( >=dev-libs/libgcrypt-1.4.5 )
	gudev? ( >=dev-libs/glib-2 )
	http? ( net-libs/libmicrohttpd )
	introspection? ( >=dev-libs/gobject-introspection-1.31.1 )
	kmod? ( >=sys-apps/kmod-12 )
	lzma? ( app-arch/xz-utils )
	pam? ( virtual/pam )
	python? ( ${PYTHON_DEPS} )
	qrcode? ( media-gfx/qrencode )
	selinux? ( sys-libs/libselinux )
	tcpd? ( sys-apps/tcp-wrappers )
	xattr? ( sys-apps/attr )
"
# baselayout-2.2 has /run
RDEPEND="${COMMON_DEPEND}
	!app-admin/eselect-settingsd
	>=app-admin/eselect-init-0.5
	>=sys-apps/baselayout-2.2
	openrc? (
		sys-apps/systemd-shim
		>=sys-fs/udev-init-scripts-26-r1
	)
	policykit? ( sys-auth/polkit )
	|| (
		>=sys-apps/util-linux-2.22
		<sys-apps/sysvinit-2.88-r4
	)
	!sys-auth/nss-myhostname
	!<sys-libs/glibc-2.10
	!sys-fs/udev"

PDEPEND="
	>=sys-apps/hwids-20130326.1[udev]
	!vanilla? ( ~sys-apps/gentoo-systemd-integration-1 )
"

DEPEND="${COMMON_DEPEND}
	app-arch/xz-utils
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	dev-util/gperf
	>=dev-util/intltool-0.50
	>=sys-devel/gcc-4.6
	>=sys-kernel/linux-headers-${MINKV}
	virtual/pkgconfig
	doc? ( >=dev-util/gtk-doc-1.18 )"

pkg_pretend() {
	local CONFIG_CHECK="~AUTOFS4_FS ~BLK_DEV_BSG ~CGROUPS ~DEVTMPFS
		~FANOTIFY ~HOTPLUG ~INOTIFY_USER ~IPV6 ~NET ~PROC_FS ~SIGNALFD
		~SYSFS ~!IDE ~!SYSFS_DEPRECATED ~!SYSFS_DEPRECATED_V2"
#		~!FW_LOADER_USER_HELPER"

	use acl && CONFIG_CHECK+=" ~TMPFS_POSIX_ACL"

	# read null-terminated argv[0] from PID 1
	# and see which path to systemd was used (if any)
	local init_path
	IFS= read -r -d '' init_path < /proc/1/cmdline
	if [[ ${init_path} == */bin/systemd && -e ${init_path} ]]; then
		eerror "You are using a compatibility symlink to run systemd. The symlink"
		eerror "has been removed. Please update your bootloader to use:"
		eerror
		eerror "	init=/usr/lib/systemd/systemd"
		eerror
		eerror "and reboot your system. We are sorry for the inconvenience."
		if [[ ${MERGE_TYPE} != buildonly ]]; then
			die "Compatibility symlink used to boot systemd."
		fi
	fi

	if [[ ${MERGE_TYPE} != binary ]]; then
		if [[ $(gcc-major-version) -lt 4
			|| ( $(gcc-major-version) -eq 4 && $(gcc-minor-version) -lt 6 ) ]]
		then
			eerror "systemd requires at least gcc 4.6 to build. Please switch the active"
			eerror "gcc version using gcc-config."
			die "systemd requires at least gcc 4.6"
		fi
	fi

	if [[ ${MERGE_TYPE} != buildonly ]]; then
		if kernel_is -lt ${MINKV//./ }; then
			ewarn "Kernel version at least ${MINKV} required"
		fi

		if ! use firmware-loader && kernel_is -lt 3 8; then
			ewarn "You seem to be using kernel older than 3.8. Those kernel versions"
			ewarn "require systemd with USE=firmware-loader to support loading"
			ewarn "firmware. Missing this flag may cause some hardware not to work."
		fi

		check_extra_config
	fi
}

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}/accept4.patch"
	# These are missing from upstream 50-udev-default.rules
	cat <<-EOF > "${T}"/40-gentoo.rules
	# Gentoo specific usb group
	SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", GROUP="usb"
	# Keep this for Linux 2.6.32 kernels with accept4() support like .60 wrt #457868
	SUBSYSTEM=="mem", KERNEL=="null|zero|full|random|urandom", MODE="0666"
	EOF

	# Configure the logind dbus service in case of OpenRC booting the system
	epatch "${FILESDIR}/systemd-logind-dbus-service-wrapper.patch"
	# Force cleanup of logind sessions when running without systemd.
	# Maybe this should be done by openrc, as discussed in:
	# https://bugs.freedesktop.org/show_bug.cgi?id=66018
	epatch "${FILESDIR}/0001-Clean-up-closing-empty-sessions-when-not-running-und.patch"
	# Ubuntu applies this patch, but I have no idea what's it about. From my tests,
	# having it or not doesn't make any difference.
	epatch "${FILESDIR}/0002-Avoid-sending-sigterm-to-session-leader.patch"
	# Add openrc-settingsd support in case of systemd being used only as
	# device manager. This doesn't harm a system booted with systemd.
	epatch "${FILESDIR}/0001-Wrap-hostname1-locale1-and-timedate1-dbus-services-E.patch"
	# Add systemd-shim wrapper support
	epatch "${FILESDIR}/0002-Wrap-org.freedesktop.systemd1-dbus-service-using-sys.patch"

	local PATCHES=(
		# localectl does not find keymaps, bug #474946
		"${FILESDIR}"/204-0002-Add-usr-share-keymaps-to-localectl-supported-locatio.patch
		# Backports from newer versions pulled by Fedora maintainers
		"${WORKDIR}/${P}-patches"/*.patch
	)

	autotools-utils_src_prepare
}

src_configure() {
	local myeconfargs=(
		--localstatedir=/var
		--with-pamlibdir=$(getpam_mod_dir)
		# avoid bash-completion dep
		--with-bashcompletiondir="$(get_bashcompdir)"
		# make sure we get /bin:/sbin in $PATH
		--enable-split-usr
		# disable sysv compatibility
		--with-sysvinit-path=
		--with-sysvrcnd-path=
		# no deps
		--enable-efi
		--enable-ima
		# optional components/dependencies
		$(use_enable acl)
		$(use_enable audit)
		$(use_enable cryptsetup libcryptsetup)
		$(use_enable doc gtk-doc)
		$(use_enable gcrypt)
		$(use_enable gudev)
		$(use_enable http microhttpd)
		$(use_enable introspection)
		$(use_enable keymap)
		$(use_enable kmod)
		$(use_enable logind)
		$(use_enable lzma xz)
		$(use_enable pam)
		$(use_enable policykit polkit)
		$(use_with python)
		$(use python && echo PYTHON_CONFIG=/usr/bin/python-config-${EPYTHON#python})
		$(use_enable qrcode qrencode)
		$(use_enable selinux)
		$(use_enable tcpd tcpwrap)
		$(use_enable test tests)
		$(use_enable xattr)

		# not supported (avoid automagic deps in the future)
		--disable-chkconfig

		# hardcode a few paths to spare some deps
		QUOTAON=/usr/sbin/quotaon
		QUOTACHECK=/usr/sbin/quotacheck
	)

	# Keep using the one where the rules were installed.
	MY_UDEVDIR=$(get_udevdir)

	if use firmware-loader; then
		myeconfargs+=(
			--with-firmware-path="/lib/firmware/updates:/lib/firmware"
		)
	fi

	# Work around bug 463846.
	tc-export CC

	autotools-utils_src_configure
}

src_compile() {
	autotools-utils_src_compile \
		udevlibexecdir="${MY_UDEVDIR}"
}

src_install() {
	autotools-utils_src_install -j1 \
		udevlibexecdir="${MY_UDEVDIR}" \
		dist_udevhwdb_DATA=

	# keep udev working without initramfs, for openrc compat
	dodir /bin /sbin
	mv "${D}"/usr/lib/systemd/systemd-udevd "${D}"/sbin/udevd || die
	mv "${D}"/usr/bin/udevadm "${D}"/bin/udevadm || die
	dosym ../../../sbin/udevd /usr/lib/systemd/systemd-udevd
	dosym ../../bin/udevadm /usr/bin/udevadm

	# zsh completion
	insinto /usr/share/zsh/site-functions
	newins shell-completion/systemd-zsh-completion.zsh "_${PN}"

	# compat for init= use
	dosym ../usr/lib/systemd/systemd /bin/systemd
	dosym ../lib/systemd/systemd /usr/bin/systemd
	# rsyslog.service depends on it...
	dosym ../usr/bin/systemctl /bin/systemctl

	# we just keep sysvinit tools, so no need for the mans
	rm "${D}"/usr/share/man/man8/{halt,poweroff,reboot,runlevel,shutdown,telinit}.8 \
		|| die
	rm "${D}"/usr/share/man/man1/init.1 || die

	# Disable storing coredumps in journald, bug #433457
	mv "${D}"/usr/lib/sysctl.d/50-coredump.conf{,.disabled} || die

	# Preserve empty dirs in /etc & /var, bug #437008
	keepdir /etc/binfmt.d /etc/modules-load.d /etc/tmpfiles.d \
		/etc/systemd/ntp-units.d /etc/systemd/user /var/lib/systemd

	# Check whether we won't break user's system.
	local x
	for x in /bin/systemd /usr/bin/systemd \
		/usr/bin/udevadm /usr/lib/systemd/systemd-udevd
	do
		[[ -x ${D}${x} ]] || die "${x} symlink broken, aborting."
	done

	# Offer a default blacklist that should cover the most
	# common use cases.
	insinto /etc/modprobe.d
	newins "${FILESDIR}"/blacklist-146 blacklist.conf

	# part of the accept4 patch to support older kernels
	insinto /lib/udev/rules.d
	doins "${T}"/40-gentoo.rules

	# add support for eselect init, rename paths
	local init_dir="${INITS_DIR}/${INIT_NAME}"
	local parts=( ${INIT_PARTS} )
	dodir "/${init_dir}/${INITS_REAL_DIR_NAME}"
	local part=
	for part in "${parts[@]}"; do
		dosym "../../../../usr/bin/systemd" "/${init_dir}/${INITS_REAL_DIR_NAME}/${part}"
		ln -s "../exec.sh" "${D}/${init_dir}/${part}" || die
	done

	# OpenRC -> systemd migration script
	exeinto /usr/libexec
	doexe "${FILESDIR}/openrc-to-systemd-2.sh"
	# OpenRC logind service wrapper
	doexe "${FILESDIR}/systemd-logind-dbus-wrapper.sh"
	# systemd-shim systemd service wrapper executable
	doexe "${FILESDIR}/systemd-shim-wrapper.sh"

	# openrc-settingsd support
	exeinto /usr/libexec
	doexe "${FILESDIR}/settingsd-wrapper.sh"

	# logind init script for OpenRC
	newinitd "${FILESDIR}/logind.init.d" "logind"

	# Install the migration assistant and use it in pkg_postinst
	exeinto /usr/libexec
	doexe "${FILESDIR}/systemd-migration-assistant"
}

migrate_locale() {
	local envd_locale_def="${EROOT%/}/etc/env.d/02locale"
	local envd_locale=( "${EROOT%/}"/etc/env.d/??locale )
	local locale_conf="${EROOT%/}/etc/locale.conf"

	if [[ ! -L ${locale_conf} && ! -e ${locale_conf} ]]; then
		# if locale.conf does not exist...
		if [[ -e ${envd_locale} ]]; then
			# ...either copy env.d/??locale if there's one
			ebegin "Moving ${envd_locale} to ${locale_conf}"
			mv "${envd_locale}" "${locale_conf}"
			eend ${?} || FAIL=1
		else
			# ...or create a dummy default
			ebegin "Creating ${locale_conf}"
			cat > "${locale_conf}" <<-EOF
				# This file has been created by the sys-apps/systemd ebuild.
				# See locale.conf(5) and localectl(1).

				# LANG=${LANG}
			EOF
			eend ${?} || FAIL=1
		fi
	fi

	if [[ ! -L ${envd_locale} ]]; then
		# now, if env.d/??locale is not a symlink (to locale.conf)...
		if [[ -e ${envd_locale} ]]; then
			# ...warn the user that he has duplicate locale settings
			ewarn
			ewarn "To ensure consistent behavior, you should replace ${envd_locale}"
			ewarn "with a symlink to ${locale_conf}. Please migrate your settings"
			ewarn "and create the symlink with the following command:"
			ewarn "ln -s -n -f ../locale.conf ${envd_locale}"
			ewarn
		else
			# ...or just create the symlink if there's nothing here
			ebegin "Creating ${envd_locale_def} -> ../locale.conf symlink"
			ln -n -s ../locale.conf "${envd_locale_def}"
			eend ${?} || FAIL=1
		fi
	fi
}

pkg_preinst() {
	# openrc -> systemd migration script
	[[ -x "${ROOT}/usr/libexec/openrc-to-systemd-2.sh" ]] || \
		export MIGRATE_SYSTEMD=1
}

pkg_postinst() {
	# for udev rules
	enewgroup dialout

	enewgroup systemd-journal
	if use http; then
		enewgroup systemd-journal-gateway
		enewuser systemd-journal-gateway -1 -1 -1 systemd-journal-gateway
	fi
	systemd_update_catalog

	# Keep this here in case the database format changes so it gets updated
	# when required. Despite that this file is owned by sys-apps/hwids.
	if has_version "sys-apps/hwids[udev]"; then
		udevadm hwdb --update --root="${ROOT%/}"
	fi

	udev_reload || FAIL=1

	# Bug 468876
	fcaps cap_dac_override,cap_sys_ptrace=ep usr/bin/systemd-detect-virt

	# Bug 465468, make sure locales are respect, and ensure consistency
	# between OpenRC & systemd
	migrate_locale

	if [[ ${FAIL} ]]; then
		eerror "One of the postinst commands failed. Please check the postinst output"
		eerror "for errors. You may need to clean up your system and/or try installing"
		eerror "systemd again."
		eerror
	fi

	if [[ ! -L "${ROOT}"/etc/mtab ]]; then
		ewarn "Upstream mandates the /etc/mtab file should be a symlink to /proc/mounts."
		ewarn "Not having it is not supported by upstream and will cause tools like 'df'"
		ewarn "and 'mount' to not work properly. Please run:"
		ewarn "	# ln -sf '${ROOT}proc/self/mounts' '${ROOT}etc/mtab'"
		ewarn
	fi

	if ! has_version sys-apps/systemd-ui; then
		elog "To get additional features, a number of optional runtime dependencies may"
		elog "be installed:"
		elog "- sys-apps/systemd-ui: for GTK+ systemadm UI and gnome-ask-password-agent"
	fi

	eselect-init_setup

	if [ "${MIGRATE_SYSTEMD}" = "1" ]; then
		ewarn "Automatically enabling some systemd units basing on your"
		ewarn "openrc configuration"
		if has_version "sys-apps/openrc"; then
			/usr/libexec/openrc-to-systemd-2.sh | /bin/sh 2>/dev/null
		fi
	fi

	# This is not really needed but eases the transition to logind
	if [ ! -e "${EROOT}/etc/systemd/.logind.migrated" ] && ! use consolekit && \
		use logind && use openrc; then
		einfo "Migrating to logind, enabling logind service"
		mkdir -p "${EROOT}"etc/runlevels/boot
		ln -snf /etc/init.d/logind "${EROOT}"etc/runlevels/boot/logind && \
			touch "${EROOT}/etc/systemd/.logind.migrated"
	fi

	# Inform user about services that should be enabled if migrating from OpenRC
	local units=$(ROOT="${EROOT}" "${EROOT}/usr/libexec/systemd-migration-assistant" 2>/dev/null)
	if [ -n "${units}" ]; then
		ewarn "If you want to migrate from OpenRC to systemd, please consider enabling"
		ewarn "the following systemd units (as root):"
		ewarn "--"

		local unit=
		for unit in ${units}; do
			ewarn "systemctl enable -f ${unit}.service"
		done

		ewarn "--"
		ewarn "/usr/libexec/systemd-migration-assistant employs an euristic algorithm"
		ewarn "So, please review the list manually."
	fi
}

pkg_prerm() {
	# If removing systemd completely, remove the catalog database.
	if [[ ! ${REPLACED_BY_VERSION} ]]; then
		rm -f -v "${EROOT}"/var/lib/systemd/catalog/database
	fi
	eselect-init_setup
}

pkg_postrm() {
	eselect-init_setup
}
