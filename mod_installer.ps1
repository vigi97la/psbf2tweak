# DO NOT USE, TEMPORARY

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

function ReadConFile($file) {
	$content=""
	$sr=[System.IO.StreamReader]$file
	while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
		$line=$sr.ReadLine()
		$content+=$line+"`r`n"
	}
	$sr.close()
	return $content
}

function cbInsideCommentLine($concontent, $i, $line, $params) {
	#Write-Output "Comment     : $line" # Write-Output causes problems?
	$content=$params
	return $content
}

function cbOutsideCommentLine($concontent, $i, $line, $params) {
	#Write-Output "Not comment : $line" # Write-Output causes problems?
	$content=$params
	$content+=$line+"`r`n"
	return $content
}

#. .\mod_installer.ps1
#(PreProcessCommentsConContent (ReadConFile "U:\Other data\Games\Battlefield 2\Personal mods\Mod DB\originals\aix2real\simpleparams.con") "cbInsideCommentLine" "cbOutsideCommentLine") -replace "\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n\s*\r?\n","`r`n"
function PreProcessCommentsConContent($concontent, $cbInsideCommentLine, $cbOutsideCommentLine) {
	$content=""
	$remregexpr="^\s*rem\s+(.*)\s*" # To skip lines beginning with a comment.
	$beginremregexpr="^\s*beginrem\s*" # To skip block comments.
	$endremregexpr="^\s*endrem\s*" # To skip block comments.
	$bInsideBlockComment=$false
	$lines=$($concontent -split "\r?\n")
	for ($i=0; $i -lt $lines.Count; $i++) {
		$line=$lines[$i]
		if ($bInsideBlockComment) {
			$m=[regex]::Match($line, $endremregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			if ($m.Success) {
				$bInsideBlockComment=$false

				$params=$content
				$content=& $cbInsideCommentLine $concontent $i $line $params

				Continue
			}

			$params=$content
			$content=& $cbInsideCommentLine $concontent $i $line $params

			Continue
		}
		$m=[regex]::Match($line, $remregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		if ($m.Success) {

			$params=$content
			$content=& $cbInsideCommentLine $concontent $i $line $params

			Continue
		}
		$m=[regex]::Match($line, $beginremregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		if ($m.Success) {
			$bInsideBlockComment=$true

			$params=$content
			$content=& $cbInsideCommentLine $concontent $i $line $params

			Continue
		}

		$params=$content
		$content=& $cbOutsideCommentLine $concontent $i $line $params

	}
	return $content
}

function cbConditionCode($concontent, $i, $line, $params) {
	$content=$params
	return $content
}

function cbOtherCode($concontent, $i, $line, $params) {
	$content=$params
	$content+=$line+"`r`n"
	return $content
}

function cbInsideTrueCondition($concontent, $i, $line, $params) {
	$content=$params
	$content+=$line+"`r`n"
	return $content
}

function cbInsideFalseCondition($concontent, $i, $line, $params) {
	$content=$params
	return $content
}

#. .\mod_installer.ps1
#$i=0
#PreProcessIfConContent (ReadConFile "U:\Other data\Games\Battlefield 2\Personal mods\Mod DB\originals\aix2real\simpleapc.tweak") ([ref]$i) "cbConditionCode" "cbOtherCode" "cbInsideTrueCondition" "cbInsideFalseCondition"
function PreProcessIfConContent($concontent, [ref]$i, $cbConditionCode, $cbOtherCode, $cbInsideTrueCondition, $cbInsideFalseCondition) {
	$content=""
	$ifregexpr="^\s*if\s*"
	$ifcondregexpr="^\s*if\s+(\S*)\s*==\s*(\S*)\s*"
	$elseIfregexpr="^\s*elseIf\s*"
	$elseIfcondregexpr="^\s*elseIf\s+(\S*)\s*==\s*(\S*)\s*"
	$elseregexpr="^\s*else\s*"
	$endifregexpr="^\s*endIf\s*"
	$bInsideCondition=$false
	$bInsideTrueCondition=$false
	$bFoundTrueCondition=$false
	$lines=$($concontent -split "\r?\n")
	for ($i.value=0; $i.value -lt $lines.Count; $i.value++) {
		$line=$lines[$i.value]

		if ($bInsideCondition) {
			$m=[regex]::Match($line, $elseIfcondregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			if (($m.Groups.Count -eq 3)) {

				$params=$content
				$content=& $cbConditionCode $concontent $i.value $line $params

				if ($bInsideTrueCondition) {
					$bInsideTrueCondition=$false
					Continue
				}				
				if ((-not $bFoundTrueCondition) -and ($m.Groups[1].value -eq $m.Groups[2].value)) {
					$bInsideTrueCondition=$true
					$bFoundTrueCondition=$true
				}
				Continue
			}
			$m=[regex]::Match($line, $elseregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			if ($m.Success) {

				$params=$content
				$content=& $cbConditionCode $concontent $i.value $line $params

				if ($bInsideTrueCondition) {
					$bInsideTrueCondition=$false
					Continue
				}				
				if (-not $bFoundTrueCondition) {
					$bInsideTrueCondition=$true
					$bFoundTrueCondition=$true
				}
				Continue
			}
			$m=[regex]::Match($line, $endifregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			if ($m.Success) {

				$params=$content
				$content=& $cbConditionCode $concontent $i.value $line $params

				$bInsideCondition=$false
				$bInsideTrueCondition=$false
				$bFoundTrueCondition=$false
				Continue
			}
			if ($bInsideTrueCondition) {
					
				# If multiple conditions inside...
				$m=[regex]::Match($line, $ifcondregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
				if (($m.Groups.Count -eq 3)) {
					$contentblock=$lines | Select-Object -Index ($i.value..($lines.Count-1)) # $concontent starting at $i.value line (so it includes the if)
					$iblock=0
					$content+=PreProcessIfConContent $contentblock ([ref]$iblock) $cbConditionCode $cbOtherCode $cbInsideTrueCondition $cbInsideFalseCondition
					$i.value+=($iblock-1) # Does not include the endIf that made PreProcessIfConContent return
				}
				else {
					$params=$content
					$content=& $cbInsideTrueCondition $concontent $i.value $line $params
				}
			}
			else {

				# If multiple conditions inside...
				$m=[regex]::Match($line, $ifcondregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
				if (($m.Groups.Count -eq 3)) {
					$contentblock=$lines | Select-Object -Index ($i.value..($lines.Count-1)) # $concontent starting at $i.value line (so it includes the if)
					$iblock=0
					$content+=PreProcessIfConContent $contentblock ([ref]$iblock) $cbInsideFalseCondition $cbInsideFalseCondition $cbInsideFalseCondition $cbInsideFalseCondition
					$i.value+=($iblock-1) # Does not include the endIf that made PreProcessIfConContent return
				}
				else {
					$params=$content
					$content=& $cbInsideFalseCondition $concontent $i.value $line $params
				}

			}
			Continue
		}
		$m=[regex]::Match($line, $ifcondregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		if (($m.Groups.Count -eq 3)) {

			$params=$content
			$content=& $cbConditionCode $concontent $i.value $line $params

			$bInsideCondition=$true
			$bInsideTrueCondition=$false
			$bFoundTrueCondition=$false
			if ($m.Groups[1].value -eq $m.Groups[2].value) {
				$bInsideTrueCondition=$true
				$bFoundTrueCondition=$true
			}
			Continue
		}	
		
		# If multiple conditions inside...
		If ([regex]::Match($line, $elseIfregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Groups.Count -eq 3) {
			break
		}
		elseIf ([regex]::Match($line, $elseregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success) {
			break
		}
		elseIf ([regex]::Match($line, $endifregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success) {
			break
		}
		else {
			$params=$content
			$content=& $cbOtherCode $concontent $i.value $line $params
		}

	}
	return $content
}

function PreProcessArgsConContent($concontent, $v_arg1, $v_arg2, $v_arg3, $v_arg4, $v_arg5, $v_arg6, $v_arg7, $v_arg8, $v_arg9) {
	$content=""
	ForEach ($line in $($concontent -split "\r?\n")) {

		# null...?

		if (($null -ne $v_arg1) -and ("" -ne $v_arg1)) { $line=$line -replace "v_arg1","$v_arg1" } else { $line=$line -replace "v_arg1","`"null`"" }
		if (($null -ne $v_arg2) -and ("" -ne $v_arg2)) { $line=$line -replace "v_arg2","$v_arg2" } else { $line=$line -replace "v_arg2","`"null`"" }
		if (($null -ne $v_arg3) -and ("" -ne $v_arg3)) { $line=$line -replace "v_arg3","$v_arg3" } else { $line=$line -replace "v_arg3","`"null`"" }
		if (($null -ne $v_arg4) -and ("" -ne $v_arg4)) { $line=$line -replace "v_arg4","$v_arg4" } else { $line=$line -replace "v_arg4","`"null`"" }
		if (($null -ne $v_arg5) -and ("" -ne $v_arg5)) { $line=$line -replace "v_arg5","$v_arg5" } else { $line=$line -replace "v_arg5","`"null`"" }
		if (($null -ne $v_arg6) -and ("" -ne $v_arg6)) { $line=$line -replace "v_arg6","$v_arg6" } else { $line=$line -replace "v_arg6","`"null`"" }
		if (($null -ne $v_arg7) -and ("" -ne $v_arg7)) { $line=$line -replace "v_arg7","$v_arg7" } else { $line=$line -replace "v_arg7","`"null`"" }
		if (($null -ne $v_arg8) -and ("" -ne $v_arg8)) { $line=$line -replace "v_arg8","$v_arg8" } else { $line=$line -replace "v_arg8","`"null`"" }
		if (($null -ne $v_arg9) -and ("" -ne $v_arg9)) { $line=$line -replace "v_arg9","$v_arg9" } else { $line=$line -replace "v_arg9","`"null`"" }

		$content+=$line+"`r`n"
	}
	return $content
}

function PreProcessIncludesConLine($line, $file) {
	$m=[regex]::Match($line, "^\s*include\s+(\S+)(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
	if ($m.Groups.Count -ge 2) {
		$includedfile=Join-Path (Get-item $file).DirectoryName $m.Groups[1].value
		$v_arg1=$m.Groups[3].value
		$v_arg2=$m.Groups[5].value
		$v_arg3=$m.Groups[7].value
		$v_arg4=$m.Groups[9].value
		$v_arg5=$m.Groups[11].value
		$v_arg6=$m.Groups[13].value
		$v_arg7=$m.Groups[15].value
		$v_arg8=$m.Groups[17].value
		$v_arg9=$m.Groups[19].value
		$i=0
		$includedfilecontent=(PreProcessIncludesConContent (PreProcessIfConContent (PreProcessArgsConContent (PreProcessCommentsConContent (ReadConFile $includedfile) "cbInsideCommentLine" "cbOutsideCommentLine") $v_arg1 $v_arg2 $v_arg3 $v_arg4 $v_arg5 $v_arg6 $v_arg7 $v_arg8 $v_arg9) ([ref]$i) "cbConditionCode" "cbOtherCode" "cbInsideTrueCondition" "cbInsideFalseCondition") $includedfile) -replace "\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n\s*\r?\n","`r`n"
		return $includedfilecontent
	}
	else {
		return $line
	}
}

function PreProcessIncludesConContent($concontent, $file) {
	$content=""
	ForEach ($line in $($concontent -split "\r?\n")) {
		$content+=(PreProcessIncludesConLine $line $file)+"`r`n"
	}
	return $content
}

#ProcessVehicles "U:\Progs\EA Games\Battlefield 2 AIX2 Reality\mods\aix2_reality\objects_server\Vehicles\Land\fr_apc_vab" $false $true $true $true $true
function ProcessVehicles($objectsFolder, [bool]$bIncludeStationaryWeapons=$false, [bool]$bIncludeAll=$false, [bool]$bResetMapIcons=$false, [bool]$bResetHUDIcons=$false, [bool]$bExpandIncludes=$false) {

	Get-ChildItem "$objectsFolder\*" -R -Include "*.tweak" | ForEach-Object {
		$file=$_.FullName
		$bVehicle=[regex]::Match($file, "(.*Vehicles.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		$bStationaryWeapon=[regex]::Match($file, "(.*Weapons\\stationary.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		If (($bVehicle) -or ($bStationaryWeapon -and $bIncludeStationaryWeapons) -or ($bIncludeAll)) {
			$bSkip=$false
			#$regexpr="\s*ObjectTemplate.create\s+PlayerControlObject\s+(\S+)\s*\r?\n" # .con
			$regexpr="\s*ObjectTemplate.activeSafe\s+PlayerControlObject\s+(\S+)\s*\r?\n" # .tweak
			$m=[regex]::Match(([System.IO.File]::ReadAllText($file)), $regexpr)
			If ($m.Groups.Count -eq 2) {
				$vehicleName=$m.Groups[1].value
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
							$vehicleMiniMapIcon=$m.Groups[1].value
							$sw.WriteLine("rem $line")
							Continue
						}
					}

					If ($bExpandIncludes) {
						$sw.WriteLine((PreProcessIncludesConLine $line $file))
						Continue
					}

					$sw.WriteLine($line)
				}
				$sw.close()
				$sr.close()
			}
		}
	}
}

function ExtractModArchivesConFile($archivesConFile,$extractFolder,[bool]$bIgnoreZipOutsideModFolder=$false,[int]$extractMode=0) {

	if (($null -eq $archivesConFile) -or !(Test-Path -Path $archivesConFile)) {
		Write-Error "Error: Invalid parameter (archivesConFile)"
		return
	}
	New-Item $extractFolder -ItemType directory -Force
	if (($null -eq $extractFolder) -or !(Test-Path -Path $extractFolder)) {
		Write-Error "Error: Invalid parameter (extractFolder)"
		return
	}

	$modFolder=split-path -parent $archivesConFile
	$conFileName=split-path -Leaf $archivesConFile

	If ([regex]::Match($conFileName, [regex]::Escape("ClientArchives.con"),[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success) {
		$serverclient="client"
	}
	else {
		$serverclient="server"
	}	

	# Objects, Menu, Common, Fonts, Shaders, Scripts

	# First lines have more priority over the last in ServerArchives.con?

	$archiveregexpr="^\s*fileManager.mountArchive\s+(.+)`.zip\s+(.+)\s*"
	$concontent=(PreProcessIncludesConContent (ReadConFile $archivesConFile) $archivesConFile)
	$lines=$($concontent -split "\r?\n")
	for ($i=$lines.Count-1; $i -ge 0; $i--) {
		$line=$lines[$i]
		$m=[regex]::Match($line, $archiveregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		if ($m.Groups.Count -ne 3) {
			Continue
		}
		$file=$m.Groups[1].value # Filename (might include relative path) without .zip
		$folder=$m.Groups[2].value
		Write-Output "$file ($folder)"
		If (Test-Path -Path "$modFolder\$file.zip") {
			$zipfile="$modFolder\$file.zip"
		}
		else {
			If (Test-Path -Path "$modFolder\..\..\$file.zip") {
				$zipfile="$modFolder\..\..\$file.zip"
				If ($bIgnoreZipOutsideModFolder) {
					Write-Output "Skipping $zipfile ($folder) since it is outside current mod"
					Continue
				}
			}
			else {
				Write-Error "Could not find $modFolder\$file.zip or $modFolder\..\..\$file.zip ($folder)"
			}
		}
		If ($extractMode -eq 1) {
			& 7z x -y "$zipfile" `-o"$extractFolder\$folder"
		}
		ElseIf ($extractMode -eq 2) {
			& 7z x -y "$zipfile" `-o"$extractFolder\$folder`_$serverclient"
		}
		Else {
			& 7z x -y "$zipfile" `-o"$extractFolder\$file"
		}
	}
}

#. .\mod_installer.ps1
#$modFolder="U:\Other data\Games\Battlefield 2\Personal mods\Mod DB\originals\bf2"
#ExtractModArchives $modFolder $modFolder $true $true 0
#$extractMode : 0 if the extracted folders use the zip name, 1 if they use the folder specified in the .con file, 2 if a suffix "server" or "client" should be added to that folder.
function ExtractModArchives($modFolder,$extractFolder=$modFolder,[bool]$bIgnoreClientArchives=$false,[bool]$bIgnoreZipOutsideModFolder=$false,[int]$extractMode=0) {

	$serverArchives="$modFolder\ServerArchives.con"
	$clientArchives="$modFolder\ClientArchives.con"

	ExtractModArchivesConFile $serverArchives $extractFolder $bIgnoreZipOutsideModFolder $extractMode
	if (-not $bIgnoreClientArchives) {
		ExtractModArchivesConFile $clientArchives $extractFolder $bIgnoreZipOutsideModFolder $extractMode
	}
}

function FindTemplate($objectsFolder,$searchedTemplateName=$null,[bool]$bShowOutput=$true) {

	if (($null -eq $objectsFolder) -or !(Test-Path -Path $objectsFolder)) {
		Write-Error "Error: Invalid parameter (objectsFolder)"
		return $null
	}

	$bFound=$false
	Get-ChildItem "$objectsFolder\*" -R -Include *.con,*.tweak | ForEach-Object {
		$file=$_.FullName

		#$bVehicle=[regex]::Match($file, "(.*Vehicles.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		#$bStationaryWeapon=[regex]::Match($file, "(.*Weapons\\stationary.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
				
		$regexpr="^\s*ObjectTemplate.create\s+(\S+)\s+(\S+)\s*"
		$concontent=(ReadConFile $file)
		$lines=$($concontent -split "\r?\n")
		for ($i=0; $i -lt $lines.Count; $i++) {
			$line=$lines[$i]
			$m=[regex]::Match($line, $regexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			If ($m.Groups.Count -eq 3) {
				$templateType=$m.Groups[1].value
				$templateName=$m.Groups[2].value
				If (($null -eq $searchedTemplateName) -or ("" -eq $searchedTemplateName)) {
					If ($bShowOutput) { Write-Output "$templateType $templateName ($file)" }
				}
				ElseIf ($m.Groups[2].value -eq $searchedTemplateName) {
					If ($bShowOutput) { Write-Output "$templateType $templateName ($file)" }
					$bFound=$true
					$lastFileFound=$file
				}				
			}
		}

	}
	If ($bFound) {
		return $lastFileFound
	}
	Else {
		return $null
	}
}

#$file="U:\Other data\Games\Battlefield 2\Personal mods\Mod DB\originals\mods\xpack\0\Objects\Vehicles\Land\aav_tunguska\aav_tunguska.con"
#$objectsFolder="U:\Other data\Games\Battlefield 2\Personal mods\Mod DB\originals\mods\xpack\0"
#ListDependenciesConContent (PreProcessIncludesConContent (ReadConFile $file) $file) $objectsFolder
function ListDependenciesConContent($concontent, $objectsFolder) {

	# FindTemplate very slow...

	# add option to list template dependencies that are created in the file...

	if (($null -eq $objectsFolder) -or !(Test-Path -Path $objectsFolder)) {
		Write-Error "Error: Invalid parameter (objectsFolder)"
	}

	$regexpr="^\s*ObjectTemplate.addTemplate\s+(\S+)\s*"
	$lines=$($concontent -split "\r?\n")
	for ($i=0; $i -lt $lines.Count; $i++) {
		$line=$lines[$i]
		#"$line"
		$m=[regex]::Match($line, $regexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		If ($m.Groups.Count -eq 2) {
			$templateDependency=$m.Groups[1].value
			"$templateDependency"
			$neededFile=FindTemplate $objectsFolder $templateDependency $false
			If (($null -ne $neededFile) -and ("" -ne $neededFile) -and ((Get-Item $file ).Basename -ne (Get-Item $neededFile ).Basename)) {
				Write-Output "Template $templateDependency created in $neededFile"
			}
		}
	}
}

function ExtractVehicles($downloadsFolder,$extractFolder,$modFolder,[bool]$bSeparateServerClient=$true,[bool]$bFixVehicleHudNameInconsistencies=$false,[bool]$bFixVehicleTypeInconsistencies=$false,[bool]$bConfirmEachFix=$false) {

	#$modFolder optional, would be to check the existence of includes...
	#if downloadsFolder empty, only use modFolder and use Server/ClientArchives.con

	#$bSeparateServerClient: Objects, Menu folders or Objects_server, Objects_client, etc.

	# TODO: There might be other archives inside the archives, and their extracted name might conflict with existing folders...

	Get-ChildItem "$downloadsFolder\*" -R -Include *.zip,*.rar,*.7z | ForEach-Object {
		& 7z x -y $_.FullName `-o"$($_.DirectoryName)/$($_.Basename)"

		#first assume it follows std dir struct of objects_server/client.zip

		#first should find a .tweak which appears to correspond to a vehicle by checking its content...
		#then in its folder there should be a .con and potentially other .tweak and .con for subparts, as well as ai, meshes, textures, sound folders
		#.con, .tweak, ai should go to server, textures, sound to client. Directory structure?: vehicles\???\vehicleName?
		#should look for any remaining .dds, .tga which might be necessary for Menu... Should read vehicleName.tweak and check for menuicon, etc.
		#effects\vehicles...
		# meshes folder should be copied to server, and its sudirectory structure copied to client with only the .bundlemesh

	}





	#use vehicleHudName to correct killname...

	#parses and get includes (including  menuincon to put in correct folder, etc.) to help extracting from other mods


}

#function CompressModArchives($modFolder) {
#
#}

#Read-Host -Prompt "Press Enter to continue"

#"Please ensure Battlefield 2 is installed (tested with Complete Collection)."

# Change or set to $null if you do not need/want.

#$bforceStandardBF2Only
#$bforceStandardBF2CompleteCollectionOnly

# Give 30 s to decide to continue with defaults (above) or not...
#...

# Should show that only if user has chosen options that requires it...
#if ((Get-Command "7z.exe" -ErrorAction SilentlyContinue) -eq $null)
#{ 
#   "Please install 7z.exe (7-Zip) and ensure it is in Windows PATH, and reboot"
#}

#Read-Host -Prompt "Commands such as wget.exe, 7z.exe are necessary please comment the following line and relaunch the script if you already have them or press Enter to continue"
#Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); choco feature enable -n useRememberedArgumentsForUpgrades ; choco upgrade -y -r --no-progress 7zip Wget ; refreshenv

# Useless...
#$ans=Read-Host 'Do you want to create a new mod from the provided template? (y: create a new mod, n: modify existing)'
#$bNewMod=!($ans -match '^n(o)?$')

#$modFolder=Read-Host 'Where is your Battlefield 2\mods\custommod (e.g. C:\Program Files\EA Games\Battlefield 2\mods\xpack) folder (Warning: it will create or modify it so make a backup if it already exists)?'
#if (Test-Path -Path $modFolder) {
#    $bNewMod=$false
#} else {
#	$bNewMod=$true
#    if (!(Test-Path -Path $modFolder\..)) {
#		"Error: [$modFolder\..] not found"
#		exit
#	}
#}



# DOWNLOAD LINKS ARE TEMPORARY?????????????



#Template. Set to $null if you do not need/want some options, vehicle will be ignored if they are required or if there is an error.
#$vehicleName="apc_btr_t"
#$vehicleType=1 #Tank:0,APC:1,AAV=5...
#$downloadLink="https://www.moddb.com/downloads/mirror/215067/123/37d435af1b55326470f5731868209805"
#$homePage="https://www.moddb.com/games/battlefield-2/addons/bf2-new-mods-btr-t-ifv-puma-and-toyota-rocket-launcher"
#$wiki="https://en.wikipedia.org/wiki/BTR-T"
#$preCustomScript=$null
#$postCustomScript="apc_btr_t.ps1"
#AddNewVehicle $vehicleName $vehicleType $vehicleTeams $downloadLink $homePage $wiki $preCustomScript $postCustomScript

function main()
{
	$vehicleName="apc_btr_t"
	$vehicleType=1
	$downloadLink="https://www.moddb.com/games/battlefield-2/addons/bf2-new-mods-btr-t-ifv-puma-and-toyota-rocket-launcher"
	$homePage="https://www.moddb.com/games/battlefield-2/addons/bf2-new-mods-btr-t-ifv-puma-and-toyota-rocket-launcher"
	$wiki="https://en.wikipedia.org/wiki/BTR-T"
	$preCustomScript=$null
	$postCustomScript="$scriptPath\apc_btr_t.ps1"
#	AddNewVehicle $vehicleName $vehicleType $vehicleTeams $downloadLink $homePage $wiki $preCustomScript $postCustomScript

	#Check xpack and bf2 existence...
	#FindAllVehicles, check ServerArchives.con, fileManager.mountArchive XXX.zip Objects, if mods/bf2/Objects_server.zip or mods/xpack/Objects_server.zip, should make a copy of the .tweak and add the ref to the new efserv.zip, vehserv.zip, stsgarageserv.zip in ServerArchives.con
	$objectsFolder="C:\tmp\Objects"

	#Use git to create a repo and make commits inside...

}

function AddNewVehicle($vehicleName, $vehicleType, $vehicleTeams, $downloadLink, $homePage=$null, $wiki=$null, $preCustomScript=$null, $postCustomScript=$null) {
	$preCustomScript

	#first should try to download directly from $downloadLink (how to get wget error code?), if it fails assumes it is moddb, how to do without ie...

	# or if not easy to download auto, ask to manually download and gather in a folder, then extract all *.zip,*.rar,*.7z...

	$ie = new-object -ComObject InternetExplorer.Application
	$ie.Navigate($downloadLink)
	$ln=$IE.Document.getElementsByTagName('a') | Where-Object {$_.href -match "/addons/start"}
	$ie.Navigate($ln.IHTMLAnchorElement_href)
	$ln=$IE.Document.getElementsByTagName('a') | Where-Object {$_.href -match "/downloads/mirror"}
	$downloadLink=$ln.IHTMLAnchorElement_href

	Invoke-WebRequest $downloadLink -UseBasicParsing -OutFile "C:\tmp\download.zip"
	& 7z x -y "C:\tmp\download.zip" `-o"C:\tmp\download"
	Get-ChildItem "C:\tmp\download\*" -R -Include *.zip,*.rar,*.7z | ForEach-Object {
		& 7z x -y $_.FullName `-o"$($_.DirectoryName)/$($_.Basename)"
		Remove-Item $_.FullName
	}

#search for .bundlemesh, .collisionmesh, .tweak, .con, then move sounds
	#sometimes also there are weapons, effects, for that use $postCustomScript?...
	$postCustomScript
}

function CreateNewModFromTemplate($modFolder) {
	If (Test-Path -Path "$modFolder\..\xpack") {
		$bxpack=$true
	}
	Else {
		$bxpack=$false
		"Error: Missing Special Forces"
		exit
	}
	If (Test-Path -Path "$modFolder\..\bf2\Booster_server.zip") {
		$bbooster=$true
	}
	Else {
		$bbooster=$false
		"Error: Missing Armored Fury"
		exit
	}
	If (Test-Path -Path "$modFolder\..\bf2\Levels\OperationSmokeScreen") {
		$bef=$true
	}
	Else {
		$bef=$false
		"Error: Missing Euro Force"
		exit
	}

	New-Item "$modFolder\Levels" -ItemType directory -Force
	Copy-Item -Path python\game\scoringCommon.py,FS.bat,WINDOWED.bat -Destination "$modFolder\" -Force -Recurse
	Copy-Item -Path "$modFolder\..\xpack\*"  -Include AI,Localization,Logs,menu,movies,Objects,python,Settings,shaders,Common_client.zip,Common_server.zip,Fonts_client.zip,Menu_client.zip,Menu_server.zip,Objects_client.zip,Objects_server.zip,Shaders_client.zip,ClientArchives.con,GameLogicInit.con,ServerArchives.con,Mod.desc,bf2xpack.ico,mod.jpg,mod_icon.jpg,bst_archive.md5,bst_archive_mod.md5,std_archive.md5,std_archive_mod.md5,mod.png,mod_icon.png,WINDOWED.bat -Destination "$modFolder\" -Force -Recurse
	Copy-Item -Path "$modFolder\..\xpack\Levels\Gulf_of_Oman" -Destination "$modFolder\Levels\" -Force -Recurse

	# Need to replace xpack_alt (which is a template)
	(Get-Content "$modFolder\FS.bat") -replace "xpack_alt",(Get-Item $modFolder).Name | Set-Content "$modFolder\FS.bat"
	(Get-Content "$modFolder\WINDOWED.bat") -replace "xpack_alt",(Get-Item $modFolder).Name | Set-Content "$modFolder\WINDOWED.bat"

	# Specific...
	Copy-Item -Path ServerArchives.con -Destination "$modFolder\" -Force -Recurse
	Copy-Item -Path ClientArchives.con -Destination "$modFolder\" -Force -Recurse
	Copy-Item -Path Levels\Gulf_of_Oman -Destination "$modFolder\Levels\" -Force -Recurse
	cmd.exe /c "$modFolder\Levels\update_server.bat" # Need 7z
	#if $bef OperationSmokeScreen, Taraba_Quarry need specific fixes to avoid vehicles conflicts...



	# For standard Battlefield 2 only (US vs MEC)
	# For standard Battlefield 2 Complete Collection only (allows some Chinese vehicles, EURO vs RU, but will need to move specific vehicles from euro and armored fury)

}

function SetLevelTeams($team1, $team2) {
#Levels\Gulf_of_Oman\server\Init.con 
}
