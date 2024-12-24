#!/bin/bash

#
# Avira binaries and stuff removal. This is useless crap
#

find squashfs-root -type f -o -type d -o -type l | while read -r item; do
    if echo "$item" | grep -q '/usr/lib/lua\|/usr/share/lua'; then
        echo "Skipping WEB UI path: $item"
        continue
    fi

    if echo "$item" | grep -qi "avira"; then
        if [ -e "$item" ] || [ -L "$item" ]; then
            rm -rf "$item"
            echo "Removed: $item"
        fi
    fi
done

rm -vf squashfs-root/etc/dns_cache_list
rm -vf squashfs-root/etc/init.d/tp_security
rm -vf squashfs-root/etc/init.d/url_class
rm -vf squashfs-root/etc/rc.d/K10tp_security
rm -vf squashfs-root/etc/rc.d/K25url_class
rm -vf squashfs-root/etc/rc.d/S50tp_security
sed -i 's| /usr/share/.avira||g' squashfs-root/lib/preinit/71_init_etc_ramfs


#
# Cloud, Family protection, Alexa, SmartHome, auto updates etc.... all this stuff is tied together. Wipe them out
#
# Note: WIP! items with XXX at the start causes issues with the WEB UI if removed.
#

find squashfs-root -type f -o -type d -o -type l | while read -r item; do
    if echo "$item" | grep -q '/usr/lib/lua\|/usr/share/lua\|/www'; then
        echo "Skipping WEB UI path: $item"
        continue
    fi

    if echo "$item" | grep -qi "cloud\|parental\|XXXmali\|XXXfamily\|XXXsmart_home\|XXXclient_mgmt\|XXXdomain_login"; then
        if [ -e "$item" ] || [ -L "$item" ]; then
            rm -rf "$item"
            echo "Removed: $item"
        fi
    fi
done

#
# remove more crap
#

rm -vf squashfs-root/etc/init.d/auto_upgrade
rm -vf squashfs-root/etc/rc.d/S99auto_upgrade
#rm -rvf squashfs-root/lib/wportal
rm -vf squashfs-root/etc/config/auto_upgrade
rm -vf squashfs-root/usr/sbin/dut_auto_upgrade
rm -vf squashfs-root/usr/sbin/fing_device_recognize
rm -vf squashfs-root/usr/sbin/fwv2_upgrade_timer
rm -vf squashfs-root/usr/sbin/new_client_access_report
rm -vf squashfs-root/usr/sbin/report_download_elapsedTime
rm -vf squashfs-root/usr/sbin/report_get_device_status
rm -vf squashfs-root/usr/sbin/report_upload_alert
rm -vf squashfs-root/usr/sbin/report_upload_bind
rm -vf squashfs-root/usr/sbin/report_upload_components
rm -vf squashfs-root/usr/sbin/report_upload_daily
rm -vf squashfs-root/usr/sbin/report_upload_dpi
rm -vf squashfs-root/usr/sbin/report_upload_period
rm -vf squashfs-root/usr/sbin/report_upload_time_apply
rm -vf squashfs-root/usr/sbin/report_upload_unbind
rm -vf squashfs-root/usr/sbin/report_upload_url_apply
sed -i -e '/^local cloud_brd=/d' -e 's/cloud_brd //g' squashfs-root/etc/monit/monit_proclist
sed -i -e '/^local client_mgmt=/d' -e 's/client_mgmt //g' squashfs-root/etc/monit/monit_proclist
sed -i -e '/^#local url_class=/d' -e 's/url_class //g' squashfs-root/etc/monit/monit_proclist
sed -i 's| /usr/sbin/cloud_cleanFwInfo||' squashfs-root/lib/upgrade/platform.sh
sed -i '/cloud_account/d' squashfs-root/sbin/switch_mode
sed -i '/domain_login/d' squashfs-root/lib/netifd/proto/passthrough.sh



# !!ATTENTION!!
#
#
# Some binaries are heavily patched by TPlink, I decompiled some and found really weird stuff inside that I don't like.
# I found this (a part of the decompiled code) inside dropbear binary:
#
#    if ( !memcmp(*(const void **)a2, "scp -f /etc/3g4g.gz", 0x13u) ) ---- whitelisting SCP session commands
#
#    lua_getfield(v7, -10002, "require")
#    lua_pushstring(v7, "cloud_req.cloud_account")   ---- cloud account tied to SSH,SCP logins
#
# We're going to purge this crap from the system, if you want to enable it in the correct way, look at 03-enable-ssh.sh
#

find squashfs-root -name "dropbear*" -exec rm -rvf {} \;
find squashfs-root -name scp -exec rm -rvf {} \;
