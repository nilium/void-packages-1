#!/bin/bash
#
# build.sh

export HOSTREPO="${HOSTREPO:-$(pwd)}"

if [ "$1" != "$2" ]; then
	arch="-a $2"
fi

# Tell xbps-src what is our arch, this is done when doing
# binary-bootstrap, but we need to do it every time since
# our masterdir is ethereal.
# /bin/echo -e '\x1b[32mWriting bootstrap arch into .xbps_chroot_init of masterdir\x1b[0m'
# echo "$1" > /hostrepo/masterdir/.xbps_chroot_init

/bin/echo -e '\x1b[32mPreparing chroot with chroot_prepare()\x1b[0m'
source "${HOSTREPO}/common/xbps-src/shutils/chroot.sh" || {
	echo "Failed to source chroot.sh for chroot_prepare()" >&2 ;
	exit 1
}

XBPS_SRCPKGDIR="${HOSTREPO}/srcpkgs" XBPS_MASTERDIR=/ chroot_prepare $1 || {
	echo "Failed to prepare chroot!" >&2 ;
	exit 1
}

# Two times due to updating xbps itself
"${HOSTREPO}/xbps-src" -H "$HOSTREPO"/hostdir bootstrap-update
"${HOSTREPO}/xbps-src" -H "$HOSTREPO"/hostdir bootstrap-update

PKGS=$("${HOSTREPO}/xbps-src" sort-dependencies $(cat /tmp/templates))

NPROCS=1
if [ -r /proc/cpuinfo ]; then
        NPROCS=$(grep ^proc /proc/cpuinfo|wc -l)
fi

for pkg in ${PKGS}; do
	"${HOSTREPO}/xbps-src" -j$NPROCS -H "$HOSTREPO"/hostdir $arch pkg "$pkg"
	[ $? -eq 1 ] && exit 1
done

exit 0
