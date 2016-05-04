# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_{3,4,5}} pypy{,3} )
DISTUTILS_SINGLE_IMPL=true

inherit bash-completion-r1 distutils-r1

DESCRIPTION='CLI HTTP client, user-friendly cURL-like tool with intuitive UI, JSON, ...'
HOMEPAGE='http://httpie.org/ https://github.com/jkbrzt/httpie'
LICENSE='BSD'

SLOT='0'
SRC_URI="https://github.com/jkbrzt/httpie/archive/${PV}.tar.gz -> ${P}.tar.gz"

RESTRICT='primaryuri'
KEYWORDS='~amd64 ~arm ~x86'
IUSE='test'

DEPEND="
	test? (
		dev-python/docutils:0[${PYTHON_USEDEP}]
		dev-python/mock:0[${PYTHON_USEDEP}]
		dev-python/pytest:0[${PYTHON_USEDEP}]
		dev-python/pytest-cov:0[${PYTHON_USEDEP}]
		dev-python/pytest-httpbin:0[${PYTHON_USEDEP}]
		dev-python/tox:0[${PYTHON_USEDEP}]
		dev-python/wheel:0[${PYTHON_USEDEP}]
	)"
RDEPEND="${DEPEND}
	dev-python/pygments:0[${PYTHON_USEDEP}]
	dev-python/requests:0[${PYTHON_USEDEP}]"

DOCS=( 'AUTHORS.rst' 'CHANGELOG.rst' 'README.rst' )

python_prepare_all() {
	# `init` target calls `pip install`
	sed -i 's|test: init|test:|' -- 'Makefile' || die

	distutils-r1_python_prepare_all
}

python_test() {
	emake test
}

python_install_all() {
	distutils-r1_python_install_all

	newbashcomp 'httpie-completion.bash' 'http'
}

