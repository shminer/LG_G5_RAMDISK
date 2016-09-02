cat << CTAG
{
	name:{en:"I/O", zh_CN:"I/O控制"},
		elements:[
			{ STitleBar:{
				title:{en:"I/O Control", zh_CN:"I/O控制"},
			}},
				{ SSeekBar:{
					title:{en:"Read-ahead Size", zh_CN:"预读取缓存大小"},
					description:{en:"Set the read-ahead size for the internal storage.", zh_CN:"设置内部存储器的预读取缓存大小."},
					unit:" KB",
					step:128,
					min:128,
					max:4096,
					default:`$BB cat /sys/block/mmcblk0/queue/read_ahead_kb`,
					action:"ioset queue read_ahead_kb"
				}},
				{ SOptionList:{
					title:{en:"I/O Scheduler", zh_CN:"I/O 调度策略"},
					description:{en:"The I/O Scheduler decides how to prioritize and handle I/O requests. More info: <a href='http://timos.me/tm/wiki/ioscheduler'>HERE</a>", zh_CN:"I/O 调度器决定了IO的读取时如何划分优先级的. 更多内容请参考: <a href='http://timos.me/tm/wiki/ioscheduler'>HERE</a>"},
					default:`$BB echo $(/res/synapse/actions/bracket-option \`sh $DEVICE DirIOScheduler\`)`,
					action:"ioset scheduler",
					values:[
						`sh $DEVICE IOSchedulerList`
					],
					notify:[
						{
							on:APPLY,
							do:[ REFRESH, CANCEL ],
							to:"`sh $DEVICE DirIOSchedulerTree`"
						},
						{
							on:REFRESH,
							do:REFRESH,
							to:"`sh $DEVICE DirIOSchedulerTree`"
						}
					]
				}},
				`if [ -f "/sys/module/mmc_core/parameters/use_spi_crc" ]; then
				CRCS=\`bool /sys/module/mmc_core/parameters/use_spi_crc\`
					$BB echo '{ SPane:{
						title:{en:"Software CRC control", zh_CN:"软件CRC控制"},
					}},
						{ SCheckBox:{
							label:{en:"Software CRC control", zh_CN:"数据冗余校验控制"},
							description:{en:"Enabling software CRCs on the data blocks can be a significant (30%) performance cost. So we allow it to be disabled.", zh_CN:"开启数据冗余校验控制会占用的 30% 以上的数据读写性能消耗。关闭可以获取更好的数据读写性能，但会使数据块的安全性不稳固，假如读写过程中出现意外可能会导致数据丢失，请谨慎选择."},
							default:'$CRCS',
							action:"boolean /sys/module/mmc_core/parameters/use_spi_crc"
						}},'
				fi`
			{ SPane:{
				title:{en:"General I/O Tunables", zh_CN:"通用读写策略"},
				description:{en:"Set the internal storage general tunables", zh_CN:"设置内置储存的通用策略"},
			}},
				{ SCheckBox:{
					description:{en:"Maintain I/O statistics for this storage device. Disabling will break I/O monitoring apps.", zh_CN:"保护存储器的IO数据，禁用此选项将会导致IO监控软件故障."},
					label:"I/O Stats",
					default:`$BB cat /sys/block/mmcblk0/queue/iostats`,
					action:"ioset queue iostats"
				}},
				{ SOptionList:{
					title:{en:"No Merges", zh_CN:"队列合并"},
					description:{en:"Types of merges (prioritization) the scheduler queue for this storage device allows.", zh_CN:"在存储器允许的情况下，按照调度器队列优先次序合并数据。大部分情况可以提升随即性能，但是某些情况下需要禁用."},
					default:`$BB cat /sys/block/mmcblk0/queue/nomerges`,
					action:"ioset queue nomerges",
					values:{
						0:{en:"All", zh_CN:"全部"}, 1:{en:"Simple Only", zh_CN:"部分"}, 2:{en:"None", zh_CN:"不合并"}
					}
				}},
				{ SOptionList:{
					title:{en:"RQ Affinity", zh_CN:"队列亲和性"},
					description:{en:"Try to have scheduler requests complete on the CPU core they were made from. Higher is more aggressive. Some kernels only support 0-1.", zh_CN:"尽量让IO请求放在同一CPU上，按照常理说IO队列申请队列的CPU作为处理请求的CPU可以提升性能."},
					default:`$BB cat /sys/block/mmcblk0/queue/rq_affinity`,
					action:"ioset queue rq_affinity",
					values:{
						0:{en:"Disabled", zh_CN:"关闭"}, 1:{en:"Enabled", zh_CN:"打开"}, 2:{en:"Aggressive", zh_CN:"更多合并"}
					}
				}},
				{ SSeekBar:{
					title:{en:"NR Requests", zh_CN:"请求上限"},
					description:{en:"Maximum number of read (or write) requests that can be queued to the scheduler in the block layer.", zh_CN:"读或写入在队列中请求的最大数量."},
					step:128,
					min:128,
					max:2048,
					default:`$BB cat /sys/block/mmcblk0/queue/nr_requests`,
					action:"ioset queue nr_requests"
				}},
			{ SPane:{
				title:{en:"I/O Scheduler Tunables", zh_CN:"I/O可调参数"},
			}},
				{ STreeDescriptor:{
					path:"`sh $DEVICE DirIOSchedulerTree`",
					generic: {
						directory: {},
						element: {
							SGeneric: { title:"@BASENAME" }
						}
					},
					exclude: [ "weights", "wr_max_time" ]
				}},
		]
}
CTAG
