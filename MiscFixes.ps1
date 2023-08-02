#. .\MiscFixes.ps1

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

function FixVehicleType($objectsFolder,$outputFolder=$null,[bool]$bIncludeStationaryWeapons=$false,[bool]$bIncludeAll=$false,[bool]$bResetMapIcons=$false,[bool]$bResetHUDIcons=$false,[bool]$bResetSpottedMessage=$false,[bool]$bOverwrite=$false) {

	If (($null -ne $outputFolder) -and ("" -ne $outputFolder)) {
		New-Item "$outputFolder" -ItemType directory -Force | Out-Null
	}

	Get-ChildItem "$objectsFolder" -R -Include "*.tweak" | ForEach-Object {
		$file=$_.FullName
		$bVehicle=[regex]::Match($file, "(.*Vehicles.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		$bStationaryWeapon=[regex]::Match($file, "(.*Weapons\\stationary.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		If (($bVehicle) -or ($bStationaryWeapon -and $bIncludeStationaryWeapons) -or ($bIncludeAll)) {
			$bSkip=$false
			#$regexpr="\s*ObjectTemplate.create\s+(PlayerControlObject|GenericFireArm)\s+(\S+)\s*\r?\n" # .con
			$regexpr="\s*ObjectTemplate.activeSafe\s+(PlayerControlObject|GenericFireArm)\s+(\S+)\s*\r?\n" # .tweak
			$m=[regex]::Match(([System.IO.File]::ReadAllText($file)), $regexpr)
			If ($m.Groups.Count -eq 3) {
				$vehicleName=$m.Groups[2].value
			}
			else {
				$bSkip=$true
			}

			If (-not $bSkip) {
				Write-Output "$file : $vehicleName"

				$m=[regex]::Match(([System.IO.File]::ReadAllText($file)), "\s*ObjectTemplate.vehicleHud.vehicleType\s+(\d+)\s*\r?\n")
				If ($m.Groups.Count -eq 2) {
					$vehicleType=[int]$m.Groups[1].value
				}
				# VTHeavyTank (0), VTApc (1), VCHelicopter (2), car (3), VCAir (4), VTAA (5), VCSea (6)
				$m=[regex]::Match(([System.IO.File]::ReadAllText($file)), "\s*ObjectTemplate.setVehicleType\s+(\S+)\s*\r?\n")
				If ($m.Groups.Count -eq 2) {
					$vehicleVT=$m.Groups[1].value
				}
				# VCHelicopter, VCAir, VCSea...
				$m=[regex]::Match(([System.IO.File]::ReadAllText($file)), "\s*ObjectTemplate.vehicleCategory\s+(\S+)\s*\r?\n")
				If ($m.Groups.Count -eq 2) {
					$vehicleVC=$m.Groups[1].value
				}

				$sr=[System.IO.StreamReader]$file
				$sw=[System.IO.StreamWriter]"$file.tmp"
				while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
					$line=$sr.ReadLine()					
					if ($null -eq $line) {
						break
					}

					#Write-Warning "$line"
										
					If ($bResetMapIcons) {

						# Should use vehicles_db.csv, see xpak_ailraider and others with specific icons, should not change if the file is found...

						$m=[regex]::Match($line, "^\s*ObjectTemplate.vehicleHud.typeIcon\s+(\S+)\s*")
						If ($m.Groups.Count -eq 2) {
							$vehicleTypeIcon=$m.Groups[1].value
							If (([double]$vehicleType -ge 0) -and ([double]$vehicleType -lt 1)) {
								$sw.WriteLine("ObjectTemplate.vehicleHud.typeIcon Ingame\Vehicles\Icons\Hud\MenuIcons\menuIcon_tank.tga")
							}
							elseIf (([double]$vehicleType -ge 1) -and ([double]$vehicleType -lt 2)) {
								$sw.WriteLine("ObjectTemplate.vehicleHud.typeIcon Ingame\Vehicles\Icons\Hud\MenuIcons\menuIcon_apc.tga")
							}
							elseIf (([double]$vehicleType -ge 2) -and ([double]$vehicleType -lt 3)) {
								$sw.WriteLine("ObjectTemplate.vehicleHud.typeIcon Ingame\Vehicles\Icons\Hud\MenuIcons\menuIcon_chopper.tga")
							}
							elseIf (([double]$vehicleType -ge 3) -and ([double]$vehicleType -lt 4)) {
								$sw.WriteLine("ObjectTemplate.vehicleHud.typeIcon Ingame\Vehicles\Icons\Hud\MenuIcons\menuIcon_jeep.tga")
							}
							elseIf (([double]$vehicleType -ge 4) -and ([double]$vehicleType -lt 5)) {
								$sw.WriteLine("ObjectTemplate.vehicleHud.typeIcon Ingame\Vehicles\Icons\Hud\MenuIcons\menuIcon_plane.tga")
							}
							elseIf (([double]$vehicleType -ge 5) -and ([double]$vehicleType -lt 6)) {
								$sw.WriteLine("ObjectTemplate.vehicleHud.typeIcon Ingame\Vehicles\Icons\Hud\MenuIcons\menuIcon_antiair.tga")
							}
							elseIf (([double]$vehicleType -ge 6) -and ([double]$vehicleType -lt 7)) {
								$sw.WriteLine("ObjectTemplate.vehicleHud.typeIcon Ingame\Vehicles\Icons\Hud\MenuIcons\menuIcon_boat.tga")
							}
							else {
								$sw.WriteLine($line)
							}
							Continue
						}
						$m=[regex]::Match($line, "^\s*ObjectTemplate.vehicleHud.miniMapIcon\s+(\S+)\s*")
						If ($m.Groups.Count -eq 2) {
							$vehicleMiniMapIcon=$m.Groups[1].value
							If (([double]$vehicleType -ge 0) -and ([double]$vehicleType -lt 1)) {
								$sw.WriteLine("ObjectTemplate.vehicleHud.miniMapIcon Ingame\Vehicles\Icons\Minimap\mini_Tank.tga")
							}
							elseIf (([double]$vehicleType -ge 1) -and ([double]$vehicleType -lt 2)) {
								$sw.WriteLine("ObjectTemplate.vehicleHud.miniMapIcon Ingame\Vehicles\Icons\Minimap\mini_APC.tga")
							}
							elseIf (([double]$vehicleType -ge 2) -and ([double]$vehicleType -lt 3)) {
								$sw.WriteLine("ObjectTemplate.vehicleHud.miniMapIcon Ingame\Vehicles\Icons\Minimap\mini_Attack_Heli.tga")
							}
							elseIf (([double]$vehicleType -ge 3) -and ([double]$vehicleType -lt 4)) {
								$sw.WriteLine("ObjectTemplate.vehicleHud.miniMapIcon Ingame\Vehicles\Icons\Minimap\mini_Jeep.tga")
							}
							elseIf (([double]$vehicleType -ge 4) -and ([double]$vehicleType -lt 5)) {
								$sw.WriteLine("ObjectTemplate.vehicleHud.miniMapIcon Ingame\Vehicles\Icons\Minimap\mini_Jet.tga")
							}
							elseIf (([double]$vehicleType -ge 5) -and ([double]$vehicleType -lt 6)) {
								$sw.WriteLine("ObjectTemplate.vehicleHud.miniMapIcon Ingame\Vehicles\Icons\Minimap\mini_AAVehicle.tga")
							}
							elseIf (([double]$vehicleType -ge 6) -and ([double]$vehicleType -lt 7)) {
								$sw.WriteLine("ObjectTemplate.vehicleHud.miniMapIcon Ingame\Vehicles\Icons\Minimap\mini_rib.tga")
							}
							else {
								$sw.WriteLine($line)
							}
							#Ingame\Vehicles\Icons\HUD\Minimap\MM_xpak_civcar.dds
							Continue
						}
					}
					If ($bResetHUDIcons) {
						$m=[regex]::Match($line, "^\s*ObjectTemplate.vehicleHud.vehicleIcon\s+(\S+)\s*")
						If ($m.Groups.Count -eq 2) {
							$vehicleIcon=$m.Groups[1].value
							$sw.WriteLine("rem $line")
							Continue
						}
					}
					If ($bResetSpottedMessage) {
						$m=[regex]::Match($line, "^\s*ObjectTemplate.Radio.spottedMessage\s+(\S+)\s*")
						If ($m.Groups.Count -eq 2) {
							$vehicleSpottedMessage=$m.Groups[1].value
							If (([double]$vehicleType -ge 0) -and ([double]$vehicleType -lt 1)) {
								$sw.WriteLine("ObjectTemplate.Radio.spottedMessage tank_spotted")
							}
							elseIf (([double]$vehicleType -ge 1) -and ([double]$vehicleType -lt 2)) {
								$sw.WriteLine("ObjectTemplate.Radio.spottedMessage apc_spotted")
							}
							elseIf (([double]$vehicleType -ge 2) -and ([double]$vehicleType -lt 3)) {
								$sw.WriteLine("ObjectTemplate.Radio.spottedMessage heli_spotted")
							}
							elseIf (([double]$vehicleType -ge 3) -and ([double]$vehicleType -lt 4)) {
								$sw.WriteLine("ObjectTemplate.Radio.spottedMessage vehicle_spotted")
							}
							elseIf (([double]$vehicleType -ge 4) -and ([double]$vehicleType -lt 5)) {
								$sw.WriteLine("ObjectTemplate.Radio.spottedMessage air_spotted")
							}
							elseIf (([double]$vehicleType -ge 5) -and ([double]$vehicleType -lt 6)) {
								$sw.WriteLine("ObjectTemplate.Radio.spottedMessage aa_spotted")
							}
							elseIf (([double]$vehicleType -ge 6) -and ([double]$vehicleType -lt 7)) {
								$sw.WriteLine("ObjectTemplate.Radio.spottedMessage boat_spotted")
							}
							else {
								$sw.WriteLine($line)
							}
							Continue
						}
					}

					$sw.WriteLine($line)
				}
				$sw.close()
				$sr.close()
				If (($null -ne $outputFolder) -and ("" -ne $outputFolder)) {
					# Should remove $objectsFolder from the path in $file and add the rest at the end of the desired folder...
					$regesc=[regex]::Escape($objectsFolder)
					$m=[regex]::Match($file, "$regesc\\(.+)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					$restOfPath=$m.Groups[1].value
					#"$restOfPath"
					$outputFile=[System.IO.Path]::Combine($outputFolder,$restOfPath)
					#"$outputFile"
					New-Item ([System.IO.FileInfo]$outputFile).DirectoryName -ItemType directory -Force | Out-Null
					Move-Item -Path "$file.tmp" -Destination $outputFile -Force
				}
				If ($bOverwrite) { 
					If (-not (Test-Path -Path "$file.bak")) { 
						Move-Item -Path $file -Destination "$file.bak" -Force
					}
					Move-Item -Path "$file.tmp" -Destination $file -Force
				}
			}
		}
	}
}
