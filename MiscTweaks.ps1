
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

#. .\MiscTweaks.ps1
#$exportFolder="U:\Progs\EA Games\Battlefield 2 AIX2 Reality\mods\aix2_reality\export\Objects\Vehicles\Land\fr_tnk_amx10rc_bf2"
#DontClearTeamOnExitUpdate $exportFolder 0 $true $true
function DontClearTeamOnExitUpdate($objectsFolder, [int]$value=0, [bool]$bIncludeStationaryWeapons=$false, [bool]$bIncludeAll=$false) {
	Get-ChildItem "$objectsFolder\*" -R -Include "*.tweak" | ForEach-Object {
		$bVehicle=[regex]::Match($_.FullName, "(.*Vehicles.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		$bStationaryWeapon=[regex]::Match($_.FullName, "(.*Weapons\\stationary.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		If (($bVehicle) -or ($bStationaryWeapon -and $bIncludeStationaryWeapons) -or ($bIncludeAll)) {
			$regexpr="(?<=ObjectTemplate.dontClearTeamOnExit)(\s+)(-?\d+)"
			$m=[regex]::Match((Get-Content $_.FullName), $regexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			If ($m.Success) {
				$val=[int]($m.Groups[2].value)
				If ($val -ne $value) {
					"$_ : updating ObjectTemplate.dontClearTeamOnExit from $val to $value"
					(Get-Content $_.FullName) -replace $regexpr," $value" | Set-Content $_.FullName
				}
			}
		}
	}
}

function DelayToUseUpdate($objectsFolder, [int]$value=0, [bool]$bIncludeStationaryWeapons=$false, [bool]$bIncludeAll=$false) {
	Get-ChildItem "$objectsFolder\*" -R -Include "*.tweak" | ForEach-Object {
		$bVehicle=[regex]::Match($_.FullName, "(.*Vehicles.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		$bStationaryWeapon=[regex]::Match($_.FullName, "(.*Weapons\\stationary.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		If (($bVehicle) -or ($bStationaryWeapon -and $bIncludeStationaryWeapons) -or ($bIncludeAll)) {
			$regexpr="(?<=ObjectTemplate.delayToUse)(\s+)(-?\d+)"
			$m=[regex]::Match((Get-Content $_.FullName), $regexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			If ($m.Success) {
				$val=[int]($m.Groups[2].value)
				If ($val -ne $value) {
					"$_ : updating ObjectTemplate.delayToUse from $val to $value"
					(Get-Content $_.FullName) -replace $regexpr," $value" | Set-Content $_.FullName
				}
			}
		}
	}
}
