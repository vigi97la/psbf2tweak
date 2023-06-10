# See also ReadMe.txt.

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

#$objectsFolder="U:\Other data\Games\Battlefield 2\Personal mods\GitHub\bf2"
#$objectsFolder="C:\Users\Administrator\Downloads"
#$bUseVehiclesDB=$true
function AddVehicleSpawnPoint($objectsFolder, [bool]$bUseVehiclesDB=$true, [bool]$bIncludeStationaryWeapons=$false, [bool]$bIncludeAll=$false) {

	If ($bUseVehiclesDB) { $db=Import-Csv -Path "$scriptPath\vehicles_db.csv" -Delimiter ";" }

	Get-ChildItem "$objectsFolder\*" -R -Include "*.tweak" | ForEach-Object {
		$file=$_.FullName
		$bVehicle=[regex]::Match($file, "(.*Vehicles.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		$bStationaryWeapon=[regex]::Match($file, "(.*Weapons\\stationary.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		If (($bVehicle) -or ($bStationaryWeapon -and $bIncludeStationaryWeapons) -or ($bIncludeAll)) {
			$bDisableSpawnPoint=$false
			$regexpr="\s*ObjectTemplate.activeSafe\s+PlayerControlObject\s+(\S+)\s*\r?\n"
			$m=[regex]::Matches(([System.IO.File]::ReadAllText($file)), $regexpr)
			If ($m.Groups.Count -ne 0) {
				$vehicleName=$m.Groups[1].value
			}
			else {
				$bDisableSpawnPoint=$true
			}
			If ((-not $bDisableSpawnPoint) -and $bUseVehiclesDB) {
				$val=@($db|Where-Object {$_.vehicleName -ieq "$vehicleName"})
				if ($val.Count -ge 1) {
					$bDisableSpawnPoint=[System.Convert]::ToBoolean([int]$val[0].bDisableSpawnPoint)
					If ($bDisableSpawnPoint) {
						Write-Warning "Mobile spawpoint on vehicle $vehicleName has been explicitely disabled in vehicles_db.csv"
					}
				}
			}
			If (-not $bDisableSpawnPoint) {
				#$regexpr="\s*ObjectTemplate.aiTemplate\s+(\S+)\s*\r?\n"
				#$m=[regex]::Matches(([System.IO.File]::ReadAllText($file)), $regexpr)

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
					$m=[regex]::Matches($line, $regexpr)
					if ($m.Groups.Count -ne 2) {
						$sw.WriteLine($line)
						Continue
					}
					$bFound=$true

					$sw.WriteLine($line)
					# Skip the next line which is usually a comment...
					$line=$sr.ReadLine()
					$sw.WriteLine($line)

					$sw.WriteLine("`r`n`r`n`r`nObjectTemplate.addTemplate $vehicleName`_SpawnPoint`r`n`r`n`r`n")
				}

				$sw.WriteLine(
				"`r`n`r`nObjectTemplate.create SpawnPoint $vehicleName`_SpawnPoint`r`n"+
				"ObjectTemplate.modifiedByUser `"egg`"`r`n"+
				"ObjectTemplate.isNotSaveable 1`r`n"+
				"ObjectTemplate.createdInEditor 1`r`n"+
				"ObjectTemplate.setEnterOnSpawn 1`r`n"+
				"ObjectTemplate.setAIEnterOnSpawn 1")

				$sw.close()
				$sr.close()

				Move-Item -Path "$file.tmp" -Destination "$file" -Force

				Write-Output "$file : Mobile spawpoint added on vehicle $vehicleName"
			}
		}
	}
}

AddVehicleSpawnPoint @args
