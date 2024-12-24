#!/bin/bash

#
# If you don't need SSH access, dont run this script and it will be purged from your system.
#
# A new clean dropbear binary will be installed on the system, because the one TPlink ships in the firmware has been modified by them
#


#
# place your public key in this variable
#
# KEY BASED ONLY LOGIN. DON'T USE PASSWORD!
#
pubkey=""



if [ -z "$pubkey" ]; then
   echo "You need to add your public key to this script before run!!"
   exit
fi

mkdir -p squashfs-root/root/.ssh
mkdir -p squashfs-root/etc/dropbear
echo $pubkey >squashfs-root/root/.ssh/authorized_keys

#
# download an updated and crap free dropbear
#
wget https://bitfab.org/dropbear-static-builds/dropbear-v2020.81-arm-none-linux-gnueabi-static.tgz
tar xvf dropbear-v2020.81-arm-none-linux-gnueabi-static.tgz

mv dropbearmulti squashfs-root/usr/sbin/dropbearmulti
ln -s dropbearmulti squashfs-root/usr/sbin/dropbear
ln -s dropbearmulti squashfs-root/usr/sbin/dropbearkey
ln -s dropbearmulti squashfs-root/usr/sbin/scp
ln -s dropbearmulti squashfs-root/usr/sbin/ssh
rm dropbear*


#
# place in startup script
#
cat << 'EOF' > squashfs-root/etc/init.d/dropbear
#!/bin/sh /etc/rc.common
START=99
start() {
        chown root.root -R /root
        chmod 700 -R /root
        dropbear -P /var/run/dropbear.1.pid -p 22 -R -s
        return 0
}
stop() {
        kill -9 $(cat /var/run/dropbear.1.pid)
        return 0
}
EOF

chmod +x squashfs-root/etc/init.d/dropbear
ln -s ../init.d/dropbear squashfs-root/etc/rc.d/S99dropbear





#
# WARNING - NOT RECOMMENDED! YOU'RE WARNED
#

# enable telnet back, if you like living a dangerous life
#ln -s ../init.d/telnet squashfs-root/etc/rc.d/S99telnet

