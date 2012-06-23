# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: Andrey Ovcharov <sudormrfhalt@gmail.com>
# Purpose: kernel-2 replacer.
#
# Bugs to sudormrfhalt@gmail.com
#

ETYPE="sources"

# No need to run scanelf/strip on kernel sources/headers (bug #134453).
RESTRICT="mirror binchecks strip"

# Even though xz-utils are in @system, they must still be added to DEPEND; see
# http://archives.gentoo.org/gentoo-dev/msg_a0d4833eb314d1be5d5802a3b710e0a4.xml
DEPEND="${DEPEND} app-arch/xz-utils"

# the kernel version (e.g 3 for 3.4.2)
VERSION="$(echo $PV | cut -f 1 -d .)"
# the kernel patchlevel (e.g 4 for 3.4.2)
PATCHLEVEL="$(echo $PV | cut -f 2 -d .)"
# the kernel sublevel (e.g 2 for 3.4.2)
SUBLEVEL="$(echo $PV | cut -f 3 -d .)"
# the kernel major version (e.g 3.4 for 3.4.2)
KMV="$(echo $PV | cut -f 1-2 -d .)"

# ebuild default values setup settings
KV_FULL="${PVR}-geek"
S="${WORKDIR}"/linux-"${KV_FULL}"
SLOT="${PV}"

IUSE="aufs bfq bld branding ck deblob fbcondecor fedora grsecurity ice imq mageia pardus pld reiser4 rt suse uksm"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"

#------------------------------------------------------------------------

# aufs
aufs_url="http://aufs.sourceforge.net/"

# apparmor
# http://git.kernel.org/?p=linux/kernel/git/jj/linux-apparmor.git;a=shortlog;h=refs/heads/v3.4-aa2.8

# Budget Fair Queueing Budget I/O Scheduler
bfq_url="http://algo.ing.unimo.it/people/paolo/disk_sched/"

# Alternate CPU load distribution technique for Linux kernel scheduler
bld_url="http://code.google.com/p/bld"

# Con Kolivas' high performance patchset
ck_url="http://users.on.net/~ckolivas/kernel"

# deblob
deblob_url="http://linux-libre.fsfla.org/pub/linux-libre/"

# Spock's fbsplash patch
fbcondecor_url="http://dev.gentoo.org/~spock/projects/fbcondecor"

# Fedora
fedora_url="http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary"

# grsecurity patches
grsecurity_url="http://grsecurity.net"

# TuxOnIce
ice_url="http://tuxonice.net"

# Intermediate Queueing Device patches
imq_url="http://www.linuximq.net"

# Mandriva/Mageia
mageia_url="http://svnweb.mageia.org/packages/cauldron/kernel/current"

# Pardus
pardus_url="https://svn.pardus.org.tr/pardus/playground/kaan.aksit/2011/kernel/default/kernel"

# pld
pld_url="http://cvs.pld-linux.org/cgi-bin/viewvc.cgi/cvs/packages/kernel/?pathrev=MAIN"

# Reiser4
reiser4_url="http://sourceforge.net/projects/reiser4"

# Ingo Molnar's realtime preempt patches
rt_url="http://www.kernel.org/pub/linux/kernel/projects/rt"

# OpenSuSE
suse_url="http://kernel.opensuse.org/cgit/kernel-source"

# uksm
uksm_url="http://kerneldedup.org"

# unionfs
# http://download.filesystems.org/unionfs/unionfs-2.x/unionfs-2.5.11_for_3.3.0-rc3.diff.gz

#------------------------------------------------------------------------

HOMEPAGE="http://www.kernel.org"
use aufs       && HOMEPAGE="$HOMEPAGE ${aufs_url}"
use bfq        && HOMEPAGE="$HOMEPAGE ${bfq_url}"
use bld        && HOMEPAGE="$HOMEPAGE ${bld_url}"
use ck         && HOMEPAGE="$HOMEPAGE ${ck_url}"
use deblob     && HOMEPAGE="$HOMEPAGE ${deblob_url}"
use fbcondecor && HOMEPAGE="$HOMEPAGE ${fbcondecor_url}"
use fedora     && HOMEPAGE="$HOMEPAGE ${fedora_url}"
use grsecurity && HOMEPAGE="$HOMEPAGE ${grsecurity_url}"
use ice        && HOMEPAGE="$HOMEPAGE ${ice_url}"
use imq        && HOMEPAGE="$HOMEPAGE ${imq_url}"
use mageia     && HOMEPAGE="$HOMEPAGE ${mageia_url}"
use pardus     && HOMEPAGE="$HOMEPAGE ${pardus_url}"
use pld        && HOMEPAGE="$HOMEPAGE ${pld_url}"
use reiser4    && HOMEPAGE="$HOMEPAGE ${reiser4_url}"
use rt         && HOMEPAGE="$HOMEPAGE ${rt_url}"
use suse       && HOMEPAGE="$HOMEPAGE ${suse_url}"
use uksm       && HOMEPAGE="$HOMEPAGE ${uksm_url}"

SRC_URI="http://www.kernel.org/pub/linux/kernel/v3.x/linux-${KMV}.tar.xz
	http://www.kernel.org/pub/linux/kernel/v3.x/patch-${PV}.xz"

RDEPEND="${RDEPEND}
	grsecurity?	( >=sys-apps/gradm-2.2.2 )
	ice?		( >=sys-apps/tuxonice-userui-1.0
			( || ( >=sys-power/hibernate-script-2.0 sys-power/pm-utils ) ) )"

# export all the available functions here
EXPORT_FUNCTIONS ApplyPatch src_unpack src_prepare src_compile src_install pkg_postinst

# default argument to patch
patch_command='patch -p1 -F1 -s'
# unpack and apply patches
ExtractApply() {
	local patch=$1
	shift
	case "$patch" in
	*.gz)  gunzip -dc    < "$patch" | $patch_command ${1+"$@"} ;;
	*.bz)  bunzip -dc    < "$patch" | $patch_command ${1+"$@"} ;;
	*.bz2) bunzip2 -dc   < "$patch" | $patch_command ${1+"$@"} ;;
	*.xz)  xz -dc        < "$patch" | $patch_command ${1+"$@"} ;;
	*.zip) unzip -d      < "$patch" | $patch_command ${1+"$@"} ;;
	*.Z)   uncompress -c < "$patch" | $patch_command ${1+"$@"} ;;
	*) $patch_command ${1+"$@"} < "$patch" ;;
	esac
}

# check the availability of a patch on the path passed
# check that the patch was not an empty
# test run patch with 'patch -p1 --dry-run'
# All tests completed successfully? run ExtractApply
Handler() {
	local patch=$1
	shift
	if [ ! -f $patch ]; then
		ewarn "Patch $patch does not exist."
		exit 1
	fi
	# don't apply patch if it's empty
	local C=$(wc -l $patch | awk '{print $1}')
	if [ "$C" -gt 9 ]; then
		# test argument to patch
		patch_command='patch -p1 --dry-run'
		if ExtractApply "$patch" &>/dev/null; then
			# default argument to patch
			patch_command='patch -p1 -F1 -s'
			ExtractApply "$patch" &>/dev/null
		else
			ewarn "Skipping patch --> $(basename $patch)"
		fi
	fi
}

# main function
kernel-geek_ApplyPatch() {
	local patch=$1
	local msg=$2
	shift
	echo
	einfo "${msg}"
	case `basename "$patch"` in
	patch_list) # list of patches
		while read -r line
		do
			# skip comments
			[[ $line =~ ^\ {0,}# ]] && continue
			# skip empty lines
			[[ -z "$line" ]] && continue
				ebegin "Applying $line"
					dir=`dirname "$patch"`
					Handler "$dir/$line"
				eend $?
		done < "$patch"
	;;
	*) # else is patch
		ebegin "Applying $(basename $patch)"
			Handler "$patch"
		eend $?
	;;
	esac
}

kernel-geek_src_unpack() {
	if [ "${A}" != "" ]; then
		ebegin "Extract the sources"
			tar xvJf "${DISTDIR}/linux-${KMV}.tar.xz" &>/dev/null
		eend $?
		cd "${WORKDIR}"
		mv "linux-${KMV}" "${S}"
	fi
	cd "${S}"
	ApplyPatch "${DISTDIR}/patch-${PV}.xz" "Update to latest upstream ..."

	if [[ $DEBLOB_AVAILABLE == 1 ]] && use deblob ; then
		cp "${DISTDIR}/deblob-${KMV}" "${T}" || die "cp deblob-${KMV} failed"
		cp "${DISTDIR}/deblob-check" "${T}/deblob-check" || die "cp deblob-check failed"
		chmod +x "${T}/deblob-${KMV}" "${T}/deblob-check" || die "chmod deblob scripts failed"
	fi
}

kernel-geek_src_prepare() {
	einfo "Copy current config from /proc"
	if [ -e "/usr/src/linux-${KV_FULL}/.config" ]; then
		ewarn "Kernel config file already exist."
		ewarn "I will NOT overwrite that."
	else
		einfo "Copying kernel config file."
		zcat /proc/config > .config || ewarn "Can't copy /proc/config"
	fi

	# Comment out EXTRAVERSION added by CK patch:
	use ck && sed -i -e 's/\(^EXTRAVERSION :=.*$\)/# \1/' "Makefile"

	einfo "Cleanup backups after patching"
	find '(' -name '*~' -o -name '*.orig' -o -name '.*.orig' -o -name '.gitignore'  -o -name '.*.old' ')' -print0 | xargs -0 -r -l512 rm -f
}

kernel-geek_src_compile() {
	if [[ $DEBLOB_AVAILABLE == 1 ]] && use deblob ; then
		echo ">>> Running deblob script ..."
		sh "${T}/deblob-${KMV}" --force || \
			die "Deblob script failed to run!!!"
	fi
}

kernel-geek_src_install() {
	local version_h_name="usr/src/linux-${KV_FULL}/include/linux"
	local version_h="${ROOT}${version_h_name}"

	if [ -f "${version_h}" ]; then
		einfo "Discarding previously installed version.h to avoid collisions"
		addwrite "/${version_h_name}"
		rm -f "${version_h}"
	fi

	cd "${S}"
	dodir /usr/src
	echo ">>> Copying sources ..."

	mv ${WORKDIR}/linux* "${D}"/usr/src
}

kernel-geek_pkg_postinst() {
	einfo " If you are upgrading from a previous kernel, you may be interested "
	einfo " in the following document:"
	einfo "   - General upgrade guide: http://www.gentoo.org/doc/en/kernel-upgrade.xml"
	einfo " geek-sources is UNSUPPORTED by Funtoo or Gentoo Security."
	einfo " This means that it is likely to be vulnerable to recent security issues."
	einfo " For specific information on why this kernel is unsupported, please read:"
	einfo " http://www.gentoo.org/proj/en/security/kernel.xml"
	echo
	einfo " Now is the time to configure and build the kernel."
	use uksm && einfo " Do not forget to disable the remote bug reporting feature by echo 0 > /sys/kernel/mm/uksm/usr_spt_enabled
	more http://kerneldedup.org/en/projects/uksm/uksmdoc/usage/"
}
