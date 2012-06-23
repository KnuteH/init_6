# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
DEBLOB_AVAILABLE="1"

inherit kernel-geek

#------------------------------------------------------------------------

# Latest version checker:
# # curl -s http://www.kernel.org/kdist/finger_banner

# git://aufs.git.sourceforge.net/gitroot/aufs/aufs3-standalone.git, read README
# Patch creation:
# git clone git://aufs.git.sourceforge.net/gitroot/aufs/aufs3-standalone.git
# cd aufs3-standalone
# git checkout -b aufs3.4 origin/aufs3.4
# cat aufs3-kbuild.patch aufs3-base.patch aufs3-standalone.patch > ~/rpm/packages/kernel/kernel-aufs3.patch
# mkdir linux
# cp -a Documentation fs include linux
# diff -urN /usr/share/empty linux >> ~/rpm/packages/kernel/kernel-aufs3.patch
# drop hunk at the end of patch (hunk is patching include/linux/Kbuild with single line change)

# Alternate CPU load distribution technique for Linux kernel scheduler
bld_ver="${KMV}-rc4"
bld_src="http://bld.googlecode.com/files/bld-${bld_ver}.tar.bz2"

# Con Kolivas' high performance patchset
ck_ver="${KMV}-ck2"
ck_src="http://ck.kolivas.org/patches/3.0/${KMV}/${KMV}-ck2/patch-${ck_ver}.bz2"

# deblob
deblob_src="http://linux-libre.fsfla.org/pub/linux-libre/releases/LATEST-${KMV}.N/deblob-${KMV} http://linux-libre.fsfla.org/pub/linux-libre/releases/LATEST-${KMV}.N/deblob-check"

# Spock's fbsplash patch
fbcondecor_src="http://sources.gentoo.org/cgi-bin/viewvc.cgi/linux-patches/genpatches-2.6/trunk/${KMV}/4200_fbcondecor-0.9.6.patch"

# grsecurity patches
# NOTE: mirror of old grsecurity patches:
# https://github.com/slashbeast/grsecurity-scrape/tree/master/test
# Gentoo hardened patchset
# http://git.overlays.gentoo.org/gitweb/?p=proj/hardened-patchset.git;a=summary
grsecurity_ver="2.9.1-${PV}-201206160836"
grsecurity_src="http://grsecurity.net/test/grsecurity-${grsecurity_ver}.patch"

# Intermediate Queueing Device patches
imq_ver="3.3"
imq_src="http://www.linuximq.net/patches/patch-imqmq-${imq_ver}.diff.xz"

# Reiser4
#reiser4_ver="${PV}"
#reiser4_src="mirror://kernel/linux/kernel/people/edward/reiser4/reiser4-for-2.6/reiser4-for-${REISER4_OKV}${REISER4_VER}.patch.bz2"

# Ingo Molnar's realtime preempt patches
rt_ver="3.4.3-rt11"
rt_src="http://www.kernel.org/pub/linux/kernel/projects/rt/${KMV}/patch-${rt_ver}.patch.xz"

# unionfs
# http://download.filesystems.org/unionfs/unionfs-2.x/unionfs-2.5.11_for_3.3.0-rc3.diff.gz

# todo: add Xenomai: Real-Time Framework for Linux http://www.xenomai.org/
# Xenomai: Real-Time Framework for Linux http://www.xenomai.org/
#xenomai_url="http://www.xenomai.org"
#xenomai_ver="2.6.0"
#xenomai_src="http://download.gna.org/xenomai/stable/xenomai-${xenomai_ver}.tar.bz2"

#------------------------------------------------------------------------

KEYWORDS="~amd64 ~x86"
use reiser4 && die "No reiser4 support yet for this version."

SRC_URI="${SRC_URI}
	deblob?		( ${deblob_src} )
	bld?		( ${bld_src} )
	ck?		( ${ck_src} )
	fbcondecor?	( ${fbcondecor_src} )
	grsecurity?	( ${grsecurity_src} )
	imq?		( ${imq_src} )
	rt?		( ${rt_src} )"

src_prepare() {
	use bfq && ApplyPatch "${FILESDIR}/${PV}/bfq/patch_list" "Budget Fair Queueing Budget I/O Scheduler - ${bfq_url}"

	use ck && ApplyPatch "$DISTDIR/patch-${ck_ver}.bz2" "Con Kolivas high performance patchset - ${ck_url}"

	use fbcondecor && ApplyPatch "${DISTDIR}/4200_fbcondecor-0.9.6.patch" "Spock's fbsplash patch - ${fbcondecor_url}"

	use grsecurity && ApplyPatch "${DISTDIR}/grsecurity-${grsecurity_ver}.patch" "GrSecurity patches - ${grsecurity_url}"

	use ice && ApplyPatch "${FILESDIR}/tuxonice-kernel-${PV}.patch.xz" "TuxOnIce - ${ice_url}"

	use imq && ApplyPatch "${DISTDIR}/patch-imqmq-${imq_ver}.diff.xz" "Intermediate Queueing Device patches - ${imq_url}"

	use reiser4 && ApplyPatch "${DISTDIR}/reiser4-for-${PV}.patch.bz2" "Reiser4 - ${reiser4_url}"

	use rt && ApplyPatch "${DISTDIR}/patch-${rt_ver}.patch.xz" "Ingo Molnar's realtime preempt patches - ${rt_url}"

	if use bld; then
		echo
		cd "${T}"
		unpack "bld-${bld_ver}.tar.bz2"
		cp "${T}/bld-${bld_ver}/BLD-${bld_ver}.patch" "${S}/BLD-${bld_ver}.patch"
		cd "${S}"
		ApplyPatch "BLD-${bld_ver}.patch" "Alternate CPU load distribution technique for Linux kernel scheduler - ${bld_url}"
		rm -f "BLD-${bld_ver}.patch"
		rm -r "${T}/bld-${bld_ver}" # Clean temp
	fi

	use uksm && ApplyPatch "${FILESDIR}/${PV}/uksm/patch_list" "Ultra Kernel Samepage Merging - ${uksm_url}"

#	if use xenomai; then
#		# Portage's ``unpack'' macro unpacks to the current directory.
#		# Unpack to the work directory.  Afterwards, ``work'' contains:
#		#   linux-2.6.29-xenomai-r5
#		#   xenomai-2.4.9
#		cd ${WORKDIR}
#		unpack ${XENO_TAR} || die "unpack failed"
#		cd ${WORKDIR}/${XENO_SRC}
#		ApplyPatch ${FILESDIR}/prepare-kernel.patch || die "patch failed"
#		scripts/prepare-kernel.sh --linux=${S} || die "prepare kernel failed"
#	fi

### BRANCH APPLY ###

	use aufs && ApplyPatch "$FILESDIR/${PV}/aufs/patch_list" "aufs3 - ${aufs_url}"

	use mageia && ApplyPatch "$FILESDIR/${PV}/mageia/patch_list" "Mandriva/Mageia - ${mageia_url}"

	use fedora && ApplyPatch "$FILESDIR/${PV}/fedora/patch_list" "Fedora - ${fedora_url}"

	use suse && ApplyPatch "$FILESDIR/${PV}/suse/patch_list" "OpenSuSE - ${suse_url}"

	use pardus && ApplyPatch "$FILESDIR/${PV}/pardus/patch_list" "Pardus - ${pardus_url}"

	ApplyPatch "${FILESDIR}/acpi-ec-add-delay-before-write.patch" "Oops: ACPI: EC: input buffer is not empty, aborting transaction - 2.6.32 regression https://bugzilla.kernel.org/show_bug.cgi?id=14733#c41"

	# USE branding
	if use branding; then
		ApplyPatch "${FILESDIR}/font-8x16-iso-latin-1-v2.patch" "font - CONFIG_FONT_ISO_LATIN_1_8x16 http://sudormrf.wordpress.com/2010/10/23/ka-ping-yee-iso-latin-1%c2%a0font-in-linux-kernel/"
		ApplyPatch "${FILESDIR}/gentoo-larry-logo-v2.patch" "logo - CONFIG_LOGO_LARRY_CLUT224 https://github.com/init6/init_6/raw/master/sys-kernel/geek-sources/files/larry.png"
	fi

### END OF PATCH APPLICATIONS ###

	echo
	einfo "Live long and prosper."
	echo

	kernel-geek_src_prepare
}
