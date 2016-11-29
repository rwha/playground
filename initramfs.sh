#!/bin/bash

copy() {
	local file
	[ "$2" == "lib" ] && file=$(PATH=/lib:/usr/lib type -p $1) || file=$(type -p $1)
	
	[ -n $file ] && cp $file $WDIR/$2 || {
		echo "Missing required file: $1 for directory $2";
		rm -rf $WDIR;
		exit 1;
	}
}

[ -z $1 ] && INITRAMFS_FILE=initrd.img-no-kmods || { 
	KERNEL_VERSION=$1; 
	INITRAMFS_FILE=initrd.img-$KERNEL_VERSION; 
}

[ -n "$KERNEL_VERSION" ] && [ -d "/lib/modules/$1" ] || { echo "No modules directory named $1"; exit 1; }

printf "Creating ${INITRAMFS_FILE}..."

binfiles="sh cat cp dd killall ls mkdir mknod mount umount sed sleep ln rm uname"

# Systemd puts udevadm in /bin...
[ -x /bin/udevadm ] && binfiles+=" udevadm";

sbinfiles="modprobe blkid switch_root"

# optional...
for f in mdadm mdmon udevd udevadm; do
	[ -x /sbin/${f} ] && sbinfiles+=" ${f}"
done
unset f

unsorted=$(mktemp /tmp/unsorted.XXXXXXXXXX)
WDIR=$(mktemp -d /tmp/initrd-work.XXXXXXXXXX)

mkdir -p $WDIR/{bin,dev,lib/firmware,run,sbin,sys,proc}
mkdir -p $WDIR/etc/{modprobe.d,udev/rules.d}
touch $WDIR/etc/modprobe.d/modprobe.conf
ln -s lib $WDIR/lib64

mknod -m 640 $WDIR/dev/console c 5 1
mknod -m 664 $WDIR/dev/null c 1 3

[ -f /etc/udev/udev.conf ] && cp /etc/udev/udev.conf $WDIR/etc/udev/udev.conf

for file in $(find /etc/udev/rules.d/ -type f); do
	cp "${file}" $WDIR/etc/udev/rules.d
done
unset file

cp -a /lib/firmware $WDIR/lib

[ -f /etc/mdadm.conf ] && cp /etc/mdadm.conf $WDIR/etc/mdadm.conf

cat > $WDIR/init << EOFINIT
#!/bin/sh
PATH=/bin:/usr/bin:/sbin:/usr/sbin
export PATH

problem() {
	printf "Encountered a problem!\n\nDropping you into a shell.\n\n"
	sh
}

no_device() {
	printf "The device %s, which is supposed to contain the\n" $1
	printf "root filesystem, does not exist.\n"
	printf "Please fix this problem and exit this shell.\n"
}

no_mount() {
	printf "Could not mount device %s\n" $1
	printf "Sleeping forever. Please reboot and fix the kernel command line.\n\n"
	printf "Maybe thie device is formatted with an unsupported file system?\n\n"
	printf "Or maybe the filesystem type autodetection went wrong, in which case\n"
	printf "you should add the rootfstype=... parameter to the kernel command line.\n\n"
	printf "Available partitions:\n"
}

do_mount_root() {
	mkdir /.root
	[ -n "$rootflags" ] && rootflags="$rootflags,"
	rootflags+="$ro"
	
	case "$root" in
		/dev/*	) device=$root ;;
		UUID=*	) eval $root; device=/dev/disk/by-uuid/$UUID ;;
		LABEL=*	) eval $root; device=/dev/disk/by-label/$LABEL ;;
		""		) echo "No root device specified."; problem ;;
	esac
	
	while [ -b "$device" ]; do
		no_device $device
		problem
	done
	
	if ! mount -n -t "rootfstype" -o "$rootflags" "$device" /.root ; then
		no_mount $device
		cat /proc/partitions
		while true ; do sleep 10000; done
	else
		echo "Successfully mounted device $root"
	fi
}

init=/sbin/init
root=
rootdelay
rootfstype=auto
ro="ro"
rootflags=
device=

mount -n -t devtmpfs devtmpfs /dev
mount -n -t proc proc /proc
mount -n -t sysfs sysfs /sys
mount -n -t tmpfs tmpfs /run

read -r cmdline < /proc/cmdline

for param in $cmdline ; do
	case $param in
		init=* ) init=${param#init=} ;;
		root=* ) root=${param#root=} ;;
		rootdelay=* ) rootdelay=${param#rootdelay=} ;;
		rootfstype=* ) rootfstype=${param#rootfstype=} ;;
		rootflags=* ) rootflags=${param#rootflags=} ;;
		ro ) ro="ro" ;;
		rw ) ro="rw" ;;
	esac
done

# udevd locations...
[ -x /sbin/udevd ] && UDEVD=/sbin/udevd || { 
	[ -x /lib/udev/udevd ] && UDEVD=/lib/udev/udevd || { 
		[ -x /lib/systemd/systemd-udevd ] && UDEVD=/lib/systemd/systemd-udevd || { 
			echo "Cannot find udevd nor systemd-udevd"; problem; 
		} 
	} 
}

${UDEVD} --daemon --resolve-names=never
udevadm trigger
udevadm settle

[ -f /etc/mdadm.conf ] && mdadm -As
[ -x /sbin/vgchange ] && /sbin/vgchange -a y > /dev/null
[ -n "$rootdelay" ] && sleep "$rootdelay"

do_mount_root

killall -w ${UDEVD##*/}

exec switch_root /.root "$init" "$@"

EOFINIT

chmod 0755 $WDIR/init

[ -n "$KERNEL_VERSION" ] && {
	[ -x /bin/kmod ] && binfiles+=" kmod" || { 
		binfiles+=" lsmod"; 
		sbinfiles+=" insmod"; 
	}
}

# Install binaries
for f in $binfiles; do
	ldd /bin/$f | sed "s/\t//" | cut -d " " -f1 >> $unsorted
	copy $f bin
done
unset f

# Add lvm
[ -x /sbin/lvm ] && sbinfiles+=" lvm dmsetup"

for f in $sbinfiles; do
	ldd /sbin/$f | sed "s/\t//" | cut -d " " -f1 >> $unsorted
	copy $f sbin
done
unset f

# Add udevd libs if not in /sbin
[ -x /lib/udev/udevd ] && { 
	ldd /lib/udev/udevd | sed "s/\t//" | cut -d " " -f1 >> $unsorted; 
} || [ -x /lib/systemd/systemd-udevd ] && {
	ldd /lib/systemd/systemd-udevd | sed "s/\t//" | cut -d " " -f1 >> $unsorted;
}

# mod sylinks
[ -n "$KERNEL_VERSION" ] && [ -x /bin/kmod ] && {
	ln -s kmod $WDIR/bin/lsmod;
	ln -s kmod $WDIR/bin/insmod;
}

# lvm.conf and lvm symlinks 
[ -x /sbin/lvm ] && {
	for l in change rename extend create display scan; do
		ln -s lvm $WDIR/sbin/lv${l};
	done
	
	for p in change ck create display scan; do
		ln -s lvm $WDIR/sbin/pv${p};
	done
	
	for v in change create scan rename ck; do
		ln -s lvm $WDIR/sbin/vg${v};
	done
	unset l p v
	cp -a /etc/lvm $WDIR/etc
}

# install libs
sort $unsorted | uniq | while read libr; do
	[ "$libr" == "linux-vdso.so.1" -o "$libr" == "linux-gate.so.1" ] && continue
	copy $libr lib
done

[ -d /lib/udev ] && cp -a /lib/udev $WDIR/lib

[ -d /lib/systemd ] && cp -a /lib/systemd $WDIR/lib

# install kernel modules if requested
[ -n "$KERNEL_VERSION" ] && {
	find \
		/lib/modules/$KERNEL_VERSION/kernel/{crypto,fs,lib} \
		/lib/modules/$KERNEL_VERSION/kernel/drivers/{block,ata,md,firewire} \
		/lib/modules/$KERNEL_VERSION/kernel/drivers/{scsi,message,pcmcia,virtio} \
		/lib/modules/$KERNEL_VERSION/kernel/drivers/usb/{host,storage} \
		-type f 2> /dev/null | cpio --make-directories -p --quiet $WDIR
		
	cp /lib/modules/$KERNEL_VERSION/modules.{builtin,order} $WDIR/lib/modules/$KERNEL_VERSION
	
	depmod -b $WDIR $KERNEL_VERSION
}

( cd $WDIR && find . | cpio -o -H newc --quiet | gzip -9 ) > $INITRAMFS_FILE

rm -rf $WDIR $unsorted

printf "done. \n"

