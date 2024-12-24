#!/bin/bash

#
# This will add a startup like shell file where you can customize it. The file will be placed under /tp_data directory where the contents is written to flash
# Any other location you save it will wipe out all the changes on reboot, as the rootfs system is R/W but in memory only.
#

cat << 'EOF' > squashfs-root/etc/init.d/rclocal
#!/bin/sh /etc/rc.common
START=99
start() {
        touch /tp_data/rc.local
        chmod +x /tp_data/rc.local
        . /tp_data/rc.local
        return 0
}
stop() {
        return 0
}
EOF

chmod +x squashfs-root/etc/init.d/rclocal
ln -s ../init.d/rclocal squashfs-root/etc/rc.d/S99rclocal
