# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: Andrey Ovcharov <sudormrfhalt@gmail.com>
# Purpose: kernel-2 replacer.
#
# Bugs to sudormrfhalt@gmail.com
#

EXPORT_FUNCTIONS ApplyPatch src_unpack src_prepare src_compile src_install pkg_postinst

# No need to run scanelf/strip on kernel sources/headers (bug #134453).
RESTRICT="mirror binchecks strip"

# Even though xz-utils are in @system, they must still be added to DEPEND; see
# http://archives.gentoo.org/gentoo-dev/msg_a0d4833eb314d1be5d5802a3b710e0a4.xml
DEPEND="${DEPEND} app-arch/xz-utils"

OLDIFS="$IFS"
VER="${PV}"
IFS='.'
set -- ${VER}
IFS="${OLDIFS}"

# the kernel version (e.g 3 for 3.4.2)
VERSION="${1}"
# the kernel patchlevel (e.g 4 for 3.4.2)
PATCHLEVEL="${2}"
# the kernel sublevel (e.g 2 for 3.4.2)
SUBLEVEL="${3}"
# the kernel major version (e.g 3.4 for 3.4.2)
KMV="${1}.${2}"

# ebuild default values setup settings
EXTRAVERSION="-geek"
KV_FULL="${PVR}${EXTRAVERSION}"
S="${WORKDIR}"/linux-"${KV_FULL}"
SLOT="${PV}"

KNOWN_FEATURES="branding deblob fbcondecor fedora ice mageia rt suse uksm"

SRC_URI="http://www.kernel.org/pub/linux/kernel/v3.x/linux-${KMV}.tar.xz
	http://www.kernel.org/pub/linux/kernel/v3.x/patch-${KMV}.xz"

# deblob
deblob_src="http://linux-libre.fsfla.org/pub/linux-libre/releases/LATEST-${KMV}.N/deblob-${KMV} http://linux-libre.fsfla.org/pub/linux-libre/releases/LATEST-${KMV}.N/deblob-check"

# Spock's fbsplash patch
fbcondecor_src="http://sources.gentoo.org/cgi-bin/viewvc.cgi/linux-patches/genpatches-2.6/trunk/${KMV}/4200_fbcondecor-0.9.6.patch"

# Ingo Molnar's realtime preempt patches
rt_src="http://www.kernel.org/pub/linux/kernel/projects/rt/${KMV}/patch-${rt_ver/KMV/$KMV}.patch.xz"

featureKnown() {
	local feature="${1/-/}"
	feature="${feature/+/}"
	[ "${feature}" == "" ] && die "Feature not defined!"

	expr index "${SUPPORTED_FEATURES}" "${feature}" >/dev/null || die "${feature} is not supported in current kernel"
	expr index "${KNOWN_FEATURES}" "${feature}" >/dev/null || die "${feature} is not known"
	IUSE="${IUSE} ${feature}"
	case ${feature} in
		deblob)
			if [ "${OVERRIDE_deblob_src}" != "" ]; then
				deblob_src="${OVERRIDE_deblob_src}"
			fi
			deblob_url="http://linux-libre.fsfla.org/pub/linux-libre/"
			HOMEPAGE="${HOMEPAGE} ${deblob_url}"
			SRC_URI="${SRC_URI}
				deblob?		( ${deblob_src} )"
			;;
		fbcondecor)
			if [ "${OVERRIDE_fbcondecor_src}" != "" ]; then
				fbcondecor_src="${OVERRIDE_fbcondecor_src}"
			fi
			fbcondecor_url="http://dev.gentoo.org/~spock/projects/fbcondecor"
			HOMEPAGE="${HOMEPAGE} ${fbcondecor_url}"
			SRC_URI="${SRC_URI}
				fbcondecor?	( ${fbcondecor_src} )"
			;;
		fedora)
			fedora_url="http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary"
			HOMEPAGE="${HOMEPAGE} ${fedora_url}"
			;;
		mageia)
			mageia_url="http://svnweb.mageia.org/packages/cauldron/kernel/current"
			HOMEPAGE="${HOMEPAGE} ${mageia_url}"
			;;
		rt)
			rt_url="http://www.kernel.org/pub/linux/kernel/projects/rt"
			HOMEPAGE="${HOMEPAGE} ${rt_url}"
			SRC_URI="${SRC_URI}
				rt?		( ${rt_src} )"
			;;
		suse)
			suse_url="http://kernel.opensuse.org/cgit/kernel-source"
			HOMEPAGE="${HOMEPAGE} ${suse_url}"
			;;
		uksm)
			uksm_url="http://kerneldedup.org"
			HOMEPAGE="${HOMEPAGE} ${uksm_url}"
			;;
	esac
}

for I in ${SUPPORTED_FEATURES}; do
	featureKnown "${I}"
done

# default argument to patch
patch_command='patch -p1 -F1 -s'
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
kernel-geek-temp-3.5_ApplyPatch() {
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

kernel-geek-temp-3.5_src_unpack() {
	if [ "${A}" != "" ]; then
		ebegin "Extract the sources"
			tar xvJf "${DISTDIR}/linux-${KMV}.tar.xz" &>/dev/null
		eend $?
		cd "${WORKDIR}"
		mv "linux-${KMV}" "${S}"
	fi
	cd "${S}"
	ApplyPatch "${DISTDIR}/patch-${KMV}.xz" "Update to latest upstream ..."

	if [[ $DEBLOB_AVAILABLE == 1 ]] && use deblob ; then
		cp "${DISTDIR}/deblob-${KMV}" "${T}" || die "cp deblob-${KMV} failed"
		cp "${DISTDIR}/deblob-check" "${T}/deblob-check" || die "cp deblob-check failed"
		chmod +x "${T}/deblob-${KMV}" "${T}/deblob-check" || die "chmod deblob scripts failed"
	fi
}

kernel-geek-temp-3.5_src_prepare() {

	use fbcondecor && ApplyPatch "${DISTDIR}/4200_fbcondecor-0.9.6.patch" "Spock's fbsplash patch - ${fbcondecor_url}"

	use rt && ApplyPatch "${DISTDIR}/patch-${rt_ver}.patch.xz" "Ingo Molnar's realtime preempt patches - ${rt_url}"

	use uksm && ApplyPatch "${FILESDIR}/${PV}/uksm/patch_list" "Ultra Kernel Samepage Merging - ${uksm_url}"

### BRANCH APPLY ###

	use mageia && ApplyPatch "$FILESDIR/${PV}/mageia/patch_list" "Mandriva/Mageia - ${mageia_url}"

	use fedora && ApplyPatch "$FILESDIR/${PV}/fedora/patch_list" "Fedora - ${fedora_url}"

	use suse && ApplyPatch "$FILESDIR/${PV}/suse/patch_list" "OpenSuSE - ${suse_url}"

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

	einfo "Set extraversion in Makefile" # manually set extraversion
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" Makefile

	# Comment out EXTRAVERSION added by CK patch:
	use ck && sed -i -e 's/\(^EXTRAVERSION :=.*$\)/# \1/' "Makefile"
	
	einfo "Copy current config from /proc"
	if [ -e "/usr/src/linux-${KV_FULL}/.config" ]; then
		ewarn "Kernel config file already exist."
		ewarn "I will NOT overwrite that."
	else
		einfo "Copying kernel config file."
		zcat /proc/config > .config || ewarn "Can't copy /proc/config"
	fi

	einfo "Cleanup backups after patching"
	find '(' -name '*~' -o -name '*.orig' -o -name '.*.orig' -o -name '.gitignore'  -o -name '.*.old' ')' -print0 | xargs -0 -r -l512 rm -f
}

kernel-geek-temp-3.5_src_compile() {
	if [[ $DEBLOB_AVAILABLE == 1 ]] && use deblob ; then
		echo ">>> Running deblob script ..."
		sh "${T}/deblob-${KMV}" --force || \
			die "Deblob script failed to run!!!"
	fi
}

kernel-geek-temp-3.5_src_install() {
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

kernel-geek-temp-3.5_pkg_postinst() {
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
