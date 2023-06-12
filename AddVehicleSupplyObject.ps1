# See also ReadMe.txt.

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

function AddVehicleSupplyObject($objectsFolder, [bool]$bUseVehiclesDB=$true, [bool]$bIncludeStationaryWeapons=$false, [bool]$bIncludeAll=$false) {

	If ($bUseVehiclesDB) { $db=Import-Csv -Path "$scriptPath\vehicles_db.csv" -Delimiter ";" }

	Get-ChildItem "$objectsFolder\*" -R -Include "*.tweak" | ForEach-Object {
		$file=$_.FullName
		$bVehicle=[regex]::Match($file, "(.*Vehicles.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		$bStationaryWeapon=[regex]::Match($file, "(.*Weapons\\stationary.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		If (($bVehicle) -or ($bStationaryWeapon -and $bIncludeStationaryWeapons) -or ($bIncludeAll)) {
			$bHasSupplies=$false
			$regexpr="\s*ObjectTemplate.activeSafe\s+PlayerControlObject\s+(\S+)\s*\r?\n"
			$m=[regex]::Match(([System.IO.File]::ReadAllText($file)), $regexpr)
			If ($m.Groups.Count -eq 2) {
				$vehicleName=$m.Groups[1].value
				If ($bUseVehiclesDB) {
					$val=@($db|Where-Object {$_.vehicleName -ieq "$vehicleName"})
					if ($val.Count -ge 1) {
						$bHasSupplies=[System.Convert]::ToBoolean([int]$val[0].bHasSupplies)
					}
				}
				Else {
					$bHasSupplies=$true
				}
			}
			If ($bHasSupplies) {
				$regexpr="^\s*ObjectTemplate.aiTemplate\s+(\S+)\s*"
				$sr=[System.IO.StreamReader]$file
				$sw=[System.IO.StreamWriter]"$file.tmp"
				$bFound=$false
				while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
					$line=$sr.ReadLine()
					If ($bFound) {
						$sw.WriteLine($line)
						Continue
					}
					$m=[regex]::Match($line, $regexpr)
					if ($m.Groups.Count -ne 2) {
						$sw.WriteLine($line)
						Continue
					}
					$bFound=$true

					$sw.WriteLine($line)
					# Skip the next line which is usually a comment...
					$line=$sr.ReadLine()
					$sw.WriteLine($line)

					$sw.WriteLine("`r`n`r`n`r`nObjectTemplate.addTemplate $vehicleName`_SupplyObject`r`nObjectTemplate.setPosition 0/0/-1`r`n`r`n`r`n")
				}

				$sw.WriteLine(
				"`r`n`r`n`r`nObjectTemplate.create SupplyObject $vehicleName`_SupplyObject`r`n"+
				"ObjectTemplate.modifiedByUser `"sofad`"`r`n"+
				"ObjectTemplate.createdInEditor 1`r`n"+
				"ObjectTemplate.floaterMod 0`r`n"+
				"ObjectTemplate.hasMobilePhysics 0`r`n"+
				"ObjectTemplate.teamOnVehicle 1`r`n"+
				"ObjectTemplate.radius 4`r`n"+
				"ObjectTemplate.workOnSoldiers 1`r`n"+
				"ObjectTemplate.workOnVehicles 1`r`n"+
				"ObjectTemplate.healSpeed 1`r`n"+
				"ObjectTemplate.refillAmmoSpeed 3.5`r`n"+
				"ObjectTemplate.sharedStorageSize 10000")

				$sw.close()
				$sr.close()

				Move-Item -Path "$file.tmp" -Destination "$file" -Force

				Write-Output "$file : Mobile supply object added on vehicle $vehicleName"
			}
		}
	}
}

AddVehicleSupplyObject @args
