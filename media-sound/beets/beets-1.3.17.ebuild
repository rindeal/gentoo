# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE='sqlite'
DISTUTILS_SINGLE_IMPL=true

inherit distutils-r1 eutils

DESCRIPTION='A media library management system for obsessive-compulsive music geeks'
HOMEPAGE='http://beets.io'
LICENSE='MIT'

SLOT='0'
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

KEYWORDS='~amd64 ~arm ~x86'
IUSE='amarok bpd chroma convert doc discogs echonest embyupdate fetchart flac gstreamer lastgenre
	lastimport lyrics metasync mpdstats ogg opus plexupdate replaygain test thumbnails web'

# TODO:
#  - http://beets.readthedocs.org/en/v1.3.17/plugins/index.html#miscellaneous
#  - http://beets.readthedocs.org/en/v1.3.17/plugins/index.html#other-plugins
RDEPEND="
	>=dev-python/enum34-1.0.4[${PYTHON_USEDEP}]
	dev-python/jellyfish[${PYTHON_USEDEP}]
	dev-python/munkres[${PYTHON_USEDEP}]
	>=dev-python/python-musicbrainz-ngs-0.4[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/unidecode[${PYTHON_USEDEP}]
	>=media-libs/mutagen-1.27[${PYTHON_USEDEP}]

	amarok? ( media-sound/amarok )
	bpd? ( dev-python/bluelet[${PYTHON_USEDEP}] )
	chroma? (
		dev-python/pyacoustid:0[${PYTHON_USEDEP}]
		gstreamer? (
			dev-python/gst-python[${PYTHON_USEDEP}]
			media-libs/gstreamer[introspection]
		)
		mad? ( dev-python/pymad:0[${PYTHON_USEDEP}] )
	)
	convert? ( media-video/ffmpeg:0[encode] )
	discogs? ( >=dev-python/discogs-client-2.1:0[${PYTHON_USEDEP}] )
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	echonest? ( >=dev-python/pyechonest-8.0.1:0[${PYTHON_USEDEP}] )
	embyupdate? ( dev-python/requests:0[${PYTHON_USEDEP}] )
	fetchart? ( dev-python/requests:0[${PYTHON_USEDEP}] )
	lastgenre? ( dev-python/pylast:0[${PYTHON_USEDEP}] )
	lastimport? ( dev-python/pylast:0[${PYTHON_USEDEP}] )
	lyrics? ( dev-python/requests:0[${PYTHON_USEDEP}] )
	metasync? ( amarok? ( dev-python/dbus-python:0[${PYTHON_USEDEP}] ) )
	mpdstats? ( dev-python/python-mpd[${PYTHON_USEDEP}] )
	plexupdate? ( dev-python/requests:0[${PYTHON_USEDEP}] )
	replaygain? (
		gstreamer? (
			media-libs/gstreamer:1.0[introspection]
			media-libs/gst-plugins-good:1.0
			dev-python/pygobject:3[${PYTHON_USEDEP}]
			ogg? ( media-plugins/gst-plugins-ogg )
			flac? ( media-plugins/gst-plugins-flac:1.0 )
			opus? ( media-plugins/gst-plugins-opus:1.0 )
		)
		!gstreamer? ( || (
			media-sound/mp3gain
			media-sound/aacgain
		) )
	)
	thumbnails? (
		dev-python/pyxdg:0[${PYTHON_USEDEP}]
		virtual/python-pathlib:0[${PYTHON_USEDEP}]
		|| (
			dev-python/pillow:0[${PYTHON_USEDEP}]
			media-gfx/imagemagick:0
		)
	)
	web? ( dev-python/flask[${PYTHON_USEDEP}] )"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		dev-python/beautifulsoup:4[${PYTHON_USEDEP}]
		dev-python/flask:0[${PYTHON_USEDEP}]
		dev-python/mock:0[${PYTHON_USEDEP}]
		dev-python/pathlib:0[${PYTHON_USEDEP}]
		dev-python/pyechonest:0[${PYTHON_USEDEP}]
		dev-python/pylast:0[${PYTHON_USEDEP}]
		dev-python/pyxdg:0[${PYTHON_USEDEP}]
		dev-python/rarfile:0[${PYTHON_USEDEP}]
		dev-python/responses:0[${PYTHON_USEDEP}]
	)"
REQUIRED_USE='
	chroma? ( || ( ffmpeg gstreamer mad ) )
	thumbnails? ( fetchart )
'

python_prepare_all() {
	# remove plugins that do not have appropriate dependencies installed
	for flag in bpd chroma convert discogs echonest lastgenre lastimport metasync mpdstats plexupdate replaygain thumbnails web; do
		if ! use ${flag}; then
			rm -v beetsplug/${flag}.py || \
			rm -rv beetsplug/${flag}/ ||
				die "Unable to remove ${flag} plugin"
		fi
	done

	for flag in bpd lastgenre metasync thumbnails web; do
		if ! use ${flag}; then
			sed -e "s:'beetsplug.${flag}',::" -i setup.py || \
				die "Unable to disable ${flag} plugin "
		fi
	done

	use bpd || rm -vf test/test_player.py || die

	distutils-r1_python_prepare_all
}

python_compile_all() {
	use doc && emake -C docs html
}

python_test() {
	cd test
	if ! use web; then
		rm -v test_web.py || die 'Failed to remove test_web.py'
	fi
	"${PYTHON}" testall.py || die "Testsuite failed"
}

python_install_all() {
	doman man/beet.1 man/beetsconfig.5
	use doc && HTML_DOCS=( 'docs/_build/html/' )

	distutils-r1_python_install_all
}
