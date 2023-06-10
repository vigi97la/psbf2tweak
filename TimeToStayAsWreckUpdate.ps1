
function TimeToStayAsWreckUpdate($objectsFolder, [int]$time=10, [bool]$bIncludeStationaryWeapons=$false, [bool]$bIncludeAll=$false) {
	Get-ChildItem "$objectsFolder\*" -R -Include "*.tweak" | ForEach-Object {
		$bVehicle=[regex]::Match($_.FullName, "(.*Vehicles.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		$bStationaryWeapon=[regex]::Match($_.FullName, "(.*Weapons\\stationary.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		If (($bVehicle) -or ($bStationaryWeapon -and $bIncludeStationaryWeapons) -or ($bIncludeAll)) {
			$regexpr="(?<=ObjectTemplate.armor.timeToStayAsWreck)(\s+)(-?\d+)"
			$m=[regex]::Match((Get-Content $_.FullName), $regexpr)
			If ($m.Success) {
				$val=[int]($m.Groups[2].value)
				If ($val -ne $time) {
					"$_ : updating ObjectTemplate.armor.timeToStayAsWreck from $val to $time"
					(Get-Content $_.FullName) -replace $regexpr," $time" | Set-Content $_.FullName
				}
			}
		}
	}
}

TimeToStayAsWreckUpdate @args
