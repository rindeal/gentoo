# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION='Fast and usable calculator for power users'
HOMEPAGE='http://speedcrunch.org'
LICENSE='GPL-2'

SLOT='0'
EGIT_REPO_URI='https://bitbucket.org/heldercorreia/speedcrunch.git'
EGIT_CLONE_TYPE='shallow'

KEYWORDS=''
IUSE='doc'

DEPEND='
    dev-qt/qtgui:5
    dev-qt/qtwidgets:5
    dev-qt/qthelp
    dev-qt/qtnetwork'
RDEPEND="${DEPEND}"

PLOCALES="ar ca_ES cs_CZ da de_DE el en_GB en_US es_AR es_ES et_EE eu_ES fi_FI
	fr_FR he_IL hu_HU id_ID it_IT ja_JP ko_KR lt lv_LV nb_NO nl_NL pl_PL pt_BR
	pt_PT ro_RO ru_RU sk sv_SE tr_TR uz@Latn vi zh_CN"
inherit l10n

# override S so that we don't have to override phase funcs
S_ORIG="${S}"
S="${S}/src"

src_prepare() {
	l10n_find_plocales_changes 'resources/locale' '' '.qm'
	my_rm_loc() {
		rm -v -f "resources/locale/${1}.qm" || die

		sed -i "s|resources/locale/${1}.ts||" \
			-- 'speedcrunch.pro' || die

		sed -i "s|<file>locale/${1}.qm</file>||" \
			'resources/speedcrunch.qrc' || die
		sed -i "s|map.insert(QString::fromUtf8(\".*, QLatin1String(\"${1}\"));||" \
			'gui/mainwindow.cpp' || die
	}
	l10n_for_each_disabled_locale_do my_rm_loc

	cmake-utils_src_prepare
}

src_install() {
	cmake-utils_src_install

	cd "${S_ORIG}" || die

	doicon -s scalable 'gfx/speedcrunch.svg'
#	use doc && dodoc doc/*.pdf
}
