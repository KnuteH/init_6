# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
K_NOUSENAME="yes"
K_NOSETEXTRAVERSION="yes"
K_SECURITY_UNSUPPORTED="1"
K_DEBLOB_AVAILABLE="1"
ETYPE="sources"

CKV="${PVR/-r/-git}"
# only use this if it's not an _rc/_pre release
[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"
#CKV="3.3"

inherit kernel-2
detect_version

### PATCH LIST ###

# Budget Fair Queueing Budget I/O Scheduler
bfq_src_1="http://algo.ing.unimo.it/people/paolo/disk_sched/patches/3.3.0-v3r3/0001-block-cgroups-kconfig-build-bits-for-BFQ-v3r3-3.3.patch"
bfq_src_2="http://algo.ing.unimo.it/people/paolo/disk_sched/patches/3.3.0-v3r3/0002-block-introduce-the-BFQ-v3r3-I-O-sched-for-3.3.patch"
bfq_url="http://algo.ing.unimo.it/people/paolo/disk_sched/"

# Con Kolivas Brain Fuck CPU Scheduler
bfs_version="3.3"
bfs_src="http://ck.kolivas.org/patches/3.0/3.3/3.3-ck1/patch-${bfs_version}-ck1.bz2"
bfs_url="http://ck-hack.blogspot.com"

# Alternate CPU load distribution technique for Linux kernel scheduler
bld_version="3.3-rc3"
bld_src="http://bld.googlecode.com/files/bld-${bld_version}.tar.bz2"
bld_url="http://code.google.com/p/bld"

# Spock's fbsplash patch
fbcondecor_src="http://sources.gentoo.org/cgi-bin/viewvc.cgi/linux-patches/genpatches-2.6/trunk/3.4/4200_fbcondecor-0.9.6.patch"
fbcondecor_url="http://dev.gentoo.org/~spock/projects/fbcondecor"

# grsecurity security patches
grsecurity_version="201205130001"
grsecurity_src="http://grsecurity.net/test/grsecurity-2.9-${PV}-${grsecurity_version}.patch"
grsecurity_url="http://grsecurity.net"

## Ingo Molnar's realtime preempt patches
#rt_version="3.4-rc5-rt6"
#rt_src="http://www.kernel.org/pub/linux/kernel/projects/rt/3.4/patch-${rt_version}.patch.xz"
#rt_url="http://www.kernel.org/pub/linux/kernel/projects/rt"

# tomoyo security patches
css_version="1.8.3-20120401"
css_src="http://sourceforge.jp/frs/redir.php?m=jaist&f=/tomoyo/49684/ccs-patch-${css_version}.tar.gz"
css_url="http://tomoyo.sourceforge.jp"

# TuxOnIce
ice_url="http://tuxonice.net"

# Intermediate Queueing Device patches
imq_version="3.3"
imq_src="http://www.linuximq.net/patches/patch-imqmq-${imq_version}.diff.xz"
imq_url="http://www.linuximq.net"

# todo: add Xenomai: Real-Time Framework for Linux http://www.xenomai.org/
# Xenomai: Real-Time Framework for Linux http://www.xenomai.org/
#xenomai_ver="2.6.0" 
#xenomai_src="http://download.gna.org/xenomai/stable/xenomai-${xenomai_ver}.tar.bz2"
#xenomai_url="http://www.xenomai.org"

### END OF PATCH LIST ###

KEYWORDS="~amd64 ~x86"
#RDEPEND=">=sys-devel/gcc-4.5 \
#	grsecurity?	( >=sys-apps/gradm-2.2.2 )
#	rt?		( x11-drivers/nvidia-drivers[rt(+)] )
#	tomoyo?		( sys-apps/ccs-tools )"
RDEPEND=">=sys-devel/gcc-4.5 \
	grsecurity?	( >=sys-apps/gradm-2.2.2 )
	tomoyo?		( sys-apps/ccs-tools )
	ice? ( >=sys-apps/tuxonice-userui-1.0 )
	ice? ( || ( >=sys-power/hibernate-script-2.0 sys-power/pm-utils ) )"

#IUSE="bfq bfs bld branding deblob fbcondecor grsecurity rt tomoyo"
IUSE="bfq bfs bld branding deblob fbcondecor grsecurity ice imq tomoyo"
DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia, tomoyo and other patches"
#HOMEPAGE="http://www.kernel.org http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary ${bld_url} ${bfq_url} ${grsecurity_url} ${css_url} ${bfs_url} ${fbcondecor_url} ${rt_url}"
HOMEPAGE="http://www.kernel.org http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary http://svnweb.mageia.org/packages/cauldron/kernel/current ${bld_url} ${bfq_url} ${grsecurity_url} ${css_url} ${bfs_url} ${fbcondecor_url} ${imq_url} ${ice_url}"
#SRC_URI="${KERNEL_URI} ${ARCH_URI}
#	bfq?		( ${bfq_src_1} ${bfq_src_2} )
#	bfs?		( ${bfs_src} )
#	bld?		( ${bld_src} )
#	fbcondecor?	( ${fbcondecor_src} )
#	grsecurity?	( ${grsecurity_src} )
#	rt?		( ${rt_src} )
#	tomoyo?		( ${css_src} )"
SRC_URI="${KERNEL_URI} ${ARCH_URI}
	bfq?		( ${bfq_src_1} ${bfq_src_2} )
	bfs?		( ${bfs_src} )
	bld?		( ${bld_src} )
	fbcondecor?	( ${fbcondecor_src} )
	grsecurity?	( ${grsecurity_src} )
	imq?		( ${imq_src} )
	tomoyo?		( ${css_src} )"
REQUIRED_USE="bfs? ( !bld )
	bld? ( !bfs )
	fbcondecor? ( !grsecurity ) fbcondecor? ( !tomoyo )
	grsecurity? ( !tomoyo ) tomoyo? ( !grsecurity )"

KV_FULL="${PVR}-geek"
EXTRAVERSION="${RELEASE}-geek"
SLOT="${PV}"
S="${WORKDIR}/linux-${KV_FULL}"

src_unpack() {
	kernel-2_src_unpack
	cd "${S}"

	einfo "Make kernel default configs"
	cp "${FILESDIR}"/"${PVR}"/fedora/config-* . || die "cannot copy kernel config";
	cp "${FILESDIR}"/"${PVR}"/fedora/merge.pl "${FILESDIR}"/"${PVR}"/fedora/Makefile.config . &>/dev/null || die "cannot copy kernel files";
	make -f Makefile.config VERSION=${PVR} configs &>/dev/null || die "cannot generate kernel .config files from config-* files"
}

src_prepare() {

### PREPARE ###

	# Budget Fair Queueing Budget I/O Scheduler
	if use bfq; then
		EPATCH_OPTS="-p1 -F1 -s" \
		epatch "${DISTDIR}/0001-block-cgroups-kconfig-build-bits-for-BFQ-v3r3-3.3.patch"
		EPATCH_OPTS="-p1 -F1 -s" \
		epatch "${DISTDIR}/0002-block-introduce-the-BFQ-v3r3-I-O-sched-for-3.3.patch"
	fi

	# Con Kolivas Brain Fuck CPU Scheduler
	if use bfs; then
		EPATCH_OPTS="-p1 -F1 -s" \
		epatch "${DISTDIR}/patch-${bfs_version}-ck1.bz2"
	fi

	# Alternate CPU load distribution technique for Linux kernel scheduler
	if use bld; then
		cd "${T}"
		unpack "bld-${bld_version}.tar.bz2"
		cp "${T}/bld-${bld_version}/BLD_${bld_version}-feb12.patch" "${S}/BLD_${bld_version}-feb12.patch"
		cd "${S}"
		EPATCH_OPTS="-p1" epatch "${S}/BLD_${bld_version}-feb12.patch"
		rm -f "${S}/BLD_${bld_version}-feb12.patch"
		rm -r "${T}/bld-${bld_version}" # Clean temp
	fi

	# Spock's fbsplash patch
	if use fbcondecor; then
		epatch "${DISTDIR}/4200_fbcondecor-0.9.6.patch"
	fi

	# grsecurity security patches
	use grsecurity && epatch "${DISTDIR}/grsecurity-2.9-${PV}-${grsecurity_version}.patch"

	# TuxOnIce
#	use ice && epatch "${FILESDIR}/tuxonice-kernel-${PV}.patch.xz"
	use ice && epatch "${FILESDIR}/tuxonice-kernel-3.3.5.patch.xz"

	# Intermediate Queueing Device patches
	use imq && epatch "${DISTDIR}/patch-imqmq-${imq_version}.diff.xz"

#	# Ingo Molnar's realtime preempt patches
#	if use rt; then
#		epatch "${DISTDIR}/patch-${rt_version}.patch.xz"
#	fi

	# tomoyo security patches
	if use tomoyo; then
		cd "${T}"
		unpack "ccs-patch-${css_version}.tar.gz"
		cp "${T}/patches/ccs-patch-3.3.diff" "${S}/ccs-patch-3.3.diff"
		cd "${S}"
		EPATCH_OPTS="-p1" epatch "${S}/ccs-patch-3.3.diff"
		rm -f "${S}/ccs-patch-3.3.diff"
		# Clean temp
		rm -rf "${T}/config.ccs" "${T}/COPYING.ccs" "${T}/README.ccs"
		rm -r "${T}/include" "${T}/patches" "${T}/security" "${T}/specs"
	fi

#	if use xenomai; then
#		# Portage's ``unpack'' macro unpacks to the current directory. 
#		# Unpack to the work directory.  Afterwards, ``work'' contains: 
#		#   linux-2.6.29-xenomai-r5 
#		#   xenomai-2.4.9 
#		cd ${WORKDIR} 
#		unpack ${XENO_TAR} || die "unpack failed" 
#		cd ${WORKDIR}/${XENO_SRC} 
#		epatch ${FILESDIR}/prepare-kernel.patch || die "patch failed" 

#		scripts/prepare-kernel.sh --linux=${S} || die "prepare kernel failed" 
#	fi

### END OF PREPARE ###

### BRANCH APPLY ###

#
# Mageia linux http://svnweb.mageia.org/packages/cauldron/kernel/current/
#

# Upstream git

# Stable Queue

# Arch x86

# laptop needing pci=assign-busses (#18989, needs to be submitted upstream)
	epatch "${FILESDIR}"/"${PVR}"/mageia/x86-pci-toshiba-equium-a60-assign-busses.patch

# If users choose a bad video mode, allow to jump to
# a working one (TTL: forever)
	epatch "${FILESDIR}"/"${PVR}"/mageia/x86-boot-video-80x25-if-break.patch

# Allow poweroff on UP machines running SMP kernels
	epatch "${FILESDIR}"/"${PVR}"/mageia/x86-default_poweroff_up_machines.patch

# Fix #38760, need to be revised and submitted upstream
	epatch "${FILESDIR}"/"${PVR}"/mageia/x86-cpufreq-speedstep-dothan-3.patch

# https://qa.mandriva.com/show_bug.cgi?id=43155
	epatch "${FILESDIR}"/"${PVR}"/mageia/x86-p4_clockmod-reasonable-default-for-scaling_min_freq.patch

# raise vmalloc to fix https://bugs.mageia.org/show_bug.cgi?id=904
	epatch "${FILESDIR}"/"${PVR}"/mageia/x86-increase-default-minimum-vmalloc-area-by-64MB-to-192MB.patch

# Core

# PCI core

	epatch "${FILESDIR}"/"${PVR}"/mageia/pci-pciprobe-CardBusNo.patch

# http://lkml.org/lkml/2008/9/12/52
	epatch "${FILESDIR}"/"${PVR}"/mageia/pci-add-ALI-M5229-ide-compatibility-mode-quirk.patch

# add netbook specific patches
	epatch "${FILESDIR}"/"${PVR}"/mageia/init-netbook-Kconfig.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/init-netbook-dont-wait-for-mouse.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/init-netbook-retry-root-mount.patch

# PNP core

# Turns pnpbios off by default, useful, since pnpbios
# is know to cause problems (TTL: forever)
	epatch "${FILESDIR}"/"${PVR}"/mageia/pnp-pnpbios-off-by-default.patch

	epatch "${FILESDIR}"/"${PVR}"/mageia/pnp-isapnp-async-init.patch

# ACPI

# TTL: forever
	epatch "${FILESDIR}"/"${PVR}"/mageia/acpi-dsdt-initrd-v0.9c-2.6.28.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/acpi-dsdt-initrd-v0.9c-fixes.patch

# list acpi fixed events at /proc/acpi/fixed_events
	epatch "${FILESDIR}"/"${PVR}"/mageia/acpi-add-proc-event-regs.patch

# CLEVO M360S acpi irq workaround
	epatch "${FILESDIR}"/"${PVR}"/mageia/acpi-CLEVO-M360S-disable_acpi_irq.patch

# Clevo M720SR freezes with C3
	epatch "${FILESDIR}"/"${PVR}"/mageia/acpi-processor-M720SR-limit-to-C2.patch

# Blacklist acpi video for devices that must use shuttle-wmi
# for backlight because of buggy BIOS
	epatch "${FILESDIR}"/"${PVR}"/mageia/acpi-video-add-blacklist-to-use-vendor-driver.patch

# Block

# epsa2 SCSI driver, don't know from where it came
	epatch "${FILESDIR}"/"${PVR}"/mageia/scsi-ppscsi-2.6.2.patch

# epsa2 is far behind
	epatch "${FILESDIR}"/"${PVR}"/mageia/scsi-ppscsi_fixes.patch

# Fix build of ppscsi on 2.6.24
	epatch "${FILESDIR}"/"${PVR}"/mageia/scsi-ppscsi-sg-helper-update.patch

# Update/fix for ppscsi on 2.6.25
	epatch "${FILESDIR}"/"${PVR}"/mageia/scsi-ppscsi-update-for-scsi_data_buffer.patch

# https://qa.mandriva.com/show_bug.cgi?id=45393
	epatch "${FILESDIR}"/"${PVR}"/mageia/scsi-ppscsi-mdvbz45393.patch

# epsa2 3.0 buildfix
	epatch "${FILESDIR}"/"${PVR}"/mageia/scsi-ppscsi-3.0-buildfix.patch

# Don't know know why this is needed
	epatch "${FILESDIR}"/"${PVR}"/mageia/scsi-megaraid-new-sysfs-name.patch

# Looks like fixes from Arnaud, not sure why they're needed
	epatch "${FILESDIR}"/"${PVR}"/mageia/ide-pci-sis5513-965.patch

	epatch "${FILESDIR}"/"${PVR}"/mageia/mpt-vmware-fix.patch

# adds aliases to support upgrade from old dm-raid45 patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/dm-raid-aliases.patch

# prefer ata drivers before ide
	epatch "${FILESDIR}"/"${PVR}"/mageia/ata-prefer-ata-drivers-over-ide-drivers-when-both-are-built.patch

# Intel Lynx Point support
	epatch "${FILESDIR}"/"${PVR}"/mageia/ata-ahci-AHCI-mode-SATA-patch-for-Intel-Lynx-Point-Devic.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/ata-ata_piix-IDE-mode-SATA-patch-for-Intel-Lynx-Point-De.patch

# disable floppy autoloading (mga #4696)
	epatch "${FILESDIR}"/"${PVR}"/mageia/block-floppy-disable-pnp-modalias.patch

# more hw support
	epatch "${FILESDIR}"/"${PVR}"/mageia/ata-ahci-Detect-Marvell-88SE9172-SATA-controller.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/ata-ata_piix-IDE-mode-SATA-patch-for-Intel-DH89xxCC-DeviceIDs.patch

# File-system

# unionfs (http://www.filesystems.org/project-unionfs.html)
	epatch "${FILESDIR}"/"${PVR}"/mageia/fs-unionfs-2.5.11_for_3.3.0-rc6.patch

# aufs2 v2.1
# git://git.c3sl.ufpr.br/aufs/aufs2-2.6.git
# BROKEN: fs-aufs2.1-38.patch
# BROKEN: fs-aufs2.1-38-modular.patch

# FireWire

# adding module aliases to ease upgrade from ieee1394
	epatch "${FILESDIR}"/"${PVR}"/mageia/firewire-ieee1394-module-aliases.patch

# GPU/DRM

# new Q57 Host Bridge id
	epatch "${FILESDIR}"/"${PVR}"/mageia/char-agp-intel-new-Q57-id.patch

# External mach64 drm support from git://anongit.freedesktop.org/git/mesa/drm
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-mach64.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-mach64-fixes.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-mach64-2.6.31.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-mach64-fix-for-changed-drm_pci_alloc.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-mach64-fix-for-changed-drm_ioctl.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-mach64-2.6.36-buildfix.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-mach64-2.6.37-buildfix.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-mach64-3.0-buildfix.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-mach64-include-module.h.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-mach64-3.3-buildfix.patch

# drm changes to support nouveau and radeon backports
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-add-convenience-function-to-create-an-enum-prope.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-add-convenience-function-to-create-an-range-prop.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-add-some-caps-for-userspace-to-discover-more-inf.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-Add-drm_mode_copy.patch

# radeon backport to support Southern Islands (HD7xxx)
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-radeon-southern-islands-backport.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-radeon-southern-islands-backport-includes.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-radeon-Don-t-dereference-possibly-NULL-pointer.patch

# nouveau backport to support Kepler
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-nouveau-Kepler-backport.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-nouveau-move-out-of-staging-drivers.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-nouveau-fix-thinko-causing-init-to-fail-on-cards.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-nouveau-default-to-8bpc-for-non-LVDS-panels-if-E.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-nouveau-i2c-fix-thinko-regression-on-really-old-.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-nouveau-oops-create-m2mf-for-nvd9-too.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-nouveau-Revert-inform-userspace-of-new-kernel-su.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-nouveau-inform-userspace-of-relaxed-kernel-subch.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-nouveau-select-POWER_SUPPLY.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-nouveau-Fix-crash-when-pci_ram_rom-returns-a-size-of.patch
# BROKEN: gpu-drm-nouveau-bios-Fix-tracking-of-BIOS-image-data.patch

# i915 fixes
	epatch "${FILESDIR}"/"${PVR}"/mageia/gpu-drm-i915-add-Ivy-Bridge-GT2-Server-entries.patch

# Hardware Monitoring

# Input

# Kbuild

# https://qa.mandriva.com/show_bug.cgi?id=54028
	epatch "${FILESDIR}"/"${PVR}"/mageia/kbuild-compress-kernel-modules-on-installation.patch

# Media

# MM

# Network

# SiS 190 fixes
	epatch "${FILESDIR}"/"${PVR}"/mageia/net-sis190-fix-list-usage.patch

# netfilter IFWLOG support
	epatch "${FILESDIR}"/"${PVR}"/mageia/net-netfilter-IFWLOG.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/net-netfilter-IFWLOG-mdv.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/net-netfilter-IFWLOG-2.6.35-buildfix.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/net-netfilter-IFWLOG-2.6.37-buildfix.patch

# netfilter psd support
	epatch "${FILESDIR}"/"${PVR}"/mageia/net-netfilter-psd.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/net-netfilter-psd-mdv.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/net-netfilter-psd-2.6.35-buildfix.patch

# disable powersaving on rt2800
	epatch "${FILESDIR}"/"${PVR}"/mageia/net-wireless-rt2800usb_disable_ps.patch

# temp fix for mga #144
# DISABLED: net-wireless-ath9k-testfix.patch

# fix stability issues on ath5k
	epatch "${FILESDIR}"/"${PVR}"/mageia/net-wireless-ath5k-do-not-stop-queues-for-full-calibration.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/net-wireless-ath5k-do-not-re-run-AGC-calibration-periodically.patch

# Platform drivers

# Allow access to Shuttle WMI interface controls
# (Mainly allow turning on/off webcam and wireless on Shuttle DA18IE and DA18IM)
	epatch "${FILESDIR}"/"${PVR}"/mageia/platform-x86-add-shuttle-wmi-driver.patch

# RTC

# Serial

# Export pci_ids.h to user space, needed by ldetect
	epatch "${FILESDIR}"/"${PVR}"/mageia/include-kbuild-export-pci_ids.patch

# Sound

# adds bluetooth sco support
	epatch "${FILESDIR}"/"${PVR}"/mageia/sound-bluetooth-SCO-support.patch

# Model for hp Desktop/business machine
	epatch "${FILESDIR}"/"${PVR}"/mageia/sound-alsa-hda-ad1884a-hp-dc-model.patch

# Staging

# USB

# http://qa.mandriva.com/show_bug.cgi?id=30638
	epatch "${FILESDIR}"/"${PVR}"/mageia/bluetooth-hci_usb-disable-isoc-transfers.patch

	epatch "${FILESDIR}"/"${PVR}"/mageia/hid-usbhid-IBM-BladeCenterHS20-quirk.patch

	epatch "${FILESDIR}"/"${PVR}"/mageia/usb-storage-unusual_devs-add-id.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/usb-storage-unusual_devs-add-id-2.6.37-buildfix.patch

# V4L

# pwc driver name in /proc/bus/devices, /sys fix and "advertisement" removal
	epatch "${FILESDIR}"/"${PVR}"/mageia/media-video-pwc-lie-in-proc-usb-devices.patch

# bugfixes
	epatch "${FILESDIR}"/"${PVR}"/mageia/media-dvb-Fix-DVB-S-regression-caused-by-a-missing-initialization.patch

# Video

# Mageia framebuffer boot logo
	epatch "${FILESDIR}"/"${PVR}"/mageia/video-mageia-logo.patch

# https://qa.mandriva.com/show_bug.cgi?id=59260
# https://bugzilla.kernel.org/show_bug.cgi?id=26232
# DISABLED: video-fb-avoid-oops-when-fw-fb-is-removed.patch
# DISABLED: video-fb-avoid-deadlock-caused-by-fb_set_suspend.patch

# 3rdparty

	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-3rdparty-1.0-tree.patch

# TODO: fix up patch below to include all archs?
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-3rdparty-merge.patch

# acerhk
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-acerhk-0.5.35.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-acerhk-kbuild.patch # Failed
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-acerhk-extra-cflags.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-acerhk-proc_dir_entry-owner.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-acerhk-fix-build-with-function-tracer.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-acerhk-2.6.36-buildfix.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-acerhk-fix-include.patch

# aes2501
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-aes2501-r19.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-aes2501-kbuild.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-aes2501-rmmod-oops-fix.patch

# heci
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-heci-3.2.0.24.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-heci-WARN-redefine.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-heci-use-sched.h.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-heci-2.6.36-buildfix.patch

# ndiswrapper
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-ndiswrapper-1.57.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-ndiswrapper-Kconfig.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-ndiswrapper-Makefile-build-fix.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-ndiswrapper-1.57-3.3-buildfix.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-ndiswrapper-buildhack.patch

# rfswitch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-rfswitch-1.3.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-rfswitch-build-fix.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-rfswitch-3.0-buildfix.patch

# viahss
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-viahss-0.92.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-viahss-config.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-viahss-module-license.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-viahss-2.6.35-buildfix.patch
	EPATCH_OPTS="-p1 -F1 -s" epatch "${FILESDIR}"/"${PVR}"/mageia/3rd-viahss-3.0-buildfix.patch

# Security

# Smack fixes
	epatch "${FILESDIR}"/"${PVR}"/mageia/smack-unionfs-deadlock-fix.patch

# XEN

# ARM
	epatch "${FILESDIR}"/"${PVR}"/mageia/arm_fix_bad_udelay_usage.patch
	epatch "${FILESDIR}"/"${PVR}"/mageia/kbuild_firmware_install.patch

#
# Fedora Linux http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary
#

	epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-makefile-after_link.patch

# Architecture patches
# x86(-64)

#
# ARM
#
# 	epatch "${FILESDIR}"/"${PVR}"/fedora/arm-omap-dt-compat.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/arm-smsc-support-reading-mac-address-from-device-tree.patch

	epatch "${FILESDIR}"/"${PVR}"/fedora/taint-vbox.patch
#
# NX Emulation
#
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-32bit-mmap-exec-randomization.patch
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-i386-nx-emulation.patch
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/fedora/nx-emu-remove-cpuinitdata-for-disable_nx-on-x86_32.patch

#
# bugfixes to drivers and filesystems
#

# ext4
#rhbz 753346
	epatch "${FILESDIR}"/"${PVR}"/fedora/jbd-jbd2-validate-sb-s_first-in-journal_get_superblo.patch

# xfs

# btrfs

# eCryptfs

# NFSv4
	epatch "${FILESDIR}"/"${PVR}"/fedora/NFSv4-Reduce-the-footprint-of-the-idmapper.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/NFSv4-Further-reduce-the-footprint-of-the-idmapper.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/NFSv4-Minor-cleanups-for-nfs4_handle_exception-and-n.patch

# NFS Client Patch set from Upstream
	epatch "${FILESDIR}"/"${PVR}"/fedora/NFS-optimise-away-unnecessary-setattrs-for-open-O_TRUNC.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/NFSv4-fix-open-O_TRUNC-and-ftruncate-error-handling.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/NFSv4-Rate-limit-the-state-manager-for-lock-reclaim-.patch

# USB

# WMI

# ACPI
	epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-defaults-acpi-video.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-acpi-video-dos.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-acpi-debug-infinite-loop.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/acpi-sony-nonvs-blacklist.patch

#
# PCI
#
# enable ASPM by default on hardware we expect to work
	epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-defaults-aspm.patch

#
# SCSI Bits.
#

# ACPI

# ALSA

#rhbz 808559
	epatch "${FILESDIR}"/"${PVR}"/fedora/ALSA-hda-realtek-Add-quirk-for-Mac-Pro-5-1-machines.patch

# Networking

# Misc fixes
# The input layer spews crap no-one cares about.
	epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-input-kill-stupid-messages.patch

# stop floppy.ko from autoloading during udev...
#	epatch "${FILESDIR}"/"${PVR}"/fedora/die-floppy-die.patch # Failed
	epatch "${FILESDIR}"/"${PVR}"/fedora/floppy-drop-disable_hlt-warning.patch

	epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6.30-no-pcspkr-modalias.patch

# Allow to use 480600 baud on 16C950 UARTs
	epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-serial-460800.patch

# Silence some useless messages that still get printed with 'quiet'
	epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-silence-noise.patch

	epatch "${FILESDIR}"/"${PVR}"/fedora/silence-timekeeping-spew.patch

# Make fbcon not show the penguins with 'quiet'
	epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-silence-fbcon-logo.patch

# Changes to upstream defaults.

# /dev/crash driver.
	epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-crash-driver.patch

# Hack e1000e to work on Montevina SDV
	epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-e1000-ich9-montevina.patch

# crypto/

# Assorted Virt Fixes
	epatch "${FILESDIR}"/"${PVR}"/fedora/fix_xen_guest_on_old_EC2.patch

# DRM core
#	epatch "${FILESDIR}"/"${PVR}"/fedora/drm-edid-try-harder-to-fix-up-broken-headers.patch

# Intel DRM
	epatch "${FILESDIR}"/"${PVR}"/fedora/drm-i915-dp-stfu.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/drm-i915-fbc-stfu.patch

	epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-intel-iommu-igfx.patch

# silence the ACPI blacklist code
	epatch "${FILESDIR}"/"${PVR}"/fedora/linux-2.6-silence-acpi-blacklist.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/quite-apm.patch

# Media (V4L/DVB/IR) updates/fixes/experimental drivers
#  apply if non-empty
	epatch "${FILESDIR}"/"${PVR}"/fedora/add-poll-requested-events.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/dvbs-fix-zigzag.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/drivers-media-update.patch

# Patches headed upstream

	epatch "${FILESDIR}"/"${PVR}"/fedora/disable-i8042-check-on-apple-mac.patch

# rhbz#605888
	epatch "${FILESDIR}"/"${PVR}"/fedora/dmar-disable-when-ricoh-multifunction.patch

	epatch "${FILESDIR}"/"${PVR}"/fedora/efi-dont-map-boot-services-on-32bit.patch

	epatch "${FILESDIR}"/"${PVR}"/fedora/lis3-improve-handling-of-null-rate.patch

	epatch "${FILESDIR}"/"${PVR}"/fedora/bluetooth-use-after-free.patch

	epatch "${FILESDIR}"/"${PVR}"/fedora/ips-noirq.patch

# utrace.
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/fedora/utrace.patch

#	epatch "${FILESDIR}"/"${PVR}"/fedora/pci-crs-blacklist.patch

	epatch "${FILESDIR}"/"${PVR}"/fedora/ext4-Support-check-none-nocheck-mount-options.patch

#rhbz 772772
	epatch "${FILESDIR}"/"${PVR}"/fedora/rt2x00_fix_MCU_request_failures.patch

#rhbz 754518
#	epatch "${FILESDIR}"/"${PVR}"/fedora/scsi-sd_revalidate_disk-prevent-NULL-ptr-deref.patch

#rhbz 789644
	epatch "${FILESDIR}"/"${PVR}"/fedora/mcelog-rcu-splat.patch

#rhbz 804957 CVE-2012-1568
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/fedora/shlib_base_randomize.patch

	epatch "${FILESDIR}"/"${PVR}"/fedora/unhandled-irqs-switch-to-polling.patch

# debug patches
	epatch "${FILESDIR}"/"${PVR}"/fedora/weird-root-dentry-name-debug.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/debug-808990.patch

#rhbz 804347
	epatch "${FILESDIR}"/"${PVR}"/fedora/x86-add-io_apic_ops-to-allow-interception.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/x86-apic_ops-Replace-apic_ops-with-x86_apic_ops.patch
	epatch "${FILESDIR}"/"${PVR}"/fedora/xen-x86-Implement-x86_apic_ops.patch

#rhbz 807632
	epatch "${FILESDIR}"/"${PVR}"/fedora/libata-forbid-port-runtime-pm-by-default.patch

#rhbz 806295
	epatch "${FILESDIR}"/"${PVR}"/fedora/disable-hid-battery.patch

#rhbz 814278 814289 CVE-2012-2119
	epatch "${FILESDIR}"/"${PVR}"/fedora/macvtap-zerocopy-validate-vector-length.patch

#rhbz 817298
	epatch "${FILESDIR}"/"${PVR}"/fedora/ipw2x00-add-supported-cipher-suites-to-wiphy-initialization.patch

#rhbz 818820
	epatch "${FILESDIR}"/"${PVR}"/fedora/dl2k-Clean-up-rio_ioctl.patch

### END OF PATCH APPLICATIONS ###

	# Oops: ACPI: EC: input buffer is not empty, aborting transaction - 2.6.32 regression
	# https://bugzilla.kernel.org/show_bug.cgi?id=14733#c41
	epatch "${FILESDIR}"/acpi-ec-add-delay-before-write.patch

	# USE branding
	if use branding; then
		epatch "${FILESDIR}"/font-8x16-iso-latin-1-v2.patch
		epatch "${FILESDIR}"/gentoo-larry-logo-v2.patch
	fi

# Unfortunately, it has yet not been ported into 3.0 kernel.
# Check out here for the progress: http://www.kernel.org/pub/linux/kernel/people/edward/reiser4/
# http://sourceforge.net/projects/reiser4/
#	use reiser4 && epatch ${DISTDIR}/reiser4-for-${PV}.patch.bz2

# Install the docs
	nonfatal dodoc "${FILESDIR}/${PVR}"/fedora/{README.txt,TODO}

	echo
	einfo "Live long and prosper."
	echo

	einfo "Set extraversion" # manually set extraversion
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" Makefile

	einfo "Delete temp files"
	for cfg in {config-*,temp-*,merge.pl}; do
		rm -f $cfg
	done;
}

src_install() {
	local version_h_name="usr/src/linux-${KV_FULL}/include/linux"
	local version_h="${ROOT}${version_h_name}"

	if [ -f "${version_h}" ]; then
		einfo "Discarding previously installed version.h to avoid collisions"
		addwrite "/${version_h_name}"
		rm -f "${version_h}"
	fi

	kernel-2_src_install
}

pkg_postinst() {
	if [ ! -e ${ROOT}usr/src/linux ]
	then
		ln -sf "${ROOT}usr/src/linux" "${ROOT}usr/src/linux-${KV_FULL}"
	fi

	einfo "Now is the time to configure and build the kernel."
	use bfq && einfo "bfq enable Budget Fair Queueing Budget I/O Scheduler patches - ${bfq_url}"
	use bfs && einfo "bfs enable Con Kolivas Brain Fuck CPU Scheduler patches - ${bfs_url}"
	use bld && einfo "bld enable Alternate CPU load distribution technique for Linux kernel scheduler - ${bld_url}"
	if use branding; then
		einfo "branding enable:"
		einfo "font - CONFIG_FONT_ISO_LATIN_1_8x16 http://sudormrf.wordpress.com/2010/10/23/ka-ping-yee-iso-latin-1%c2%a0font-in-linux-kernel/"
		einfo "logo - CONFIG_LOGO_LARRY_CLUT224 http://www.gentoo.org/proj/en/desktop/artwork/artwork.xml"
	fi
	use fbcondecor && einfo "fbcondecor enable Spock's fbsplash patch - ${fbcondecor_url}"
	use grsecurity && einfo "grsecurity enable grsecurity security patches - ${grsecurity_url}"
	use ice && einfo "ice enable TuxOnIce patches - ${ice_url}"
	use imq && einfo "imq enable Intermediate Queueing Device patches - ${imq_url}"
#	use rt && einfo "rt enable Ingo Molnar's realtime preempt patches - ${rt_url}"
	use tomoyo && einfo "tomoyo enable tomoyo security patches - ${css_url}"
}
