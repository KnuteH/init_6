# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

DESCRIPTION="Virtual for Linux kernel sources"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="*"
IUSE="hardened"

DEPEND=""
RDEPEND="|| (
		hardened? ( sys-kernel/hardened-sources )
		sys-kernel/sysrescue-std-sources
		sys-kernel/debian-sources
		sys-kernel/openvz-rhel5-stable
		sys-kernel/openvz-rhel6-stable
		sys-kernel/openvz-rhel6-test
		sys-kernel/gentoo-sources
		sys-kernel/vanilla-sources
		sys-kernel/cell-sources
		sys-kernel/ck-sources
		sys-kernel/git-sources
		sys-kernel/hardened-sources
		sys-kernel/mips-sources
		sys-kernel/mm-sources
		sys-kernel/openvz-sources
		sys-kernel/pf-sources
		sys-kernel/tuxonice-sources
		sys-kernel/usermode-sources
		sys-kernel/vserver-sources
		sys-kernel/xbox-sources
		sys-kernel/xen-sources
		sys-kernel/zen-sources
		sys-kernel/rh-sources
		sys-kernel/geek-sources
	)"
