#!/sbin/busybox sh

BB=/sbin/busybox;

setenforce 0

# Some script copy from Alucard

OPEN_RW()
{
	if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
		$BB mount -o remount,rw /;
	fi;
	if [ "$($BB mount | grep system | grep -c ro)" -eq "1" ]; then
		$BB mount -o remount,rw /system;
	fi;
}
OPEN_RW;

$BB chmod 644 /system/lib/modules/*.ko;

# run ROM scripts
$BB sh /system/etc/init.qcom.post_boot.sh;
# $BB sh /init.qcom.post_boot.sh;
OPEN_RW;

CRITICAL_PERM_FIX()
{
	# critical Permissions fix
	$BB chown -R root:root /tmp;
	$BB chown -R root:root /res;
	$BB chown -R root:root /sbin;
	# $BB chown -R root:root /lib;
	$BB chmod -R 777 /tmp/;
	$BB chmod -R 775 /res/;
	$BB chmod -R 06755 /sbin/ext/;
	$BB chmod 06755 /sbin/busybox;
	#$BB chmod 06755 /system/xbin/busybox;
	$BB chmod 0555 /system/xbin/busybox;
}
CRITICAL_PERM_FIX;

#echo 120 > /sys/module/cpu_boost/parameters/boost_ms
#echo 1497600 > /sys/module/cpu_boost/parameters/sync_threshold
#echo 1497600 > /sys/module/cpu_boost/parameters/input_boost_freq
#echo 980 > /sys/module/cpu_boost/parameters/input_boost_ms

# Permissions for LMK
chmod 0664 /sys/module/lowmemorykiller/parameters/adj
chmod 0664 /sys/module/lowmemorykiller/parameters/minfree
chmod 0664 /sys/module/lowmemorykiller/parameters/cost
chmod 0664 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
chmod 0664 /sys/module/lowmemorykiller/parameters/vmpressure_file_min

# Tune LMK with values we love
echo "12288,15360,18432,21504,24576,30720" > /sys/module/lowmemorykiller/parameters/minfree
echo 32 > /sys/module/lowmemorykiller/parameters/cost

# disable debugging on some modules
  echo "N" > /sys/module/kernel/parameters/initcall_debug;
  echo "0" > /sys/module/smd/parameters/debug_mask
  echo "0" > /sys/module/smem/parameters/debug_mask
  echo "0" > /sys/module/event_timer/parameters/debug_mask
  echo "0" > /sys/module/smp2p/parameters/debug_mask
  echo "0" > /sys/module/msm_serial_hs_lge/parameters/debug_mask
  echo "0" > /sys/module/rpm_smd/parameters/debug_mask
  echo "0" > /sys/module/xt_qtaguid/parameters/debug_mask
  echo "0" > /sys/module/qpnp_regulator/parameters/debug_mask
  echo "0" > /sys/module/binder/parameters/debug_mask
  echo "0" > /sys/module/msm_show_resume_irq/parameters/debug_mask
  echo "0" > /sys/module/mpm_of/parameters/debug_mask
  echo "0" > /sys/module/msm_pm/parameters/debug_mask
OPEN_RW;

# Adaptive LMK
# $BB echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
# $BB echo 53059 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min

# Process Reclaim
# echo 1 > /sys/module/process_reclaim/parameters/enable_process_reclaim
# echo 100 > /sys/module/process_reclaim/parameters/pressure_max

# Tweak VM
echo 200 > /proc/sys/vm/dirty_expire_centisecs
echo 20 > /proc/sys/vm/dirty_background_ratio
echo 40 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/swappiness

# disable lge triton service
if [ -e /system/bin/triton ]; then
	/system/bin/stop triton
fi;

# Stop LG logging to /data/logger/$FILE we dont need that. draning power.
setprop persist.service.events.enable 0
setprop persist.service.main.enable 0
setprop persist.service.power.enable 0
setprop persist.service.radio.enable 0
setprop persist.service.system.enable 0


CLEAN_BUSYBOX()
{
	for f in *; do
		case "$($BB readlink "$f")" in *usybox*)
			$BB rm "$f"
		;;
		esac
	done;
}

INSTALL_BUSYBOX()
{
if [ ! -e /system/etc/busybox_installed ];then
	# Cleanup the old busybox symlinks
	cd /system/xbin/;
	CLEAN_BUSYBOX;

	cd /system/bin/;
	CLEAN_BUSYBOX;

	cd /sbin/;
	CLEAN_BUSYBOX;

	cd /;

	# Install latest busybox to the ROM
	cp /sbin/busybox /system/xbin/;

	/system/xbin/busybox --install -s /system/xbin/
	chmod 0555 /system/xbin/busybox;

	touch /system/etc/busybox_installed;
fi
}
INSTALL_BUSYBOX;
if [ ! -d /system/etc/init.d ]; then
	mkdir /system/etc/init.d;
fi
chmod 755 /system/etc/init.d/*
$BB run-parts /system/etc/init.d/

# Make tmp folder
mkdir /tmp;

# Give permissions to execute
chown -R root:system /tmp/;
chmod -R 777 /tmp/;
chmod -R 777 /res/;
chmod 6755 /res/synapse/actions/*;
chmod 6755 /sbin/*;
chmod 6755 /system/xbin/*;
echo "Boot initiated on $(date)" > /tmp/bootcheck;

chmod +x /res/synapse/uci
ln -s /res/synapse/uci /sbin/uci
chmod +x /sbin/uci
/sbin/uci

echo "768" > /proc/sys/kernel/random/read_wakeup_threshold;
echo "256" > /proc/sys/kernel/random/write_wakeup_threshold;

# sharpe control
if [ -e /data/.jz_sy/sharpening ];then
    chmod 0755 /data/.jz_sy/sharpening;
    echo `cat /data/.jz_sy/sharpening` > /sys/devices/virtual/panel/img_tune/sharpness;
fi
# sharpe control
exit;
