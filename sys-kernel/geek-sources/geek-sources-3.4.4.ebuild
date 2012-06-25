# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
ETYPE="sources"
DEBLOB_AVAILABLE="1"

KMV="$(echo $PV | cut -f 1-2 -d .)"

bfq_ver="v3r4"
bld_ver="${KMV}-rc4"
ck_ver="${KMV}-ck2"
grsecurity_ver="2.9.1-3.4.3-201206221855"
imq_ver="3.3"
rt_ver="3.4.3-rt12"

SUPPORTED_FEATURES="aufs bfq bld branding ck deblob fbcondecor fedora grsecurity ice imq mageia pardus -pld reiser4 rt suse uksm"

inherit kernel-geek

KEYWORDS="~amd64 ~x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
