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

# input boost 
echo "0:1190400 2:1036800" > /sys/module/cpu_boost/parameters/multi_boost_freq
echo "0:1190400 2:1036800" > /sys/module/cpu_boost/parameters/input_boost_freq
echo 40 > /sys/module/cpu_boost/parameters/input_boost_ms
echo 1 > /sys/module/cpu_boost/parameters/sched_boost_on_input

function write() {
   $BB echo -n "$2" > "$1"
}

CREATE_CPUSETS() {
	# Make sure CPUSET is set right
    mkdir /dev/cpuset
    mount cpuset none /dev/cpuset
    mkdir /dev/cpuset/foreground
    write /dev/cpuset/foreground/cpus 0
    write /dev/cpuset/foreground/mems 0
    mkdir /dev/cpuset/foreground/boost
    write /dev/cpuset/foreground/boost/cpus 0
    write /dev/cpuset/foreground/boost/mems 0
    mkdir /dev/cpuset/background
    write /dev/cpuset/background/cpus 0
    write /dev/cpuset/background/mems 0	
    # system-background is for system tasks that should only run on
    # little cores, not on bigs
    # to be used only by init, so don't change system-bg permissions
    mkdir /dev/cpuset/system-background
    write /dev/cpuset/system-background/cpus 0
    write /dev/cpuset/system-background/mems 0
    mkdir /dev/cpuset/top-app
    write /dev/cpuset/top-app/cpus 0
    write /dev/cpuset/top-app/mems 0	
    # change permissions for all cpusets we'll touch at runtime
    chown system system /dev/cpuset
    chown system system /dev/cpuset/foreground
    chown system system /dev/cpuset/foreground/boost
    chown system system /dev/cpuset/background
    chown system system /dev/cpuset/system-background
    chown system system /dev/cpuset/top-app
    chown system system /dev/cpuset/tasks
    chown system system /dev/cpuset/foreground/tasks
    chown system system /dev/cpuset/foreground/boost/tasks
    chown system system /dev/cpuset/background/tasks
    chown system system /dev/cpuset/system-background/tasks
    chown system system /dev/cpuset/top-app/tasks	
    # set system-background to 0775 so SurfaceFlinger can touch it
    chmod 0775 /dev/cpuset/system-background
    chmod 0664 /dev/cpuset/foreground/tasks
    chmod 0664 /dev/cpuset/foreground/boost/tasks
    chmod 0664 /dev/cpuset/background/tasks
    chmod 0664 /dev/cpuset/system-background/tasks
    chmod 0664 /dev/cpuset/top-app/tasks
    chmod 0664 /dev/cpuset/tasks
}
CREATE_CPUSETS;

SET_CPUSETS() {
	# Update foreground and background cpusets
	write /dev/cpuset/foreground/cpus 0-3
	write /dev/cpuset/foreground/boost/cpus 0-3
	write /dev/cpuset/background/cpus 0-1
	write /dev/cpuset/camera-daemon/cpus 0-3
	write /dev/cpuset/system-background/cpus 0-3
	write /dev/cpuset/top-app/cpus 0-3
	write /dev/cpuset/major/cpus 0-3
}
SET_CPUSETS;

CPU_BUS_DCVS() {
	# Enable bus-dcvs
	for cpubw in /sys/class/devfreq/*qcom,cpubw* ; do
		write $cpubw/governor "bw_hwmon"
		write $cpubw/polling_interval 50
		write $cpubw/min_freq 1525
		write $cpubw/bw_hwmon/mbps_zones "1525 5195 11863 13763"
		write $cpubw/bw_hwmon/sample_ms 4
		write $cpubw/bw_hwmon/bw_step 190
		write $cpubw/bw_hwmon/io_percent 27
		write $cpubw/bw_hwmon/hist_memory 20
		write $cpubw/bw_hwmon/hyst_length 10
		write $cpubw/bw_hwmon/low_power_ceil_mbps 0
		write $cpubw/bw_hwmon/low_power_io_percent 30
		write $cpubw/bw_hwmon/low_power_delay 20
		write $cpubw/bw_hwmon/guard_band_mbps 0
		write $cpubw/bw_hwmon/up_scale 250
		write $cpubw/bw_hwmon/idle_mbps 1600
	done

}
CPU_BUS_DCVS;

# Kernel tweak
echo "0" > /proc/sys/vm/oom_kill_allocating_task; # default: 0
echo "0" > /proc/sys/vm/panic_on_oom; # default: 0
echo "5" > /proc/sys/kernel/panic; # default: 5
echo "0" > /proc/sys/kernel/panic_on_oops; # default: 1
echo "5" > /proc/sys/vm/dirty_background_ratio; # default: 5
echo "20" > /proc/sys/vm/dirty_ratio; # default: 20
echo "4" > /proc/sys/vm/min_free_order_shift; # default: 4
echo "1" > /proc/sys/vm/overcommit_memory; # default: 1
echo "50" > /proc/sys/vm/overcommit_ratio; # default: 50
echo "0" > /proc/sys/vm/page-cluster; # default: 0
echo "60" > /proc/sys/vm/swappiness; # default: 60
echo "100" > /proc/sys/vm/vfs_cache_pressure; # default: 60
echo "200" > /proc/sys/vm/dirty_expire_centisecs; # default: 60
# mem calc here in pages. so 16384 x 4 = 64MB reserved for fast access by kernel and VM
echo "32768" > /proc/sys/vm/mmap_min_addr; #default: 32768
echo "94912" > /proc/sys/vm/min_free_kbytes;

# Permissions for LMK
chmod 0664 /sys/module/lowmemorykiller/parameters/adj
chmod 0664 /sys/module/lowmemorykiller/parameters/minfree
chmod 0664 /sys/module/lowmemorykiller/parameters/cost
chmod 0664 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
chmod 0664 /sys/module/lowmemorykiller/parameters/vmpressure_file_min

# Tune LMK with values we love
echo 0 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
echo "18432,23040,27648,51256,150296,200640" > /sys/module/lowmemorykiller/parameters/minfree
echo 81250 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
echo 32 > /sys/module/lowmemorykiller/parameters/cost

echo 1 > /sys/module/process_reclaim/parameters/enable_process_reclaim
echo 70 > /sys/module/process_reclaim/parameters/pressure_max
echo 30 > /sys/module/process_reclaim/parameters/swap_opt_eff
echo 10 > /sys/module/process_reclaim/parameters/pressure_min
echo 1024 > /sys/module/process_reclaim/parameters/per_swap_size


# KCAL for LG G5/V20 panel
echo "240 240 240" > /sys/devices/platform/kcal_ctrl.0/kcal

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

$BB sh /sbin/launch_daemonsu.sh;

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

