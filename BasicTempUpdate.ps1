
function BasicTempUpdate($objectsFolder, [double]$tempMultiplier=10, [bool]$bIncludeStationaryWeapons=$false, [bool]$bIncludeAll=$false) {
	Get-ChildItem "$objectsFolder\*" -R -Include "Objects.ai" | ForEach-Object {
		$bVehicle=[regex]::Match($_.FullName, "(.*Vehicles)").Success
		$bStationaryWeapon=[regex]::Match($_.FullName, "(.*Weapons\\stationary)").Success
		If (($bVehicle) -or ($bStationaryWeapon -and $bIncludeStationaryWeapons) -or ($bIncludeAll)) {
			$regexpr="(?<=aiTemplate.basicTemp)(\s+)(-?\d+)"
			$m=[regex]::Matches((Get-Content $_.FullName), $regexpr)
			ForEach ($mi in $m) {
				$val=[int]($mi.Groups[2].value)
				$temp=[int]($tempMultiplier*$val)
				"$_ : updating aiTemplate.basicTemp from $val to $temp"
				(Get-Content $_.FullName) -replace $regexpr," $temp" | Set-Content $_.FullName
			}
		}
	}
}

BasicTempUpdate @args
