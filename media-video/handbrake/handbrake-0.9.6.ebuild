# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="svn://svn.handbrake.fr/HandBrake/trunk"
ESVN_PROJECT="hb-trunk"

inherit subversion python gnome2-utils toolchain-funcs

DESCRIPTION="Video Encoder"
HOMEPAGE="http://handbrake.fr"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gtk gst ffmpeg2 doc"

# fribidi is necessary to compile libass
# Don't need this dependency, net-libs/webkit-gtk, 
# since I'm passing --disable-gtk-update-checks to configure.
DEPEND=">=sys-devel/gcc-4.0.0
        =dev-lang/python-2.7*
        || (
           >=net-misc/curl-7.21.4
           >=net-misc/wget-1.13.4
        )
        >=dev-lang/yasm-0.8.0
        sys-libs/zlib
        app-arch/bzip2
        dev-libs/fribidi
        =sys-devel/automake-1.11*
        gtk? (
           dev-util/intltool
           >=dev-libs/dbus-glib-0.98
           >=x11-libs/gtk+-2.0
           >=sys-fs/udev-171[gudev]
           x11-libs/libnotify
        )
        gst? (
           media-libs/gstreamer
           media-libs/gst-plugins-base
        )"
RDEPEND="${DEPEND}"

# the directory name differs from the package name so
# need to modify the source directory
S="${WORKDIR}/hb-trunk"

# what version of python must be eselected in the user's environment
ESELECT_PY_VERSION=2.7

# what version of automake required
AUTOMAKE_VERSION=1.11

# Set these variables manually since handbrake's configure
# script doesn't handle outputs from use_enable correctly
# (i.e. --disable-ff-mpeg2 will break ./configure)
DISABLE_GST="--disable-gst"
ENABLE_FFMPEG2=""
FETCH="wget"

pkg_setup()
{
   # make sure eselect for python set to ESELECT_PY_VERSION
   python_pkg_setup
   if [ -z $(python_get_version | grep "${ESELECT_PY_VERSION}") ]; then
      elog "Package dependencies require you to set the \
python version to ${ESELECT_PY_VERSION} before emerging ${PN}."
      elog "Please run eselect python list; eselect python set 1 \
(if python version ${ESELECT_PY_VERSION} is in the first slot, for example)."
      die "Python environment must be changed to meet package \
dependencies.  See above explanation and run eselect python help for details."
   fi

   # set the use flags for use in ./configure later on
   if use gst ; then
      DISABLE_GST="";
   fi
   if use ffmpeg2 ; then
      ENABLE_FFMPEG2="--enable-ff-mpeg2";
   fi
   if [ -x /usr/bin/curl ]; then
      FETCH="curl";
   fi
}

src_configure()
{
   # python configure script doesn't accept all econf flags
   ./configure --force --prefix=/usr $(use_enable gtk) \
--disable-gtk-update-checks ${DISABLE_GST} \
${ENABLE_FFMPEG2} --fetch=${FETCH}
}

src_compile()
{
   WANT_AUTOMAKE="${AUTOMAKE_VERSION}" emake -C build || die "failed compiling ${PN}"
}

src_install()
{
   WANT_AUTOMAKE="${AUTOMAKE_VERSION}" emake -C build DESTDIR=${D} install || die "failed installing ${PN}"
   elog "If you were required to change your python version, you \
may now change back to the previous version you were using before \
emerging ${PN}.  Please run eselect python list; eselect python set 1 \
(if python version ${ESELECT_PY_VERSION} is in the first slot, for example)."

   if use doc ; then
      WANT_AUTOMAKE="${AUTOMAKE_VERSION}" emake -C build doc
      dodoc AUTHORS CREDITS NEWS THANKS build/doc/articles/txt/* || die "dodoc
failed"
   else
      dodoc AUTHORS CREDITS NEWS THANKS || die "dodoc failed"
   fi
}

pkg_preinst()
{
   gnome2_icon_savelist
}

pkg_postinst()
{
   gnome2_icon_cache_update
}

pkg_postrm()
{
   gnome2_icon_cache_update
}
