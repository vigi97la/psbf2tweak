
function SetBots($modFolder, [int]$nbBots=47, [int]$maxBotsIncludeHumans=0, [double]$botSkill=1.0) {
	$regexpr="(?<=aiSettings.overrideMenuSettings)(\s+)(\d+)"
	(Get-Content $modFolder\AI\AIDefault.ai) -replace $regexpr," 1" | Set-Content $modFolder\AI\AIDefault.ai
	$regexpr="(?<=aiSettings.setMaxNBots)(\s+)(\d+)"
	(Get-Content $modFolder\AI\AIDefault.ai) -replace $regexpr," $nbBots" | Set-Content $modFolder\AI\AIDefault.ai
	$regexpr="(?<=aiSettings.maxBotsIncludeHumans)(\s+)(\d+)"
	(Get-Content $modFolder\AI\AIDefault.ai) -replace $regexpr," $maxBotsIncludeHumans" | Set-Content $modFolder\AI\AIDefault.ai
	$regexpr="(?<=aiSettings.setBotSkill)(\s+)([+-]?([0-9]*\.)?[0-9]+)"
	(Get-Content $modFolder\AI\AIDefault.ai) -replace $regexpr," $botSkill" | Set-Content $modFolder\AI\AIDefault.ai

	(Get-Content $modFolder\AI\AIDefault.ai) -replace "rem aiSettings","aiSettings" | Set-Content $modFolder\AI\AIDefault.ai
}

SetBots $args
