# See also ReadMe.txt.

function ListVehicles($objectsFolder, [bool]$bIncludeStationaryWeapons=$false, [bool]$bIncludeAll=$false) {

	Write-Output "$objectsFolder : The following lines can be added to vehicles_db.csv as a template to be modified manually:"

	Get-ChildItem "$objectsFolder\*" -R -Include "*.tweak" | ForEach-Object {
		$file=$_.FullName
		$bVehicle=[regex]::Match($file, "(.*Vehicles.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		$bStationaryWeapon=[regex]::Match($file, "(.*Weapons\\stationary.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		If (($bVehicle) -or ($bStationaryWeapon -and $bIncludeStationaryWeapons) -or ($bIncludeAll)) {
			$bSkip=$false
			$regexpr="\s*ObjectTemplate.activeSafe\s+PlayerControlObject\s+(\S+)\s*\r?\n"
			$m=[regex]::Match(([System.IO.File]::ReadAllText($file)), $regexpr)
			If ($m.Groups.Count -eq 2) {
				$vehicleName=$m.Groups[1].value
			}
			else {
				$bSkip=$true
			}
			$regexpr="\s*ObjectTemplate.vehicleHud.vehicleType\s+(\d+)\s*\r?\n"
			$m=[regex]::Match(([System.IO.File]::ReadAllText($file)), $regexpr)
			If ($m.Groups.Count -eq 2) {
				$vehicleType=[int]$m.Groups[1].value
			}
			else {
				$bSkip=$true
			}
			$regexpr="\s*ObjectTemplate.vehicleHud.hudName\s+(\S+)\s*\r?\n"
			$m=[regex]::Match(([System.IO.File]::ReadAllText($file)), $regexpr)
			If ($m.Groups.Count -eq 2) {
				$vehicleHudName=$m.Groups[1].value
			}
			else {
				$bSkip=$true
			}
			if (-not $bSkip) {
				$bFloating=0
				$bFlying=0
				$bVTOL=0
				$bNeedWater=0
				$bNeedAirfield=0
				$bHeavilyArmored=0
				$bHeavilyArmed=0
				$bHasManyPassengers=0
				$bHasSupplies=0
				If ($vehicleType -eq 0) {
					$bHeavilyArmored=1
					$bHeavilyArmed=1
				}
				elseif ($vehicleType -eq 1) {
					$bHeavilyArmored=1
					$bHeavilyArmed=1
				}
				elseif ($vehicleType -eq 2) {
					$bFlying=1
					$bVTOL=1
				}
				elseif ($vehicleType -eq 3) {
					$bHasSupplies=1
				}
				elseif ($vehicleType -eq 4) {
					$bFlying=1
					$bNeedAirfield=1
				}
				elseif ($vehicleType -eq 5) {
					$bHeavilyArmored=1
				}
				elseif ($vehicleType -eq 6) {
					$bNeedWater=1
				}

				# Should also try to detect the number of passengers, bFloating, bAmphibious...
				# Team, bCivilian sometimes could be deduced from vehicleName...?

				Write-Output "$vehicleName;$vehicleType;ALL;ALL;0;;0;$bFloating;$bFlying;$bVTOL;$bNeedWater;$bNeedAirfield;0;$bHeavilyArmored;$bHeavilyArmed;$bHasManyPassengers;0;0;0;$bHasSupplies;$vehicleHudName;;;"
			}
		}
	}
}

ListVehicles @args
