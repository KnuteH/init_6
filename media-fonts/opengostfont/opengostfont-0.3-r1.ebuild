# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit font

DESCRIPTION="Russian State Standard font for drawings"
HOMEPAGE="https://bitbucket.org/fat_angel/opengostfont"
SRC_URI="https://bitbucket.org/fat_angel/${PN}/downloads/${PN}-otf-${PV}.tar.xz"

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="OFL-1.1"

FONT_SUFFIX="otf"

DEPEND="media-libs/fontconfig"
RDEPEND=""

pkg_setup() {
	S="${WORKDIR}/${PN}-otf-${PV}"
	FONT_S=${S}
	font_pkg_setup
}
