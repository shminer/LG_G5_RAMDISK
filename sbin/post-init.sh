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
	wr_alu_cpufreq 0 freq_responsiveness 1113600
	wr_alu_cpufreq 0 freq_responsiveness_max 1324800
	wr_alu_cpufreq 0 cpus_up_rate_at_max_freq 2
	wr_alu_cpufreq 0 cpus_up_rate 1
	wr_alu_cpufreq 0 cpus_down_rate_at_max_freq 1
	wr_alu_cpufreq 0 cpus_down_rate 1
	wr_alu_cpufreq 0 pump_inc_step_at_min_freq 4
	wr_alu_cpufreq 0 pump_inc_step 2
	wr_alu_cpufreq 0 pump_dec_step_at_min_freq 1
	wr_alu_cpufreq 0 pump_dec_step 1

	wr_alu_cpufreq 2 freq_responsiveness 1324800
	wr_alu_cpufreq 2 freq_responsiveness_max 1920000
	wr_alu_cpufreq 2 cpus_up_rate_at_max_freq 1
	wr_alu_cpufreq 2 cpus_up_rate 1
	wr_alu_cpufreq 2 cpus_down_rate_at_max_freq 1
	wr_alu_cpufreq 2 cpus_down_rate 1
	wr_alu_cpufreq 2 pump_inc_step_at_min_freq 3
	wr_alu_cpufreq 2 pump_inc_step 2
	wr_alu_cpufreq 2 pump_dec_step_at_min_freq 1
	wr_alu_cpufreq 2 pump_dec_step 2
fi

wr_alusched_cpufreq()
{
	echo ${3} > /sys/devices/system/cpu/cpu${1}/cpufreq/alucardsched/${2}
}
grep "schedalucard" /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors > /dev/null
if [ "$?" == 0 ];then
	chmod 0644 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
	chmod 0644 /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
	echo "schedalucard" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
	echo "schedalucard" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
	wr_alusched_cpufreq 0 freq_responsiveness 1190400
	wr_alusched_cpufreq 0 iowait_boost_enable 1
	wr_alusched_cpufreq 0 boost_perc 0
	wr_alusched_cpufreq 0 pump_inc_step_at_min_freq 2
	wr_alusched_cpufreq 0 pump_inc_step 1
	wr_alusched_cpufreq 0 pump_dec_step_at_min_freq 1
	wr_alusched_cpufreq 0 pump_dec_step 1

	wr_alusched_cpufreq 2 freq_responsiveness 1248000
	wr_alusched_cpufreq 2 iowait_boost_enable 1
	wr_alusched_cpufreq 2 boost_perc 0
	wr_alusched_cpufreq 2 pump_inc_step_at_min_freq 2
	wr_alusched_cpufreq 2 pump_inc_step 1
	wr_alusched_cpufreq 2 pump_dec_step_at_min_freq 1
	wr_alusched_cpufreq 2 pump_dec_step 1
fi

# input boost 
echo "0:1190400 2:1248000" > /sys/module/cpu_boost/parameters/multi_boost_freq
echo 1050 > /sys/module/cpu_boost/parameters/input_boost_ms

# from Eliminater74
function write() {
   $BB echo -n "$2" > "$1"
}

CREATE_EAS_CGROUPS_STUNE_TUNING_NODES() {
	# Create energy-aware scheduler tuning nodes
    mkdir /sys/fs/cgroup/stune
    mount -t cgroup none /sys/fs/cgroup/stune schedtune
	#mount -t cgroup -o schedtune stune /sys/fs/cgroup/stune
    mkdir /sys/fs/cgroup/stune/foreground
	mkdir /sys/fs/cgroup/stune/performance
    chown system system /sys/fs/cgroup/stune
    chown system system /sys/fs/cgroup/stune/foreground
    chown system system /sys/fs/cgroup/stune/tasks
    chown system system /sys/fs/cgroup/stune/foreground/tasks
    chmod 0664 /sys/fs/cgroup/stune/tasks
    chmod 0664 /sys/fs/cgroup/stune/foreground/tasks
	chmod 0664 /sys/fs/cgroup/stune/performance/tasks
}
CREATE_EAS_CGROUPS_STUNE_TUNING_NODES;

CREATE_EAS_TUNING_NODES() {
	# Create energy-aware scheduler tuning nodes
    mkdir /dev/stune
    mount -t cgroup none /dev/stune schedtune
    mkdir /dev/stune/foreground
    mkdir /dev/stune/background
    mkdir /dev/stune/top-app
    chown system system /dev/stune
    chown system system /dev/stune/foreground
    chown system system /dev/stune/background
    chown system system /dev/stune/top-app
    chown system system /dev/stune/tasks
    chown system system /dev/stune/foreground/tasks
    chown system system /dev/stune/background/tasks
    chown system system /dev/stune/top-app/tasks
    chmod 0664 /dev/stune/tasks
    chmod 0664 /dev/stune/foreground/tasks
    chmod 0664 /dev/stune/background/tasks
    chmod 0664 /dev/stune/top-app/tasks
}
CREATE_EAS_TUNING_NODES;

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

SET_EAS_CGROUP_STUNE() {
	write /sys/fs/cgroup/stune/cgroup.clone_children 0
	# write /sys/fs/cgroup/stune/cgroup.procs
	write /sys/fs/cgroup/stune/cgroup.sane_behavior 1
	write /sys/fs/cgroup/stune/notify_on_release 0
	# write /sys/fs/cgroup/stune/release_agent
	write /sys/fs/cgroup/stune/schedtune.boost 5
	write /sys/fs/cgroup/stune/schedtune.prefer_idle 1
	# write /sys/fs/cgroup/stune/tasks

	### Perfomance ###
	write /sys/fs/cgroup/stune/performance/cgroup.clone_children 0
	# write /sys/fs/cgroup/stune/performance/cgroup.procs
	write /sys/fs/cgroup/stune/performance/notify_on_release 0
	write /sys/fs/cgroup/stune/performance/schedtune.boost 100
	write /sys/fs/cgroup/stune/performance/schedtune.prefer_idle 0
	# write /sys/fs/cgroup/stune/performance/tasks

	write /proc/sys/kernel/sched_child_runs_first 0
	write /proc/sys/kernel/sched_cstate_aware 1
	write /proc/sys/kernel/sched_initial_task_util 0
	write /proc/sys/kernel/sched_is_big_little 1
	write /proc/sys/kernel/sched_latency_ns 10000000
	write /proc/sys/kernel/sched_migration_cost_ns 500000
	write /proc/sys/kernel/sched_min_granularity_ns 900000
	write /proc/sys/kernel/sched_nr_migrate 24
	write /proc/sys/kernel/sched_rr_timeslice_ms 10
	write /proc/sys/kernel/sched_rt_period_us 1000000
	write /proc/sys/kernel/sched_rt_runtime_us 950000
	write /proc/sys/kernel/sched_shares_window_ns 10000000
	write /proc/sys/kernel/sched_sync_hint_enable 1
	write /proc/sys/kernel/sched_time_avg_ms 1000
	write /proc/sys/kernel/sched_tunable_scaling 0
	write /proc/sys/kernel/sched_use_walt_cpu_util 1
	write /proc/sys/kernel/sched_use_walt_task_util 1
	write /proc/sys/kernel/sched_wakeup_granularity_ns 250000
	write /proc/sys/kernel/sched_walt_cpu_high_irqload 10000000
	write /proc/sys/kernel/sched_walt_init_task_load_pct 10
}
SET_EAS_CGROUP_STUNE;
	
SET_CPUSETS() {
	# Update foreground and background cpusets
	write /dev/cpuset/foreground/cpus 0-3
	write /dev/cpuset/foreground/boost/cpus 0-3
	write /dev/cpuset/background/cpus 0-2
	write /dev/cpuset/camera-daemon/cpus 0-2
	write /dev/cpuset/system-background/cpus 0-1
	write /dev/cpuset/top-app/cpus 0-3
	# set default schedTune value for foreground/top-app (only affects EAS)
	write /dev/stune/foreground/schedtune.prefer_idle 1
	write /dev/stune/schedtune.boost 20
	write /dev/stune/schedtune.prefer_idle 1
}
SET_CPUSETS;

CPU_BUS_DCVS() {
	# Enable bus-dcvs
	for cpubw in /sys/class/devfreq/*qcom,cpubw* ; do
		write $cpubw/governor "bw_hwmon"
		write $cpubw/polling_interval 50
		write $cpubw/min_freq 1525
		write $cpubw/bw_hwmon/mbps_zones "1525 5195 11863 13763"
		write $cpubw/bw_hwmon/sample_ms 2
		write $cpubw/bw_hwmon/bw_step 170
		write $cpubw/bw_hwmon/io_percent 25
		write $cpubw/bw_hwmon/hist_memory 20
		write $cpubw/bw_hwmon/hyst_length 10
		write $cpubw/bw_hwmon/low_power_ceil_mbps 0
		write $cpubw/bw_hwmon/low_power_io_percent 25
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
echo "8" > /proc/sys/vm/dirty_background_ratio; # default: 5
echo "28" > /proc/sys/vm/dirty_ratio; # default: 20
echo "4" > /proc/sys/vm/min_free_order_shift; # default: 4
echo "1" > /proc/sys/vm/overcommit_memory; # default: 1
echo "50" > /proc/sys/vm/overcommit_ratio; # default: 50
echo "0" > /proc/sys/vm/page-cluster; # default: 0
echo "85" > /proc/sys/vm/swappiness; # default: 60
echo "55" > /proc/sys/vm/vfs_cache_pressure; # default: 60
# mem calc here in pages. so 16384 x 4 = 64MB reserved for fast access by kernel and VM
echo "32768" > /proc/sys/vm/mmap_min_addr; #default: 32768

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
