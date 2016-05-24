# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit eutils systemd toolchain-funcs

MY_PV="${PV//_/-}"
MY_P="${PN}-${MY_PV}"
DESCRIPTION="NTP client and server programs"
HOMEPAGE="https://chrony.tuxfamily.org/"
SRC_URI="https://download.tuxfamily.org/${PN}/${MY_P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 ~arm ~hppa ~ppc64"
IUSE="caps +cmdmon html ipv6 libedit +ntp +phc +pps readline +refclock +rtc selinux +adns"
REQUIRED_USE="
	?? ( libedit readline )
"

CDEPEND="
	caps? ( sys-libs/libcap )
	libedit? ( dev-libs/libedit )
	readline? ( >=sys-libs/readline-4.1-r4:= )
"
DEPEND="
	${CDEPEND}
	html? ( dev-ruby/asciidoctor )
"
RDEPEND="
	${CDEPEND}
	selinux? ( sec-policy/selinux-chronyd )
"

# FIXME: why?
RESTRICT="test"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	default

	local sed_args=(
		-e 's:/etc/chrony\.:/etc/chrony/chrony.:g'
		-e 's:/var/run:/run:g')
	sed "${sed_args[@]}" \
		-i -- conf.c doc/*.man.in examples/* || die
}

src_configure() {
	# FIXME: why?
	tc-export CC

	local econf_args=(
		--chronysockdir="${EPREFIX}/run/chrony"
		--sysconfdir="${EPREFIX}/etc/chrony"
		# FIXME: why?
		--disable-sechash
		# FIXME: why?
		--without-nss
		# FIXME: why?
		--without-tomcrypt

		$(use_enable caps linuxcaps)
		$(use_enable cmdmon)
		$(use_enable ipv6)
		$(use_enable ntp)
		$(use_enable phc)
		$(use_enable pps)
		$(use_enable rtc)
		$(use_enable refclock)
		$(use_enable adns asyncdns)

		$(use_with libedit editline)
		$(use_with readline)
	)

	# ./configure legend:
	# --disable-readline : disable line editing entirely
	# --without-readline : do not use sys-libs/readline (enabled by default)
	# --without-editline : do not use dev-libs/libedit (enabled by default)
	if ! use readline && ! use libedit; then
		econf_args+=( --disable-readline )
	fi

	econf "${econf_args[@]}"
}

src_compile() {
	emake all docs $(usex html '' 'ADOC=true')
}

src_install() {
	local HTML_DOCS=( doc/*.html )
	default

	newinitd "${FILESDIR}"/chronyd.init-r1 chronyd
	newconfd "${FILESDIR}"/chronyd.conf chronyd

	insinto /etc/${PN}
	newins examples/chrony.conf.example1 chrony.conf

	docinto examples
	dodoc examples/*.example*

	keepdir /var/{lib,log}/chrony

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/chrony-2.4.logrotate chrony

	systemd_newunit "${FILESDIR}"/chronyd.service-r2 chronyd.service
	systemd_enable_ntpunit 50-chrony chronyd.service
}
