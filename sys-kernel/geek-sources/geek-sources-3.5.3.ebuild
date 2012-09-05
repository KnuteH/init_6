# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
ETYPE="sources"
DEBLOB_AVAILABLE="1"

KMV="$(echo $PV | cut -f 1-2 -d .)"

bld_ver="${KMV}.0"
ck_ver="${KMV}-ck1"
#rt_ver="${PV}-rt13"
rt_ver="3.4.10-rt18"
OVERRIDE_rt_src="http://www.kernel.org/pub/linux/kernel/projects/rt/3.4/patch-${rt_ver}.patch.xz"
vserver_ver="2.3.4.2"

SUPPORTED_FEATURES="aufs bfq bld branding ck deblob fbcondecor fedora grsecurity ice mageia rt suse uksm vserver zfs"

inherit kernel-geek

KEYWORDS="~amd64 ~x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
