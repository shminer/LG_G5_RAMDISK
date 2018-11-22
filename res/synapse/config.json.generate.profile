cat << CTAG
{
    name:{en:"PROFILE", zh_CN:"配置管理"},
    elements:[
		{ STitleBar:{
			title:{en:"Profiles", zh_CN:"导入配置"},
		}},
			{ SOptionList:{
				title:{en:"Selected Profile", zh_CN:"导入完整配置文件"},
				description:{en:"Choose the settings you want and apply your choice in Synapse before using the action buttons below.", zh_CN:"选择配置文件，然后点击屏幕上方的 √ 键，再按下列按钮完成导入或删除配置的操作."},
				action:"restorebackup pickprofile",
				default:"None",
				values:[ "None",
					`for BAK in \`/res/synapse/actions/restorebackup listprofile\`; do
						echo "\"$BAK\","
					done`
				],
				notify:[
					{
						on:APPLY,
						do:[ REFRESH, APPLY ],
						to:"generic /res/synapse/files/bck_prof"
					}
				]
			}},
			{ SDescription:{
				description:{en:"NOTE: After you restore a profile, you have to press the X button on top to load the settings.", zh_CN:"注意：在你恢复一个配置文件后，Synapse 会自动退出重新启动，你必须点击屏幕上方的 X 键后，才能完成导入配置."},
			}},
			{ SButton:{
				label:{en:"Restore Selected Profile", zh_CN:"选择一个用来恢复的配置文件"},
				action:"restorebackup applyprofile",
				notify:[
					{
						on:APPLY,
						do:[ REFRESH, APPLY ],
						to:"restorebackup pickprofile"
					}
				]
			}},
			{ SButton:{
				label:{en:"Delete Selected Profile", zh_CN:"删除一个配置文件"},
				action:"restorebackup delprofile",
				notify:[
					{
						on:APPLY,
						do:[ REFRESH, APPLY ],
						to:"restorebackup pickprofile"
					}
				]
			}},
		{ SPane:{
			title:"Configs"
		}},
			{ SOptionList:{
				title:{en:"Selected Config", zh_CN:"导入普通设置文本"},
				description:{en:"Choose the settings you want and apply your choice in Synapse before using the action buttons below.", zh_CN:"选择普通设置文本（不含电压数据等高级操作），然后点击屏幕上方的 √ 键，再按下列按钮完成导入或删除的操作."},
				action:"restorebackup pickconfig",
				default:"None",
				values:[ "None",
					`for BAK in \`/res/synapse/actions/restorebackup listconfig\`; do
						echo "\"$BAK\","
					done`
				],
				notify:[
					{
						on:APPLY,
						do:[ REFRESH, APPLY ],
						to:"generic /res/synapse/files/bck_prof"
					}
				]
			}},
			{ SDescription:{
				description:{en:"NOTE: After you restore a config, you have to press the X button on top to load the settings.", zh_CN:"注意：在你恢复一个配置文本后，Synapse 会自动退出重新启动，你必须点击屏幕上方的 X 键后，才能完成导入配置."},
			}},
			{ SButton:{
				label:{en:"Import Selected Config", zh_CN:"导入设置文本"},
				action:"sqlite ImportConfigSynapse",
				notify:[
					{
						on:APPLY,
						do:[ REFRESH, APPLY ],
						to:"restorebackup pickconfig"
					}
				]
			}},
			{ SButton:{
				label:{en:"Delete Selected Config", zh_CN:"删除设置文本"},
				action:"restorebackup delconfig",
				notify:[
					{
						on:APPLY,
						do:[ REFRESH, APPLY ],
						to:"restorebackup pickconfig"
					}
				]
			}},
		{ SPane:{
			title:{en:"Backup Actions", zh_CN:"备份配置"},
		}},
			{ SGeneric:{
				title:{en:"Profile/Config Name", zh_CN:"请输入备份文件名"},
				default:"None",
				action:"generic /res/synapse/files/bck_prof",
			}},
			{ SDescription:{
				description:{en:"First set a name above and apply. After this you can press the Backup Current Profile or Export Current Config button below.", zh_CN:"输入文件名后请输入 回车键 确认，然后点击屏幕上方的 √ 键，再按备份按钮完成备份操作."},
			}},
			{ SButton:{
				label:{en:"Backup Current Profile", zh_CN:"备份完整设置文件"},
				action:"restorebackup keepprofile",
				notify:[
					{
						on:APPLY,
						do:[ REFRESH, APPLY ],
						to:"generic /res/synapse/files/bck_prof"
					}
				]
			}},
			{ SButton:{
				label:{en:"Export Current Config", zh_CN:"备份普通设置文本"},
				action:"sqlite ExportConfigSynapse",
				notify:[
					{
						on:APPLY,
						do:[ REFRESH, APPLY ],
						to:"generic /res/synapse/files/bck_prof"
					}
				]
			}},
		{ SPane:{
			title:{en:"General Actions", zh_CN:"其他操作"},
			description:{en:"To update/refresh lists, select Restart Synapse below.", zh_CN:"如需更新文件列表，请安下列按钮重启动 Synapse。"},
		}},
			{ SButton:{
				label:{en:"Restart Synapse", zh_CN:"重启 Synapse"},
				action:"restorebackup restart"
			}},
    ]
}
CTAG
