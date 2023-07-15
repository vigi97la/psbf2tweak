# See also ReadMe.txt.

function AddArmorEffect($objectsFolder, [bool]$bIncludeStationaryWeapons=$false, [bool]$bIncludeAll=$false) {

	Get-ChildItem "$objectsFolder\*" -R -Include "*.tweak" | ForEach-Object {
		$file=$_.FullName
		$bVehicle=[regex]::Match($file, "(.*Vehicles.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		$bStationaryWeapon=[regex]::Match($file, "(.*Weapons\\stationary.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		If (($bVehicle) -or ($bStationaryWeapon -and $bIncludeStationaryWeapons) -or ($bIncludeAll)) {
			$bDisableArmorEffect=$false
			$regexpr="\s*ObjectTemplate.activeSafe\s+PlayerControlObject\s+(\S+)\s*\r?\n"
			$m=[regex]::Match(([System.IO.File]::ReadAllText($file)), $regexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			If ($m.Groups.Count -eq 2) {
				$vehicleName=$m.Groups[1].value
			}
			else {
				$bDisableArmorEffect=$true
			}
			If (-not $bDisableArmorEffect) {
				$regexpr="^\s*ObjectTemplate.armor.addArmorEffect\s+(-?\d+)\s+(\S+)"
				$sr=[System.IO.StreamReader]$file
				$sw=[System.IO.StreamWriter]"$file.tmp"
				$bFound=$false
				while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
					$line=$sr.ReadLine()
					If ($bFound) {
						$sw.WriteLine($line)
						Continue
					}
					$m=[regex]::Match($line, $regexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					if (($m.Groups.Count -ne 3) -or ([int]$m.Groups[1].Value -gt 10)) {
						$sw.WriteLine($line)
						Continue
					}
					$bFound=$true

					$sw.WriteLine($line)

					$sw.WriteLine(
					"`r`n`r`nObjectTemplate.armor.addArmorEffect 9 e_dstate_land_fire 0/0.373439/-2.05691 0/0/0`r`n"+
					"ObjectTemplate.armor.addArmorEffect 2 e_dstate_static_fire 0.401428/0.444168/-1.41347 0/0/0`r`n"+
					"ObjectTemplate.armor.addArmorEffect 2 e_sAmb_wreckfire -0.390331/0.429387/1.24622 0/0/0`r`n"+
					"ObjectTemplate.armor.addArmorEffect 0 e_sAmb_wreckfire 0.44/0.148/-1.645 0/0/0`r`n"+
					"ObjectTemplate.armor.addArmorEffect 0 e_sAmb_wreckfire -0.257/0.663/-1.721 0/0/0`r`n"+
					"ObjectTemplate.armor.addArmorEffect 0 e_dstate_static_fire 0/0.5/1.748 0/0/0`r`n"+
					"ObjectTemplate.armor.addArmorEffect 0 e_dstate_static_fire 0.324/0.618/-0.968 0/0/0`r`n"+
					"ObjectTemplate.armor.addArmorEffect -1 e_dstate_static_fire 0.401428/0.444168/-1.41347 0/0/0`r`n"+
					"ObjectTemplate.armor.addArmorEffect -1 e_sAmb_wreckfire -0.390331/0.429387/1.24622 0/0/0`r`n`r`n")
				}
				$sw.close()
				$sr.close()

				Move-Item -Path "$file.tmp" -Destination "$file" -Force

				Write-Output "$file : Armor effect added on vehicle $vehicleName"
			}
		}
	}
}

AddArmorEffect @args
