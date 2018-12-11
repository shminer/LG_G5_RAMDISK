#!/sbin/busybox sh

BB=/sbin/busybox;

# Make tmp folder
mkdir /tmp;

CRITICAL_PERM_FIX()
{
	# critical Permissions fix
	chown -R root:root /tmp;
	chown -R root:root /res;
	chown -R root:root /sbin;
	#chown -R root:root /lib;
	$BB chmod -R 777 /tmp/;
	$BB chmod -R 775 /res/;
	chmod 755 /sbin/busybox;
	chmod 755 /root/busybox;
}
CRITICAL_PERM_FIX;

setenforce 0

# Some script copy from Alucard

OPEN_RW()
{
	if [ "$(mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
		mount -o remount,rw /;
	fi;
	if [ "$(mount | grep system | grep -c ro)" -eq "1" ]; then
		mount -o remount,rw /system;
	fi;
}
OPEN_RW;

# $BB chmod 644 /system/lib/modules/*.ko;

# run ROM scripts
# $BB sh /system/etc/init.qcom.post_boot.sh;
# $BB sh /init.qcom.post_boot.sh;

# Adjust for alucard cpu gonvernor(default gonvernor)
# e.g. wr_alu_cpufreq argv1 argv2 argv3
wr_alu_cpufreq()
{
	echo ${3} > /sys/devices/system/cpu/cpu${1}/cpufreq/alucard/${2}
}
grep "alucard" /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors > /dev/null
if [ "$?" == 0 ];then
	chmod 0644 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
	chmod 0644 /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
	echo "alucard" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
	echo "alucard" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
	wr_alu_cpufreq 0 freq_responsiveness 1190400
	wr_alu_cpufreq 0 freq_responsiveness_max 1228800
	wr_alu_cpufreq 0 cpus_up_rate_at_max_freq 1
	wr_alu_cpufreq 0 cpus_up_rate 1
	wr_alu_cpufreq 0 cpus_down_rate_at_max_freq 1
	wr_alu_cpufreq 0 cpus_down_rate 1
	wr_alu_cpufreq 0 pump_inc_step_at_min_freq 4
	wr_alu_cpufreq 0 pump_inc_step 2
	wr_alu_cpufreq 0 pump_dec_step_at_min_freq 1
	wr_alu_cpufreq 0 pump_dec_step 1

	wr_alu_cpufreq 2 freq_responsiveness 1190400
	wr_alu_cpufreq 2 freq_responsiveness_max 1248000
	wr_alu_cpufreq 2 cpus_up_rate_at_max_freq 2
	wr_alu_cpufreq 2 cpus_up_rate 1
	wr_alu_cpufreq 2 cpus_down_rate_at_max_freq 1
	wr_alu_cpufreq 2 cpus_down_rate 1
	wr_alu_cpufreq 2 pump_inc_step_at_min_freq 2
	wr_alu_cpufreq 2 pump_inc_step 1
	wr_alu_cpufreq 2 pump_dec_step_at_min_freq 1
	wr_alu_cpufreq 2 pump_dec_step 1
fi
echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "interactive" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
# input boost 
echo "0:960000 2:1036800" > /sys/module/cpu_boost/parameters/multi_boost_freq
echo "0:960000 2:1036800" > /sys/module/cpu_boost/parameters/input_boost_freq
echo 45 > /sys/module/cpu_boost/parameters/input_boost_ms
# echo 1 > /sys/module/cpu_boost/parameters/sched_boost_on_input


# thermal
echo "1324800" > /sys/module/msm_thermal/parameters/c0_ioctl_user_max_freq_limit
echo "1036800" > /sys/module/msm_thermal/parameters/c1_ioctl_user_max_freq_limit

function write() {
   echo -n "$2" > "$1"
}

CPU_BUS_DCVS() {
	# Enable bus-dcvs
	for cpubw in /sys/class/devfreq/*qcom,cpubw* ; do
		write $cpubw/governor "bw_hwmon"
		write $cpubw/polling_interval 50
		write $cpubw/min_freq 1525
		write $cpubw/bw_hwmon/mbps_zones "1525 5195 11863 13763"
		write $cpubw/bw_hwmon/sample_ms 4
		write $cpubw/bw_hwmon/bw_step 190
		write $cpubw/bw_hwmon/io_percent 30
		write $cpubw/bw_hwmon/hist_memory 20
		write $cpubw/bw_hwmon/hyst_length 10
		write $cpubw/bw_hwmon/low_power_ceil_mbps 0
		write $cpubw/bw_hwmon/low_power_io_percent 34
		write $cpubw/bw_hwmon/low_power_delay 20
		write $cpubw/bw_hwmon/guard_band_mbps 0
		write $cpubw/bw_hwmon/up_scale 250
		write $cpubw/bw_hwmon/idle_mbps 1600
	done

}
CPU_BUS_DCVS;

# KCAL for LG G5/V20 panel
echo "240 240 240" > /sys/devices/platform/kcal_ctrl.0/kcal
echo "258" > /sys/devices/platform/kcal_ctrl.0/kcal_val # for LG O-OS

# for my earpod
SC=/sys/class/misc/soundcontrol
echo "4" > $SC/mic_boost
echo "20" > $SC/volume_boost

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

if [ -e /root/rctd ]; then
	rm /root/rctd
fi;

if [ -e /sbin/rctd ]; then
	rm /sbin/rctd
fi;

/system/bin/stop rctd

# Stop LG logging to /data/logger/$FILE we dont need that. draning power.
setprop persist.service.events.enable 0
setprop persist.service.main.enable 0
setprop persist.service.power.enable 0
setprop persist.service.radio.enable 0
setprop persist.service.system.enable 0


CLEAN_BUSYBOX()
{
	for f in *; do
		case "$(readlink "$f")" in *usybox*)
			rm "$f"
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
#INSTALL_BUSYBOX;

if [ ! -d /system/etc/init.d ]; then
	mkdir /system/etc/init.d;
fi

# Give permissions to execute
chown -R root:system /tmp/;
chmod -R 777 /tmp/;
chmod -R 777 /res/;
chmod 6755 /res/synapse/actions/*;
chmod 6755 /sbin/*;
# chmod 6755 /system/xbin/*;
echo "Boot initiated on $(date)" > /tmp/bootcheck;

chmod +x /res/synapse/uci
/res/synapse/uci
ln -s /res/synapse/uci /sbin/uci

#echo "768" > /proc/sys/kernel/random/read_wakeup_threshold;
#echo "256" > /proc/sys/kernel/random/write_wakeup_threshold;

chmod 755 /system/etc/init.d/*
$BB run-parts /system/etc/init.d/

exit;

