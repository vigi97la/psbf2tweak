# DO NOT USE, TEMPORARY

#. .\mod_installer.ps1
#$modFolder="C:\tmp\mods\bf2"
#$extractFolder="$modFolder\extracted"
#ExtractModArchives $modFolder $extractFolder $false $false 1
#$modFolder="C:\tmp\mods\xpack"
#$extractFolder="$modFolder\extracted"
#ExtractModArchives $modFolder $extractFolder $false $false 1
#$modFolder="C:\tmp\mods\aix2_reality"
#$extractFolder="$modFolder\extracted"
#ExtractModArchives $modFolder $extractFolder $false $false 1
##PreProcessVehicles $extractFolder $null $true $true $true $true $true # Can be very slow (2h) for AIX2 Reality handheld weapons...
#FindTemplate $extractFolder $null $false $true $false $false # To build a template cache
#MergeTemplateMultipleDefinitions $extractFolder $false # Post-processing of the template cache to attempt to solve some problems, can be slow (2h) for AIX2 Reality...
##$file="C:\tmp\mods\bf2\extracted\Objects\Vehicles\Land\jep_mec_paratrooper\jep_mec_paratrooper.con"
##$file="C:\tmp\mods\xpack\extracted\Objects\Vehicles\xpak_vehicles\xpak_atv\xpak_atv.con"
#$vehicleToExtract="Objects\Vehicles\Land\fr_trk_logistics\fr_trk_logistics.con"
##$vehicleToExtract="Objects\Vehicles\Land\fr_apc_vab\fr_apc_vab.con"
##$vehicleToExtract="Objects\Vehicles\Land\fr_tnk_leclerc\fr_tnk_leclerc.con" # Then also for fr_tnk_leclerc_bf2...
#$file=(Get-Item "$modFolder\extracted\$vehicleToExtract").FullName
#$exportFolder="$modFolder\export"
##ListDependencies $file $extractFolder $exportFolder $true $true $false $modFolder\..\bf2\extracted $false $modFolder\..\xpack\extracted $true $false $false 16
#ListDependencies $file $extractFolder $exportFolder $true $true $true $modFolder\..\bf2\extracted $true $modFolder\..\xpack\extracted $true $false $false 16
#. .\MiscFixes.ps1
#FixVehicleType $exportFolder $true $true $true $true $true $true
#. .\MiscTweaks.ps1
#DontClearTeamOnExitUpdate $exportFolder 0 $true $true
#DelayToUseUpdate $exportFolder 0 $true $true
#SplitToServerAndClientFolders $exportFolder $exportFolder\server $exportFolder\client
#SplitToServerAndClientFolders $exportFolder"_bf2_modified" $exportFolder"_bf2_modified"\server $exportFolder"_bf2_modified"\client
#SplitToServerAndClientFolders $exportFolder"_xpack_modified" $exportFolder"_xpack_modified"\server $exportFolder"_xpack_modified"\client

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

function ReadConFile($file) {
	$content=""
	If (-not (Test-Path -Path "$file")) {
		Write-Warning "$file not found"
		return $content
	}
	$sr=[System.IO.StreamReader]$file
	while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
		$line=$sr.ReadLine()
		if ($null -eq $line) {
			break
		}
		$content+=$line+"`r`n"
	}
	$sr.close()
	return $content
}

#. .\mod_installer.ps1
#ConvertBlockCommentsConContent (ReadConFile "U:\Other data\Games\Battlefield 2\Personal mods\Mod DB\originals\aix2real\simpleparams.con")
function ConvertBlockCommentsConContent($concontent) {
	$content=""
	$beginremregexpr="^\s*beginrem\s*"
	$endremregexpr="^\s*endrem\s*"
	$bInsideBlockComment=$false
	$lines=@($concontent -split "\r?\n")
	for ($i=0; $i -lt $lines.Count; $i++) {
		$line=$lines[$i]
		if ($bInsideBlockComment) {
			$m=[regex]::Match($line, $endremregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			if ($m.Success) {
				$bInsideBlockComment=$false
				$content+="rem "+$line+"`r`n"
				Continue
			}
			$content+="rem "+$line+"`r`n"
			Continue
		}
		$m=[regex]::Match($line, $beginremregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		if ($m.Success) {
			$bInsideBlockComment=$true
			$content+="rem "+$line+"`r`n"
			Continue
		}
		$content+=$line+"`r`n"
	}
	return $content
}

function cbInsideCommentLine($concontent, $i, $line, $params) {
	#Write-Warning "Comment     : $line" # Write-Output causes problems?
	$content=$params
	return $content
}

function cbOutsideCommentLine($concontent, $i, $line, $params) {
	#Write-Warning "Not comment : $line" # Write-Output causes problems?
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
	$lines=@($concontent -split "\r?\n")
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
	#$ifcondregexpr=[regex]::new("^\s*if\s+(\S*)\s*==\s*(\S*)\s*","Compiled, IgnoreCase, CultureInvariant")
	$elseIfregexpr="^\s*elseIf\s*"
	$elseIfcondregexpr="^\s*elseIf\s+(\S*)\s*==\s*(\S*)\s*"
	$elseregexpr="^\s*else\s*"
	$endifregexpr="^\s*endIf\s*"
	$bInsideCondition=$false
	$bInsideTrueCondition=$false
	$bFoundTrueCondition=$false
	$lines=@($concontent -split "\r?\n")
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
				if ((-not $bFoundTrueCondition) -and ($m.Groups[1].value -ieq $m.Groups[2].value)) {
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
				#$m=$ifcondregexpr.Match($line)
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
				#$m=$ifcondregexpr.Match($line)
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
		#$m=$ifcondregexpr.Match($line)
		if (($m.Groups.Count -eq 3)) {

			$params=$content
			$content=& $cbConditionCode $concontent $i.value $line $params

			$bInsideCondition=$true
			$bInsideTrueCondition=$false
			$bFoundTrueCondition=$false
			if ($m.Groups[1].value -ieq $m.Groups[2].value) {
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
	ForEach ($line in @($concontent -split "\r?\n")) {

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

#$file="U:\Other data\Games\Battlefield 2\Personal mods\Mod DB\originals\aix2real\simpleconst.tweak"
#PreProcessConstsConContent (ReadConFile $file)
function PreProcessConstsConContent($concontent) {
	$constNames=$null
	$constValues=$null

	$content=""
	ForEach ($line in @($concontent -split "\r?\n")) {

		# null...?

		# numbers, strings...?
		$m=[regex]::Match($line,"^\s*const\s+(\S+)\s*=\s*([+-]?([0-9]*\.)?[0-9]+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		If ($m.Groups.Count -eq 3) {
			$constNames+=,$m.Groups[1].value
			$constValues+=,$m.Groups[2].value
		}
		ElseIf ($null -ne $constNames) {
			for ($i=0;$i -lt $constNames.Count;$i++) {
				$regescconstName=[regex]::Escape($constNames[$i])
				$line=$line -replace $regescconstName,$constValues[$i]
			}
		}

		$content+=$line+"`r`n"
	}
	Return $content
}

function PreProcessVarsConContent($concontent) {
	$varNames=$null
	$varValues=$null
	$bVarArrowAssignments=$null

	$content=""
	ForEach ($line in @($concontent -split "\r?\n")) {

		# null...?

		# numbers, strings...?

		# Only variables initialized with a constant and until an operator "->" is found will be replaced by their initial value, or constant value set by "=" operator...

		$m=[regex]::Match($line,"^\s*var\s+(\S+)\s*=\s*([+-]?([0-9]*\.)?[0-9]+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		If ($m.Groups.Count -eq 3) {
			$varNames+=,$m.Groups[1].value
			$varValues+=,$m.Groups[2].value
			$bVarArrowAssignments+=,$false
		}
		ElseIf ($null -ne $varNames) {
			for ($i=0;$i -lt $varNames.Count;$i++) {
				$regescvarName=[regex]::Escape($varNames[$i])
				$m2=[regex]::Match($line,"^\s*$regescvarName\s*=\s*([+-]?([0-9]*\.)?[0-9]+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
				If ($m2.Groups.Count -eq 2) {
					$varValues[$i]=$m2.Groups[1].value
					$bVarArrowAssignments[$i]=$false
				}
				Else {
					$m3=[regex]::Match($line,"\s*->\s*$regescvarName\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					If ($m3.Groups.Count -eq 2) {
						$bVarArrowAssignments[$i]=$true
					}
					ElseIf (!$bVarArrowAssignments[$i]) { $line=$line -replace $regescvarName,$varValues[$i] }
				}
			}
		}

		$content+=$line+"`r`n"
	}
	Return $content
}

function PreProcessIncludesConLine($line, $file) {
	$m=[regex]::Match($line, "^\s*include\s+(\S+)(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
	if ($m.Groups.Count -ge 2) {
		$resRelPath=$m.Groups[1].value
		$includedFile=Join-Path ([System.IO.FileInfo]$file).DirectoryName $resRelPath
		If (([System.IO.FileInfo]$includedFile).Extension -ieq "") {
			$includedFile="$includedFile.con"
		}
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
		$includedFileContent=(PreProcessRunsConContent (PreProcessIncludesConContent (PreProcessIfConContent (PreProcessVarsConContent (PreProcessConstsConContent (PreProcessArgsConContent (PreProcessCommentsConContent (ReadConFile $includedFile) "cbInsideCommentLine" "cbOutsideCommentLine") $v_arg1 $v_arg2 $v_arg3 $v_arg4 $v_arg5 $v_arg6 $v_arg7 $v_arg8 $v_arg9))) ([ref]$i) "cbConditionCode" "cbOtherCode" "cbInsideTrueCondition" "cbInsideFalseCondition") $includedFile) $includedFile) -replace "\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n\s*\r?\n","`r`n"
		return $includedFileContent
	}
	else {
		return $line
	}
}

function PreProcessIncludesConContent($concontent, $file) {
	$content=""
	ForEach ($line in @($concontent -split "\r?\n")) {
		$content+=(PreProcessIncludesConLine $line $file)+"`r`n"
	}
	return $content
}

function GetFileIncludedConLine($line, $file) {
	$m=[regex]::Match($line, "^\s*include\s+(\S+)(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
	If ($m.Groups.Count -ge 2) {
		return Join-Path (Get-item $file).DirectoryName ($m.Groups[1].value -replace "`"","" -replace "/","\")
	}
	Else {
		return $null
	}
}

function PreProcessRunsConLine($line, $file) {
	$m=[regex]::Match($line, "^\s*run\s+(\S+)(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
	if ($m.Groups.Count -ge 2) {
		$resRelPath=($m.Groups[1].value -replace "`"","" -replace "/","\")
		$runFile=Join-Path ([System.IO.FileInfo]$file).DirectoryName $resRelPath
		If (([System.IO.FileInfo]$runFile).Extension -ieq "") {
			$runFile="$runFile.con"
		}
		$v_arg1=$m.Groups[3].value
		$v_arg2=$m.Groups[5].value
		$v_arg3=$m.Groups[7].value
		$v_arg4=$m.Groups[9].value
		$v_arg5=$m.Groups[11].value
		$v_arg6=$m.Groups[13].value
		$v_arg7=$m.Groups[15].value
		$v_arg8=$m.Groups[17].value
		$v_arg9=$m.Groups[19].value
		#$i=0
		#$runFileContent=(PreProcessRunsConContent (PreProcessIncludesConContent (PreProcessIfConContent (PreProcessVarsConContent (PreProcessConstsConContent (PreProcessArgsConContent (PreProcessCommentsConContent (ReadConFile $runFile) "cbInsideCommentLine" "cbOutsideCommentLine") $v_arg1 $v_arg2 $v_arg3 $v_arg4 $v_arg5 $v_arg6 $v_arg7 $v_arg8 $v_arg9))) ([ref]$i) "cbConditionCode" "cbOtherCode" "cbInsideTrueCondition" "cbInsideFalseCondition") $runFile) $runFile) -replace "\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n\s*\r?\n","`r`n"
		$runFileContent=(PreProcessRunsConContent (PreProcessIncludesConContent (PreProcessVarsConContent (PreProcessConstsConContent (PreProcessArgsConContent (PreProcessCommentsConContent (ReadConFile $runFile) "cbInsideCommentLine" "cbOutsideCommentLine") $v_arg1 $v_arg2 $v_arg3 $v_arg4 $v_arg5 $v_arg6 $v_arg7 $v_arg8 $v_arg9))) $runFile) $runFile) -replace "\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n\s*\r?\n","`r`n"
		return $runFileContent
	}
	else {
		return $line
	}
}

function PreProcessRunsConContent($concontent, $file) {
	$content=""
	ForEach ($line in @($concontent -split "\r?\n")) {
		$content+=(PreProcessRunsConLine $line $file)+"`r`n"
	}
	return $content
}

function GetFileRunConLine($line, $file) {
	$m=[regex]::Match($line, "^\s*run\s+(\S+)(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
	If ($m.Groups.Count -ge 2) {
		return Join-Path (Get-item $file).DirectoryName ($m.Groups[1].value -replace "`"","" -replace "/","\")
	}
	Else {
		return $null
	}
}

#. .\mod_installer.ps1
#$vehicleToExtract="U:\Progs\EA Games\Battlefield 2 AIX2 Reality\mods\aix2_reality\objects_server\Vehicles\Land\fr_apc_vab"
#PreProcessVehicles $vehicleToExtract $null $false $true $true $true $true
function PreProcessVehicles($objectsFolder,$outputFolder=$null,[bool]$bIncludeStationaryWeapons=$false,[bool]$bIncludeAll=$false,[bool]$bExpandIncludes=$true,[bool]$bOverwrite=$false,[bool]$bShowOutput=$true) {

	If (($null -ne $outputFolder) -and ("" -ne $outputFolder)) {
		New-Item "$outputFolder" -ItemType directory -Force | Out-Null
	}

	Get-ChildItem "$objectsFolder" -R -Include "*.tweak" | ForEach-Object {
		$file=$_.FullName
		$bVehicle=[regex]::Match($file, "(.*Vehicles.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		$bStationaryWeapon=[regex]::Match($file, "(.*Weapons\\stationary.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		If (($bVehicle) -or ($bStationaryWeapon -and $bIncludeStationaryWeapons) -or ($bIncludeAll)) {
			$bSkip=$false
			#$regexpr="\s*ObjectTemplate.create\s+(PlayerControlObject|GenericFireArm|GenericProjectile)\s+(\S+)\s*\r?\n" # .con
			$regexpr="\s*ObjectTemplate.activeSafe\s+(PlayerControlObject|GenericFireArm|GenericProjectile)\s+(\S+)\s*\r?\n" # .tweak
			$m=[regex]::Match(([System.IO.File]::ReadAllText($file)), $regexpr)
			If ($m.Groups.Count -eq 3) {
				$vehicleName=$m.Groups[2].value
			}
			else {
				$bSkip=$true
			}

			If (-not $bSkip) {
				If ($bShowOutput) { Write-Output "$file : $vehicleName" }

				$sr=[System.IO.StreamReader]$file
				$sw=[System.IO.StreamWriter]"$file.tmp"
				while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
					$line=$sr.ReadLine()
					if ($null -eq $line) {
						break
					}

					#Write-Warning "$line"

					If ($bExpandIncludes) {
						$sw.WriteLine((PreProcessIncludesConLine $line $file))
						Continue
					}

					$sw.WriteLine($line)
				}
				$sw.close()
				$sr.close()
				If (($null -ne $outputFolder) -and ("" -ne $outputFolder)) {
					# Should remove $objectsFolder from the path in $file and add the rest at the end of the desired folder...
					If ($objectsFolder -ieq $file) { $regesc=[regex]::Escape(([System.IO.FileInfo]$objectsFolder).DirectoryName) }
					Else { $regesc=[regex]::Escape($objectsFolder) }
					$m=[regex]::Match($file, "$regesc\\?(.+)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
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

function PreProcessConFiles($folder) {
	Get-ChildItem "$folder" -R -Include "*.con","*.ai" | ForEach-Object {
		$file=$_.FullName
		#iii=0
		#$concontent=(PreProcessRunsConContent (PreProcessIncludesConContent (PreProcessIfConContent (PreProcessVarsConContent (PreProcessConstsConContent (PreProcessCommentsConContent (ReadConFile $file) "cbInsideCommentLine" "cbOutsideCommentLine"))) ([ref]$iii) "cbConditionCode" "cbOtherCode" "cbInsideTrueCondition" "cbInsideFalseCondition") $file) $file)# -replace "\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n\s*\r?\n","`r`n"
		$concontent=(PreProcessRunsConContent (PreProcessIncludesConContent (PreProcessVarsConContent (PreProcessConstsConContent (PreProcessCommentsConContent (ReadConFile $file) "cbInsideCommentLine" "cbOutsideCommentLine"))) $file) $file)# -replace "\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n\s*\r?\n","`r`n"
		$sw=[System.IO.StreamWriter]"$file`preprocessed"
		$sw.Write($concontent)
		$sw.close()
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

	$archiveregexpr="^\s*fileManager.mountArchive\s+(.+)`\.zip\s+(.+)\s*"
	$concontent=(PreProcessIncludesConContent (ReadConFile $archivesConFile) $archivesConFile)
	$lines=@($concontent -split "\r?\n")
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
				Write-Error "Error: Could not find $modFolder\$file.zip or $modFolder\..\..\$file.zip ($folder)"
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
#$modFolder="U:\Progs\EA Games\Battlefield 2 AIX2 Reality\mods\xpack"
#$extractFolder="$modFolder\extracted"
#ExtractModArchives $modFolder $extractFolder $true $true 0
#$extractMode: 0 if the extracted folders use the zip name, 1 if they use the folder specified in the .con file, 2 if a suffix "server" or "client" should be added to that folder.
function ExtractModArchives($modFolder,$extractFolder=$modFolder,[bool]$bIgnoreClientArchives=$false,[bool]$bIgnoreZipOutsideModFolder=$false,[int]$extractMode=0) {

	$serverArchives="$modFolder\ServerArchives.con"
	$clientArchives="$modFolder\ClientArchives.con"

	ExtractModArchivesConFile $serverArchives $extractFolder $bIgnoreZipOutsideModFolder $extractMode
	if (-not $bIgnoreClientArchives) {
		ExtractModArchivesConFile $clientArchives $extractFolder $bIgnoreZipOutsideModFolder $extractMode
	}
}

# Classes are not directly available before Powershell 5...
#class ObjectTemplate {
#    [string]$name=$null
#    [string]$type=$null
#    [string]$file=$null
#    #[string[]]$files=$null
#	[string[]]$children=$null
#	# Position
#	[double]$x=0
#	[double]$y=0
#	[double]$z=0
#	# Rotation
#	[double]$phi=0
#	[double]$theta=0
#	[double]$psi=0
#}

function FindTemplate($extractedFolder,$searchedTemplateName=$null,[bool]$bUsePreProcessedConFiles=$false,[bool]$bUseCache=$true,[bool]$bShowOutput=$true,[bool]$bEnableSlowSearch=$false) {

	if (($null -eq $extractedFolder) -or !(Test-Path -Path $extractedFolder)) {
		Write-Error "Error: Invalid parameter (objectsFolder)"
		return $null
	}

	$templateName=$null
	$bFound=$false
	$lastChildrenFound=$null
	$lastFilesFound=$null
	$cachefile="$extractedFolder\cache_db.csv"
	If ((-not $bUseCache) -or (($null -eq $searchedTemplateName) -or ("" -eq $searchedTemplateName))) {
		If ($bUseCache) {
			$sw=[System.IO.StreamWriter]$cachefile
		}
		If ($bUsePreProcessedConFiles) {
			$fileglob="*.conpreprocessed","*.aipreprocessed"
		}
		Else {
			$fileglob="*.con","*.ai"
		}
		#$fileglob="*.con","*.tweak","*.ai","*.inc"

		Get-ChildItem "$extractedFolder\*" -R -Include $fileglob | ForEach-Object {

			# End of any previous object...
			If ($null -ne $templateName) {
				If (($null -eq $searchedTemplateName) -or ("" -eq $searchedTemplateName)) {
					$sw.Write("$templateName;$templateType")
					foreach ($element in $templateChildren) {
						If (($null -ne $element) -and ("" -ne $element)) {
							$sw.Write(";$element")
						}
					}
					foreach ($element in $templateFiles) {
						If (($null -ne $element) -and ("" -ne $element)) {
							$sw.Write(";$element")
						}
					}
					$sw.WriteLine()
					$templateFile=$templateFiles[0]
					If ($bShowOutput) { Write-Output "$templateType $templateName ($templateFile)" }
				}
				ElseIf ($templateName -ieq $searchedTemplateName) {
					$templateFile=$templateFiles[0]
					If ($bShowOutput) { Write-Output "$templateType $templateName ($templateFile)" }
					$bFound=$true
					$lastChildrenFound=$templateChildren
					$lastFilesFound=$templateFiles
				}
			}

			$templateName=$null

			$file=$_.FullName
			If ($bUsePreProcessedConFiles) {
				$concontent=(ReadConFile $file)
			}
			Else {
				#iii=0
				#$concontent=(PreProcessRunsConContent (PreProcessIncludesConContent (PreProcessIfConContent (PreProcessVarsConContent (PreProcessConstsConContent (PreProcessCommentsConContent (ReadConFile $file) "cbInsideCommentLine" "cbOutsideCommentLine"))) ([ref]$iii) "cbConditionCode" "cbOtherCode" "cbInsideTrueCondition" "cbInsideFalseCondition") $file) $file)# -replace "\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n\s*\r?\n","`r`n"
				$concontent=(PreProcessRunsConContent (PreProcessIncludesConContent (PreProcessVarsConContent (PreProcessConstsConContent (PreProcessCommentsConContent (ReadConFile $file) "cbInsideCommentLine" "cbOutsideCommentLine"))) $file) $file)# -replace "\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n\s*\r?\n","`r`n"
			}

			$lines=@($concontent -split "\r?\n")
			for ($i=0; $i -lt $lines.Count; $i++) {
				$line=$lines[$i]
				#$m=[regex]::Match($line, "^\s*(ObjectTemplate|aiTemplatePlugIn).(create|active|activeSafe)\s+(\S+)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
				$m=[regex]::Match($line, "^\s*(ObjectTemplate\S*|aiTemplate\S*|weaponTemplate\S*)\.(create|active|activeSafe)\s+(\S+)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
				If ($m.Groups.Count -ne 5) {
					#$m=[regex]::Match($line, "^\s*(aiTemplate|weaponTemplate).(create|active|activeSafe)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					$m=[regex]::Match($line, "^\s*(ObjectTemplate\S*|aiTemplate\S*|weaponTemplate\S*)\.(create|active|activeSafe)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
				}
				If (($m.Groups.Count -eq 5) -or ($m.Groups.Count -eq 4)) {

					# End of any previous object...
					If ($null -ne $templateName) {
						If (($null -eq $searchedTemplateName) -or ("" -eq $searchedTemplateName)) {
							$sw.Write("$templateName;$templateType")
							foreach ($element in $templateChildren) {
								If (($null -ne $element) -and ("" -ne $element)) {
									$sw.Write(";$element")
								}
							}
							foreach ($element in $templateFiles) {
								If (($null -ne $element) -and ("" -ne $element)) {
									$sw.Write(";$element")
								}
							}
							$sw.WriteLine()
							$templateFile=$templateFiles[0]
							If ($bShowOutput) { Write-Output "$templateType $templateName ($templateFile)" }
						}
						ElseIf ($templateName -ieq $searchedTemplateName) {
							$templateFile=$templateFiles[0]
							If ($bShowOutput) { Write-Output "$templateType $templateName ($templateFile)" }
							$bFound=$true
							$lastChildrenFound=$templateChildren
							$lastFilesFound=$templateFiles
						}
					}

					# Beginning of new object...
					If ($m.Groups.Count -eq 5) {
						$templateType=$m.Groups[3].value
						$templateName=$m.Groups[4].value
					}
					Else {
						$templateType=$m.Groups[1].value
						$templateName=$m.Groups[3].value
					}
					$templateFile=$file
					$templateFiles=,$file
					$templateChildren=$null
				}
				ElseIf ($null -ne $templateName) {
					#$m=[regex]::Match($line, "^\s*(ObjectTemplate).(setObjectTemplate|armor.addArmorEffect)\s+(\d+)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					$m=[regex]::Match($line, "^\s*(ObjectTemplate\S*|aiTemplate\S*|weaponTemplate\S*)\.(\S*Template\S*|\S+\.\S*Template\S*|add\S*|\S+\.add\S*)\s+(\d+)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					If ($m.Groups.Count -eq 5) {
						$templateChild=$m.Groups[4].value
						If ($null -ne ($templateChild -as [double])) {
							continue
						}
						$templateChildren+=,$templateChild
						continue
					}
					#$m=[regex]::Match($line, "^\s*(ObjectTemplate).(addTemplate|template|particleSystemTemplate|projectileTemplate|tracerTemplate|detonation.endEffectTemplate|target.targetObjectTemplate|aiTemplate|.vehicleHud.pantingSound|.vehicleHud.injurySound)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					$m=[regex]::Match($line, "^\s*(ObjectTemplate\S*|aiTemplate\S*|weaponTemplate\S*)\.(\S*Template\S*|\S+\.\S*Template\S*|add\S*|\S+\.add\S*|\.vehicleHud\S*Sound)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					If ($m.Groups.Count -eq 4) {
						$templateChild=$m.Groups[3].value
						If ($null -ne ($templateChild -as [double])) {
							continue
						}
						$templateChildren+=,$templateChild
						continue
					}
					#$m=[regex]::Match($line, "^\s*aiTemplate\.addPlugIn\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					#If ($m.Groups.Count -eq 2) {
					#	$templateChild=$m.Groups[1].value
					#	$templateChildren+=,$templateChild
					#	continue
					#}
					#$m=[regex]::Match($line, "^\s*ObjectTemplate.textureName\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					#$m=[regex]::Match($line, "^\s*\S*Template\S*\.\S*texture\S*\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					$m=[regex]::Match($line, "^\s*ObjectTemplate\.textureName\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					If ($m.Groups.Count -eq 2) {
						$resRelPaths=@($m.Groups[1].value -split ",")
						for ($j=0; $j -lt $resRelPaths.Count; $j++) {
							$resRelPath=($resRelPaths[$j] -replace "`"","" -replace "/","\")
							#Write-Warning "$extractedFolder\$resRelPath.dds"
							$resFile=Join-Path $extractedFolder "$resRelPath.dds"
							#If (!(Test-Path -Path $resFile)) {
							#	Write-Warning "$resFile not found ($templateFile)"
							#}
							$templateFiles+=,$resFile
						}
						continue
					}
					$m=[regex]::Match($line, "^\s*ObjectTemplate\.collisionMesh\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					If ($m.Groups.Count -eq 2) {
						$resRelPath=($m.Groups[1].value -replace "`"","" -replace "/","\")
						$resFile=Join-Path (Join-Path ([System.IO.FileInfo]$templateFile).DirectoryName "meshes") "$resRelPath.collisionmesh"
						If (!(Test-Path -Path $resFile)) {
							$resFile=Join-Path (Join-Path ([System.IO.FileInfo]$templateFile).DirectoryName "..\$resRelPath\meshes") "$resRelPath.collisionmesh"
							#If (!(Test-Path -Path $resFile)) {
							#	Write-Warning "$resFile not found ($templateFile)"
							#}
						}
						If ($bEnableSlowSearch -and !(Test-Path -Path $resFile)) {
							Write-Warning "Attempting a slow search of $resRelPath mesh"
							Get-ChildItem -Path $extractedFolder -Filter "$resRelPath.collisionmesh" -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object {
								$resFile=$_.FullName
							}
							If (!(Test-Path -Path $resFile)) {
								Write-Warning "$resFile not found ($templateFile)"
							}
						}
						$templateFiles+=,$resFile
						continue
					}
					$m=[regex]::Match($line, "^\s*ObjectTemplate\.geometry\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					If ($m.Groups.Count -eq 2) {
						$resRelPath=($m.Groups[1].value -replace "`"","" -replace "/","\")
						# BundledMesh vs. SkinnedMesh, ObjectTemplate vs. GeometryTemplate type...?
						$resFile=Join-Path (Join-Path ([System.IO.FileInfo]$templateFile).DirectoryName "meshes") "$resRelPath.bundledmesh"
						If (!(Test-Path -Path $resFile)) {
							$resFile=Join-Path (Join-Path ([System.IO.FileInfo]$templateFile).DirectoryName "meshes") "$resRelPath.skinnedmesh"
							If (!(Test-Path -Path $resFile)) {
								$resFile=Join-Path (Join-Path ([System.IO.FileInfo]$templateFile).DirectoryName "meshes") "$resRelPath.staticmesh"
								If (!(Test-Path -Path $resFile)) {
									$resFile=Join-Path (Join-Path ([System.IO.FileInfo]$templateFile).DirectoryName "..\$resRelPath\meshes") "$resRelPath.bundledmesh"
									If (!(Test-Path -Path $resFile)) {
										$resFile=Join-Path (Join-Path ([System.IO.FileInfo]$templateFile).DirectoryName "..\$resRelPath\meshes") "$resRelPath.skinnedmesh"
										If (!(Test-Path -Path $resFile)) {
											$resFile=Join-Path (Join-Path ([System.IO.FileInfo]$templateFile).DirectoryName "..\$resRelPath\meshes") "$resRelPath.staticmesh"
											#If (!(Test-Path -Path $resFile)) {
											#	Write-Warning "$resFile not found ($templateFile)"
											#}
										}
									}
								}
							}
						}
						If ($bEnableSlowSearch -and !(Test-Path -Path $resFile)) {
							Write-Warning "Attempting a slow search of $resRelPath mesh"
							Get-ChildItem -Path $extractedFolder -Filter "$resRelPath.bundledmesh" -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object {
								$resFile=$_.FullName
							}
							If (!(Test-Path -Path $resFile)) {
								Get-ChildItem -Path $extractedFolder -Filter "$resRelPath.skinnedmesh" -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object {
									$resFile=$_.FullName
								}
								If (!(Test-Path -Path $resFile)) {
									Get-ChildItem -Path $extractedFolder -Filter "$resRelPath.staticmesh" -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object {
										$resFile=$_.FullName
									}
									If (!(Test-Path -Path $resFile)) {
										Write-Warning "$resFile not found ($templateFile)"
									}
								}
							}
						}
						$templateFiles+=,$resFile
						continue
					}
					#$m=[regex]::Match($line, "^\s*ObjectTemplate.(soundFilename|seatAnimationSystem|animationSystem|animationSystem1P|animationSystem3P|skeleton|skeleton1P|skeleton3P)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					#$m=[regex]::Match($line, "^\s*\S*Template\S*\.(\S+\.\S*sound\S*|\S*sound\S*|\S+\.\S*animation\S*|\S*animation\S*|\S+\.\S*skeleton\S*|\S*skeleton\S*)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					$m=[regex]::Match($line, "^\s*ObjectTemplate\.(soundFilename|seatAnimationSystem|animationSystem|animationSystem1P|animationSystem3P|skeleton|skeleton1P|skeleton3P)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					If ($m.Groups.Count -eq 3) {
						$resRelPaths=@($m.Groups[2].value -split ",")
						for ($j=0; $j -lt $resRelPaths.Count; $j++) {
							$resRelPath=($resRelPaths[$j] -replace "`"","" -replace "/","\")
							#Write-Warning "$extractedFolder\$resRelPath"
							If ($resRelPath -ieq "->") {
								# Don't know what to do with variables...
								continue
							}
							$resFile=Join-Path $extractedFolder $resRelPath
							If (([System.IO.FileInfo]$resFile).Extension -ieq "") {
								# Don't know what to do with variables...
								continue
							}
							If (!(Test-Path -Path $resFile)) {
								Write-Warning "$resFile not found ($templateFile)"
							}
							$templateFiles+=,$resFile
						}
						continue
					}
					#$m=[regex]::Match($line, "^\s*ObjectTemplate.(vehicleHud|weaponHud|WarningHud|StrategicObject).(typeIcon|miniMapIcon|vehicleIcon|abilityIcon|spottedIcon|weaponIcon|altWeaponIcon|selectIcon|specialAbilityIcon|crosshairIcon|warningIcon|intactIcon|destroyedIcon)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					$m=[regex]::Match($line, "^\s*ObjectTemplate\.([^d]\S+\.[^u3h]\S*Icon)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					If ($m.Groups.Count -eq 3) {
						$resRelPaths=@($m.Groups[2].value -split ",")
						for ($j=0; $j -lt $resRelPaths.Count; $j++) {
							$resRelPath=($resRelPaths[$j] -replace "`"","" -replace "/","\")
							#Write-Warning "$extractedFolder\Menu\HUD\Texture\$resRelPath"
							$resFile=Join-Path "$extractedFolder\Menu\HUD\Texture" $resRelPath
							If ((([System.IO.FileInfo]$resFile).Extension -ine ".dds") -and (([System.IO.FileInfo]$resFile).Extension -ine ".tga")) {
								Write-Warning "Unexpected Icon: $resRelPath ($templateFile)"
								continue
							}
							#If (!(Test-Path -Path $resFile)) {
							#	Write-Warning "$resFile not found ($templateFile)"
							#}
							$templateFiles+=,$resFile
						}
						continue
					}
					# Animations (.inc) seem to only declare local "templates"...?
					# Textures (possibly called in meshes?)...?
					# Meshes can be anywhere...?
				}
			}
		}

		# End of any previous object...
		If ($null -ne $templateName) {
			If (($null -eq $searchedTemplateName) -or ("" -eq $searchedTemplateName)) {
				$sw.Write("$templateName;$templateType")
				foreach ($element in $templateChildren) {
					If (($null -ne $element) -and ("" -ne $element)) {
						$sw.Write(";$element")
					}
				}
				foreach ($element in $templateFiles) {
					If (($null -ne $element) -and ("" -ne $element)) {
						$sw.Write(";$element")
					}
				}
				$sw.WriteLine()
				$templateFile=$templateFiles[0]
				If ($bShowOutput) { Write-Output "$templateType $templateName ($templateFile)" }
			}
			ElseIf ($templateName -ieq $searchedTemplateName) {
				$templateFile=$templateFiles[0]
				If ($bShowOutput) { Write-Output "$templateType $templateName ($templateFile)" }
				$bFound=$true
				$lastChildrenFound=$templateChildren
				$lastFilesFound=$templateFiles
			}
		}

		If ($bUseCache) {
			$sw.close()
		}
	}
	Else {
		if (($null -eq $cachefile) -or !(Test-Path -Path $cachefile)) {
			Write-Error "Error: cache_db.csv not found, please try e.g. FindTemplate $extractedFolder $null to build it"
			return $null
		}
		#$regescbackslash=[regex]::Escape("\")
		#$regesc=[regex]::Escape($searchedTemplateName)
		$sr=[System.IO.StreamReader]$cachefile
		while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
			$line=$sr.ReadLine()
			$cols=($line -split ";")
			#$m=[regex]::Match($cols[0],"^$regesc$",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			#if ($m.Success) {
			If ($cols[0] -ieq $searchedTemplateName) {
				$templateType=$cols[1]
				$templateFile=$cols[2]
				$templateChildren=$null
				for ($i=2; $i -lt $cols.Count; $i++) {
					# Detect whether it is a child or file...
					#if ([regex]::Match($cols[$i],$regescbackslash,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success) {
					If ($cols[$i].Contains("\")) {
						break
					}
					$templateChild=$cols[$i]
					If (($null -ne $templateChild) -and ("" -ne $templateChild)) {
						$templateChildren+=,$templateChild
					}
				}
				$templateFiles=$null
				for (; $i -lt $cols.Count; $i++) {
					$templateFile=$cols[$i]
					If (($null -ne $templateFile) -and ("" -ne $templateFile)) {
						$templateFiles+=,$templateFile
					}
				}
				$templateFile=$templateFiles[0]
				If ($bShowOutput) { Write-Output "$templateType $searchedTemplateName ($templateFile)" }
				$bFound=$true
				$lastChildrenFound=$templateChildren
				$lastFilesFound=$templateFiles
			}
		}
		$sr.close()
	}
	If ($bFound) {
		If (($null -ne $templateChildren) -and ("" -ne $templateChildren)) {
			return $lastFilesFound+$templateChildren
		}
		Else {
			return $lastFilesFound
		}
	}
	Else {
		return $null
	}
}

function MergeTemplateMultipleDefinitions($extractedFolder,[bool]$bShowOutput=$true,[bool]$bShowExtendedOutput=$false) {

	if (($null -eq $extractedFolder) -or !(Test-Path -Path $extractedFolder)) {
		Write-Error "Error: Invalid parameter (objectsFolder)"
		return
	}
	$cachefile="$extractedFolder\cache_db.csv"
	if (($null -eq $cachefile) -or !(Test-Path -Path $cachefile)) {
		Write-Error "Error: cache_db.csv not found"
		return
	}

	$templateValidityList=$null
	$templateNameList=$null
	$templateTypeList=$null
	$templateChildrenList=$null
	$templateFilesList=$null

	#$regescbackslash=[regex]::Escape("\")
	$sr=[System.IO.StreamReader]$cachefile
	while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
		$line=$sr.ReadLine()
		$cols=($line -split ";")
		$templateName=$cols[0]
		$templateType=$cols[1]
		$templateFile=$cols[2]
		$templateChildren=$null
		for ($i=2; $i -lt $cols.Count; $i++) {
			# Detect whether it is a child or file...
			#if ([regex]::Match($cols[$i],$regescbackslash,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success) {
			If ($cols[$i].Contains("\")) {
				break
			}
			$templateChild=$cols[$i]
			If (($null -ne $templateChild) -and ("" -ne $templateChild)) {
				$templateChildren+=,$templateChild
			}
		}
		$templateFiles=$null
		for (; $i -lt $cols.Count; $i++) {
			$templateFile=$cols[$i]
			If (($null -ne $templateFile) -and ("" -ne $templateFile)) {
				$templateFiles+=,$templateFile
			}
		}
		$templateFile=$templateFiles[0]
		If ($bShowExtendedOutput) { Write-Output "$templateType $templateName ($templateFile)" }

		$templateValidityList+=,$true
		$templateNameList+=,$templateName
		$templateTypeList+=,$templateType
		$templateChildrenList+=,$templateChildren
		$templateFilesList+=,$templateFiles
	}
	$sr.close()

	$tmpcachefile="$extractedFolder\cache_db.csv.tmp"

	$sw=[System.IO.StreamWriter]$tmpcachefile
	for ($ii=0; $ii -lt $templateNameList.Count; $ii++) {
		If (!$templateValidityList[$ii]) { continue }
		$templateName=$templateNameList[$ii]
		$templateType=$templateTypeList[$ii]
		$templateChildren=$templateChildrenList[$ii]
		$templateFiles=$templateFilesList[$ii]

		# Search for further occurences of $templateName...
		#$regesc=[regex]::Escape($templateName)
		for ($j=$ii+1; $j -lt $templateNameList.Count; $j++) {
			If (!$templateValidityList[$j]) { continue }
			#$m=[regex]::Match($templateNameList[$j],"^$regesc$",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			#If ($m.Success) {
			If ($templateNameList[$j] -ieq $templateName) {
				$tmpTemplateType=$templateTypeList[$j]
				$tmpTemplateChildren=$templateChildrenList[$j]
				$tmpTemplateFiles=$templateFilesList[$j]
				If ($templateType -ine $tmpTemplateType) {
					Write-Warning "Multiple definitions of $templateName with a different type ($templateType vs. $tmpTemplateType)"
					$templateType=$tmpTemplateType
				}
				Else {
					If ($bShowOutput) { Write-Output "Multiple definitions of $templateType $templateName" }
				}
				If (($null -ne $tmpTemplateChildren) -and ("" -ne $tmpTemplateChildren)) {
					for ($k=0; $k -lt $tmpTemplateChildren.Count; $k++) {
						$tmpTemplateChild=$tmpTemplateChildren[$k]
						If (-not (($null -ne $templateChildren) -and ($templateChildren -icontains $tmpTemplateChild))) {
							$templateChildren+=,$tmpTemplateChild
						}
					}
				}
				If (($null -ne $tmpTemplateFiles) -and ("" -ne $tmpTemplateFiles)) {
					for ($k=0; $k -lt $tmpTemplateFiles.Count; $k++) {
						$tmpTemplateFile=$tmpTemplateFiles[$k]
						If (-not (($null -ne $templateFiles) -and ($templateFiles -icontains $tmpTemplateFile))) {
							$templateFiles+=,$tmpTemplateFile
						}
					}
				}
				$templateValidityList[$j]=$false
			}
		}

		$sw.Write("$templateName;$templateType")
		foreach ($element in $templateChildren) {
			If (($null -ne $element) -and ("" -ne $element)) {
				$sw.Write(";$element")
			}
		}
		foreach ($element in $templateFiles) {
			If (($null -ne $element) -and ("" -ne $element)) {
				$sw.Write(";$element")
			}
		}
		$sw.WriteLine()
		$templateFile=$templateFiles[0]
		#If ($bShowOutput) { Write-Output "$templateType $templateName ($templateFile)" }
	}
	$sw.close()

	If (-not (Test-Path -Path "$cachefile.bak")) {
		Move-Item -Path $cachefile -Destination "$cachefile.bak" -Force
	}
	Move-Item -Path $tmpcachefile -Destination $cachefile -Force
}

$callStackCounterFindTemplateDependencies=[int]0
#$alreadyProcessedTemplateNamesFindTemplateDependencies=$null # How to reset it properly when there are multiple function calls...?
function FindTemplateDependencies($extractedFolder,$searchedTemplateName,[bool]$bUseCache=$true,[int]$maxDependencyLevel=16,[ref]$alreadyProcessedTemplateNames) {

	$callStackCounterFindTemplateDependencies++
	#Write-Host "Begin FindTemplateDependencies $searchedTemplateName" -ForegroundColor Magenta

	$bWarnedSkipping=$false

	If (($null -ne $alreadyProcessedTemplateNames.value) -and ($alreadyProcessedTemplateNames.value -icontains $searchedTemplateName)) {
		$callStackCounterFindTemplateDependencies--
		#If ($callStackCounterFindTemplateDependencies -le 0) { $alreadyProcessedTemplateNames.value=$null }
		#Write-Host "End FindTemplateDependencies $searchedTemplateName" -ForegroundColor Magenta
		return $null
	}

	$ret=@(FindTemplate $extractedFolder $searchedTemplateName $false $bUseCache $false $false)
	#Write-Warning "$ret"
	If (($null -eq $ret) -or ("" -eq $ret)) {
		$callStackCounterFindTemplateDependencies--
		#If ($callStackCounterFindTemplateDependencies -le 0) { $alreadyProcessedTemplateNames.value=$null }
		#Write-Host "End FindTemplateDependencies $searchedTemplateName" -ForegroundColor Magenta
		return $null
	}
	$neededFile=$ret[0]
	If (($null -eq $neededFile) -or ("" -eq $neededFile)) {
		$callStackCounterFindTemplateDependencies--
		#If ($callStackCounterFindTemplateDependencies -le 0) { $alreadyProcessedTemplateNames.value=$null }
		#Write-Host "End FindTemplateDependencies $searchedTemplateName" -ForegroundColor Magenta
		return $null
	}
	#$regescbackslash=[regex]::Escape("\")
	$alreadyProcessedTemplateNames.value+=,$searchedTemplateName
	$neededFiles=,$neededFile
	#Write-Warning "$neededFile"
	for ($i=1; $i -lt $ret.Count; $i++) {
		# Detect whether it is a child or file...
		#if ([regex]::Match($ret[$i],$regescbackslash,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success) {
		If ($ret[$i].Contains("\")) {
			$neededFile=$ret[$i]
			If (-not (($null -ne $neededFiles) -and ($neededFiles -icontains $neededFile))) {
				$neededFiles+=$neededFile
			}
			#Write-Warning "$neededFile"
			continue
		}
		$templateChild=$ret[$i]
		#Write-Warning "$templateChild"
		If (($null -ne $templateChild) -and ("" -ne $templateChild)) {
			If ($searchedTemplateName -ieq $templateChild) {
				# Dependency loop...
				continue
			}
			If (($null -ne $alreadyProcessedTemplateNames.value) -and ($alreadyProcessedTemplateNames.value -icontains $templateChild)) {
				continue
			}
			If ($callStackCounterFindTemplateDependencies -ge $maxDependencyLevel) {
				If (!$bWarnedSkipping) { Write-Warning "FindTemplateDependencies: Skipping deep dependencies possibly due to dependency loop... ($searchedTemplateName)" }
				$bWarnedSkipping=$true
				#continue
				#Write-Warning "$neededFiles"
				$callStackCounterFindTemplateDependencies--
				#If ($callStackCounterFindTemplateDependencies -le 0) { $alreadyProcessedTemplateNames.value=$null }
				#Write-Host "End FindTemplateDependencies $searchedTemplateName" -ForegroundColor Magenta
				return $neededFiles
			}
			$neededChildFiles=@(FindTemplateDependencies $extractedFolder $templateChild $bUseCache $maxDependencyLevel ([ref]$alreadyProcessedTemplateNames.value))
			If (($null -ne $neededChildFiles) -and ("" -ne $neededChildFiles)) {
				for ($j=0; $j -lt $neededChildFiles.Count; $j++) {
					$neededChildFile=$neededChildFiles[$j]
					If (-not (($null -ne $neededFiles) -and ($neededFiles -icontains $neededChildFile))) {
						$neededFiles+=$neededChildFile
					}
					#Write-Warning "$neededChildFile"
				}
			}
			$alreadyProcessedTemplateNames.value+=$templateChild
		}
	}
	$callStackCounterFindTemplateDependencies--
	#If ($callStackCounterFindTemplateDependencies -le 0) { $alreadyProcessedTemplateNames.value=$null }
	#Write-Host "End FindTemplateDependencies $searchedTemplateName" -ForegroundColor Magenta
	#Write-Warning "$neededFiles"
	return $neededFiles
}

#FindFileDependencies $extractFolder $file $true 16 $false
$callStackCounterFindFileDependencies=[int]0
$alreadyProcessedFilesFindFileDependencies=$null # How to reset it properly when there are multiple function calls...?
function FindFileDependencies($extractedFolder,$file,[bool]$bUseCache=$true,[int]$maxDependencyLevel=16,[bool]$bDisableSharedCallsMemory=$true,[ref]$alreadyProcessedFiles=([ref]$alreadyProcessedFilesFindFileDependencies)) {

	$callStackCounterFindFileDependencies++
	#Write-Host "Begin FindFileDependencies $file" -ForegroundColor Magenta

	$bWarnedSkipping=$false

	If ($bDisableSharedCallsMemory) { $alreadyProcessedFiles.value=$null }

	If (($null -ne $alreadyProcessedFiles.value) -and ($alreadyProcessedFiles.value -icontains $file)) {
		$callStackCounterFindFileDependencies--
		#Write-Host "End FindFileDependencies $file" -ForegroundColor Magenta
		return $null
		#return $file
	}
	If (-not (Test-Path -Path $file)) {
		$neededFiles=,$file
		If (!$bDisableSharedCallsMemory) { $alreadyProcessedFiles.value+=,$file }
		$callStackCounterFindFileDependencies--
		#Write-Host "End FindFileDependencies $file" -ForegroundColor Magenta
		##Write-Error "Error: $file not found"
		##Write-Warning "$neededFiles"
		return $neededFiles
	}
	If ((([System.IO.FileInfo]$file).Extension -ieq ".bundledmesh") -or (([System.IO.FileInfo]$file).Extension -ieq ".skinnedmesh") -or (([System.IO.FileInfo]$file).Extension -ieq ".staticmesh")) {
		$neededFiles=,$file
		If (!$bDisableSharedCallsMemory) { $alreadyProcessedFiles.value+=,$file }
		$regexpr="(objects\p{IsBasicLatin}+\.dds[^oc]|common\p{IsBasicLatin}+\.dds[^oc]|objects\p{IsBasicLatin}+\.tga[^oc]|common\p{IsBasicLatin}+\.tga[^oc])"
		$m=[regex]::Matches(([System.IO.File]::ReadAllText($file)),$regexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		If ($null -ne $m) {
			for ($i=0; $i -lt $m.Count; $i++) {
				#"$($m[$i])"
				$tmp=@($m[$i] -split "\.(dds|tga)[^oc]") -creplace "[\n\r\0]"
				#"$tmp"
				for ($j=0; $j -lt $tmp.Count; $j+=2) {
					If (($null -ne $tmp[$j]) -and ("" -ne $tmp[$j]) -and ($null -ne $tmp[$j+1]) -and ("" -ne $tmp[$j+1])) {
						#"$($tmp[$j]).$($tmp[$j+1])"
						$resRelPath=("$($tmp[$j]).$($tmp[$j+1])" -replace "`"","" -replace "/","\")
						#Write-Warning "$extractedFolder\$resRelPath"
						$neededFile=Join-Path $extractedFolder $resRelPath
						If (($null -ne $neededFiles) -and ($neededFiles -icontains $neededFile)) {
							continue
						}
						If (($null -ne $alreadyProcessedFiles.value) -and ($alreadyProcessedFiles.value -icontains $neededFile)) {
							continue
						}
						$neededFiles+=$neededFile
						If (!$bDisableSharedCallsMemory) { $alreadyProcessedFiles.value+=$neededFile }
						#Write-Host "$neededFile" -ForegroundColor White
					}
				}
			}
		}
		$callStackCounterFindFileDependencies--
		#Write-Host "End FindFileDependencies $file" -ForegroundColor Magenta
		##Write-Warning "$neededFiles"
		return $neededFiles
	}
	If ((([System.IO.FileInfo]$file).Extension -ine ".con") -and (([System.IO.FileInfo]$file).Extension -ine ".tweak") -and (([System.IO.FileInfo]$file).Extension -ine ".ai") -and (([System.IO.FileInfo]$file).Extension -ine ".inc")) {
		$neededFiles=,$file
		If (!$bDisableSharedCallsMemory) { $alreadyProcessedFiles.value+=,$file }
		$callStackCounterFindFileDependencies--
		#Write-Host "End FindFileDependencies $file" -ForegroundColor Magenta
		##Write-Error "Error: $file has unsupported extension"
		##Write-Warning "$neededFiles"
		return $neededFiles
	}

	$neededFiles=,$file
	If (!$bDisableSharedCallsMemory) { $alreadyProcessedFiles.value+=,$file }
	$processedTemplateDependencies=$null

	# Here we need to keep include and run statements...

	#iii=0
	#$concontent=(PreProcessIfConContent (PreProcessVarsConContent (PreProcessConstsConContent (PreProcessCommentsConContent (ReadConFile $file) "cbInsideCommentLine" "cbOutsideCommentLine"))) ([ref]$iii) "cbConditionCode" "cbOtherCode" "cbInsideTrueCondition" "cbInsideFalseCondition")# -replace "\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n\s*\r?\n","`r`n"
	$concontent=(PreProcessVarsConContent (PreProcessConstsConContent (PreProcessCommentsConContent (ReadConFile $file) "cbInsideCommentLine" "cbOutsideCommentLine")))# -replace "\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n\s*\r?\n","`r`n"

	$lines=@($concontent -split "\r?\n")
	for ($i=0; $i -lt $lines.Count; $i++) {
		$line=$lines[$i]
		##Write-Warning "$line"

		$templateDependency=$null
		$templateDependencyFile=$null

		$m=[regex]::Match($line, "^\s*(ObjectTemplate\S*|aiTemplate\S*|weaponTemplate\S*)\.(create|active|activeSafe)\s+(\S+)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		If ($m.Groups.Count -eq 5) {
			$templateDependency=$m.Groups[4].value
		}
		Else {
			$m=[regex]::Match($line, "^\s*(ObjectTemplate\S*|aiTemplate\S*|weaponTemplate\S*)\.(create|active|activeSafe)\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			If ($m.Groups.Count -eq 4) {
				$templateDependency=$m.Groups[3].value
			}
			Else {
				$m=[regex]::Match($line, "^\s*animationSystem\.createAnimation\s+(\S+)\s*",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
				If ($m.Groups.Count -eq 2) {
					$resRelPath=($m.Groups[1].value -replace "`"","" -replace "/","\")
					#Write-Warning "$extractedFolder\$resRelPath"
					$templateDependencyFile=Join-Path $extractedFolder $resRelPath
				}
				Else {
					$templateDependencyFile=GetFileIncludedConLine $line $file
					If ($null -eq $templateDependencyFile) {
						$templateDependencyFile=GetFileRunConLine $line $file
						If ($null -eq $templateDependencyFile) {
							continue
						}
					}
				}
			}
		}

		If ($null -ne $templateDependencyFile) {
			If (($null -ne $neededFiles) -and ($neededFiles -icontains $templateDependencyFile)) {
				continue
			}
			If (($null -ne $alreadyProcessedFiles.value) -and ($alreadyProcessedFiles.value -icontains $templateDependencyFile)) {
				continue
			}
			If ($callStackCounterFindFileDependencies -ge $maxDependencyLevel) {
				If (-not (($null -ne $neededFiles) -and ($neededFiles -icontains $templateDependencyFile))) {
					$neededFiles+=$templateDependencyFile
				}
				#Write-Host "$templateDependencyFile" -ForegroundColor White
				If (!$bWarnedSkipping) { Write-Warning "FindFileDependencies: Skipping deep dependencies possibly due to dependency loop... ($file)" }
				$bWarnedSkipping=$true
				continue
				###Write-Warning "$neededFiles"
				#$callStackCounterFindFileDependencies--
				##Write-Host "End FindFileDependencies $file" -ForegroundColor Magenta
				#return $neededFiles
			}
			$ret=@(FindFileDependencies $extractedFolder $templateDependencyFile $bUseCache $maxDependencyLevel $bDisableSharedCallsMemory ([ref]$alreadyProcessedFiles.value))
			#Write-Host "$ret" -ForegroundColor DarkGreen
			If (($null -eq $ret) -or ("" -eq $ret)) {
				Write-Warning "Internal error while processing file $templateDependencyFile"
				continue
			}
			for ($k=0; $k -lt $ret.Count; $k++) {
				$neededFile=$ret[$k]
				If (($null -ne $neededFile) -and ("" -ne $neededFile)) {
					If (($null -ne $neededFiles) -and ($neededFiles -icontains $neededFile)) {
						continue
					}
					If (($null -ne $alreadyProcessedFiles.value) -and ($alreadyProcessedFiles.value -icontains $neededFile)) {
						continue
					}
					$neededFiles+=$neededFile
					If (!$bDisableSharedCallsMemory) { $alreadyProcessedFiles.value+=$neededFile }
					#Write-Host "$neededFile" -ForegroundColor White
				}
				Else {
					Write-Warning "File $templateDependencyFile has invalid dependencies"
				}
			}
			continue
		}

		#Write-Host "$templateDependency" -ForegroundColor White

		If (($null -ne $processedTemplateDependencies) -and ($processedTemplateDependencies -icontains $templateDependency)) {
			continue
		}
		$retj=@(FindTemplateDependencies -extractedFolder $extractedFolder -searchedTemplateName $templateDependency -bUseCache $bUseCache -alreadyProcessedTemplateNames ([ref]$processedTemplateDependencies))
		#Write-Host "$retj" -ForegroundColor Green
		If (($null -eq $retj) -or ("" -eq $retj)) {
			Write-Warning "Template $templateDependency not found"
			continue
		}
		for ($j=0; $j -lt $retj.Count; $j++) {
			$templateDependencyFile=$retj[$j]
			If (($null -ne $templateDependencyFile) -and ("" -ne $templateDependencyFile)) {
				If (($null -ne $neededFiles) -and ($neededFiles -icontains $templateDependencyFile)) {
					continue
				}
				If (($null -ne $alreadyProcessedFiles.value) -and ($alreadyProcessedFiles.value -icontains $templateDependencyFile)) {
					continue
				}
				If ($callStackCounterFindFileDependencies -ge $maxDependencyLevel) {
					If (-not (($null -ne $neededFiles) -and ($neededFiles -icontains $templateDependencyFile))) {
						$neededFiles+=$templateDependencyFile
					}
					#Write-Host "$templateDependencyFile" -ForegroundColor White
					If (!$bWarnedSkipping) { Write-Warning "FindFileDependencies: Skipping deep dependencies possibly due to dependency loop... ($templateDependency)" }
					$bWarnedSkipping=$true
					continue
					###Write-Warning "$neededFiles"
					#$callStackCounterFindFileDependencies--
					##Write-Host "End FindFileDependencies $file" -ForegroundColor Magenta
					#return $neededFiles
				}
				$ret=@(FindFileDependencies $extractedFolder $templateDependencyFile $bUseCache $maxDependencyLevel $bDisableSharedCallsMemory ([ref]$alreadyProcessedFiles.value))
				#Write-Host "$ret" -ForegroundColor DarkGreen
				If (($null -eq $ret) -or ("" -eq $ret)) {
					Write-Warning "Internal error while processing file $templateDependencyFile"
					continue
				}
				for ($k=0; $k -lt $ret.Count; $k++) {
					$neededFile=$ret[$k]
					If (($null -ne $neededFile) -and ("" -ne $neededFile)) {
						If (($null -ne $neededFiles) -and ($neededFiles -icontains $neededFile)) {
							continue
						}
						If (($null -ne $alreadyProcessedFiles.value) -and ($alreadyProcessedFiles.value -icontains $neededFile)) {
							continue
						}
						$neededFiles+=$neededFile
						If (!$bDisableSharedCallsMemory) { $alreadyProcessedFiles.value+=$neededFile }
						#Write-Host "$neededFile" -ForegroundColor White
					}
					Else {
						Write-Warning "File $templateDependencyFile has invalid dependencies"
					}
				}
			}
			Else {
				Write-Warning "Template $templateDependency has invalid dependencies"
			}
		}
		$processedTemplateDependencies+=,$templateDependency
	}

	$callStackCounterFindFileDependencies--
	#Write-Host "End FindFileDependencies $file" -ForegroundColor Magenta
	##Write-Warning "$neededFiles"
	return $neededFiles
}

#. .\mod_installer.ps1
#$modFolder="U:\Progs\EA Games\Battlefield 2 AIX2 Reality\mods\xpack"
#$extractFolder="$modFolder\extracted"
#ExtractModArchives $modFolder $extractFolder $false $false 1
#FindTemplate $extractFolder $null $false $true $false $false
#$vehicleToExtract="Objects\Vehicles\Land\aav_tunguska\aav_tunguska.con"
#$file=(Get-Item "$modFolder\extracted\$vehicleToExtract").FullName
#$exportFolder="$modFolder\export"
#ListDependencies $file $extractFolder $exportFolder $true $true $false $null $false $null $false $true $false -1
# $extractedFolder should correspond to the mod where the vehicle comes from, while $bf2ExtractedFolder can be set to the mod where the vehicle should be used (which is typically standard bf2 without modifications).
# If $bf2ExtractedFolder is set, the vehicle dependencies will be split in separate folders, typically "export" folder for the dependencies that are not available in $bf2ExtractedFolder, "export_bf2" folder for those that are already in $bf2ExtractedFolder, "export_bf2_modified" folder for those that are modifications of existing files in $bf2ExtractedFolder. The files in "export_bf2_modified" folder might need to be manually modified since they might break existing functionalities in $bf2ExtractedFolder.
# $xpackExtractedFolder is for advanced use, to get more details on where the different dependencies come from.
function ListDependencies($file,$extractedFolder,$exportFolder=$null,[bool]$bUseCache=$true,[bool]$bHideDefinitionsInCurrentConOrTweak=$true,[bool]$bHideDefinitionsInBf2=$false,$bf2ExtractedFolder=$null,[bool]$bHideDefinitionsInXpack=$false,$xpackExtractedFolder=$null,[bool]$bPreProcessVehicles=$true,[bool]$bAllowExtraFiles=$true,[bool]$bAlwaysCopyContainingFolder=$true,[int]$maxDependencyLevel=16) {

	If (($null -eq $extractedFolder) -or !(Test-Path -Path $extractedFolder)) {
		Write-Error "Error: Invalid parameter (extractedFolder)"
		return
	}
	If (($null -eq $bf2ExtractedFolder) -or !(Test-Path -Path $bf2ExtractedFolder)) {
		$bf2ExtractedFolder=$null
		Write-Warning  "bf2ExtractedFolder parameter not available"
	}
	If (($null -eq $xpackExtractedFolder) -or !(Test-Path -Path $xpackExtractedFolder)) {
		$xpackExtractedFolder=$null
		Write-Warning  "xpackExtractedFolder parameter not available"
	}

			$alreadyProcessedFiles=$null
			$ret=@(FindFileDependencies $extractedFolder $file $bUseCache $maxDependencyLevel $false ([ref]$alreadyProcessedFiles))
			$alreadyProcessedFiles=$null
			#"$ret"
			If (($null -eq $ret) -or ("" -eq $ret)) {
				Write-Error "Internal error while processing file $file"
				return
			}

			for ($k=0; $k -lt $ret.Count; $k++) {
				$neededFile=$ret[$k]
				If (($null -ne $neededFile) -and ("" -ne $neededFile)) {
					# Sometimes textures might not have the correct extension...
					# Also, FindTemplate has some limitations...
					If (!(Test-Path -Path $neededFile)) {
						$origNeededFile=$neededFile
						If (([System.IO.FileInfo]$origNeededFile).Extension -ieq ".tga") {
							$neededFile=($origNeededFile -replace [regex]::Escape(".tga"),".dds")
						}
						ElseIf (([System.IO.FileInfo]$origNeededFile).Extension -ieq ".collisionmesh") {
							Get-ChildItem -Path $extractedFolder -Filter ([System.IO.FileInfo]$neededFile).Name -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object {
								$neededFile=$_.FullName
							}
						}
						ElseIf ((([System.IO.FileInfo]$origNeededFile).Extension -ieq ".bundledmesh") -or (([System.IO.FileInfo]$origNeededFile).Extension -ieq ".skinnedmesh") -or (([System.IO.FileInfo]$origNeededFile).Extension -ieq ".staticmesh")) {
							$neededFile=($origNeededFile -replace [regex]::Escape(([System.IO.FileInfo]$origNeededFile).Extension),".bundledmesh")
							Get-ChildItem -Path $extractedFolder -Filter ([System.IO.FileInfo]$neededFile).Name -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object {
								$neededFile=$_.FullName
							}
							If (!(Test-Path -Path $neededFile)) {
								$neededFile=($origNeededFile -replace [regex]::Escape(([System.IO.FileInfo]$origNeededFile).Extension),".skinnedmesh")
								Get-ChildItem -Path $extractedFolder -Filter ([System.IO.FileInfo]$neededFile).Name -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object {
									$neededFile=$_.FullName
								}
								If (!(Test-Path -Path $neededFile)) {
									$neededFile=($origNeededFile -replace [regex]::Escape(([System.IO.FileInfo]$origNeededFile).Extension),".staticmesh")
									Get-ChildItem -Path $extractedFolder -Filter ([System.IO.FileInfo]$neededFile).Name -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object {
										$neededFile=$_.FullName
									}
								}
							}
						}
						If (!(Test-Path -Path $neededFile)) {
							Write-Error "Error: $origNeededFile not found"
							continue
						}
						Else {
							Write-Warning "$origNeededFile not found but $neededFile found"
						}
					}
					# Should remove $extractedFolder from the path in $neededFile and add the rest at the end of the desired folder...
					$neededDirectory=(Get-Item $neededFile).DirectoryName
					$regesc=[regex]::Escape($extractedFolder)
					$m=[regex]::Match($neededFile, "$regesc\\?(.+)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
					$restOfPath=$m.Groups[1].value
					#"$restOfPath"
					$exportFolderSuffix=""
					$bAlreadyDefinedInXpack=$false
					$bAlreadyDefinedInXpackButModified=$false
					If ($null -ne $xpackExtractedFolder) {
						$xpackNeededFile=[System.IO.Path]::Combine($xpackExtractedFolder,$restOfPath)
						#"$xpackNeededFile"
						#$bAlreadyDefinedInXpack=([regex]::Match($neededDirectory, [regex]::Escape("mods\xpack\"),[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success -or (Test-Path -Path $xpackNeededFile))
						#$bAlreadyDefinedInXpackButModified=((Test-Path -Path $xpackNeededFile) -and ((Get-FileHash $neededFile).hash -ne (Get-FileHash $xpackNeededFile).hash))
						$bAlreadyDefinedInXpack=(Test-Path -Path $xpackNeededFile)
						$bAlreadyDefinedInXpackButModified=($bAlreadyDefinedInXpack -and ((Get-FileHash $neededFile).hash -ne (Get-FileHash $xpackNeededFile).hash))
						If ($bAlreadyDefinedInXpack) {
							$exportFolderSuffix="_xpack"
						}
						If ($bAlreadyDefinedInXpackButModified) {
							$exportFolderSuffix="_xpack_modified"
						}
					}
					$bAlreadyDefinedInBf2=$false
					$bAlreadyDefinedInBf2ButModified=$false
					If ($null -ne $bf2ExtractedFolder) {
						$bf2NeededFile=[System.IO.Path]::Combine($bf2ExtractedFolder,$restOfPath)
						#"$bf2NeededFile"
						#$bAlreadyDefinedInBf2=([regex]::Match($neededDirectory,[regex]::Escape("mods\bf2\"),[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success -or (Test-Path -Path $bf2NeededFile))
						#$bAlreadyDefinedInBf2ButModified=((Test-Path -Path $bf2NeededFile) -and ((Get-FileHash $neededFile).hash -ne (Get-FileHash $bf2NeededFile).hash))
						$bAlreadyDefinedInBf2=(Test-Path -Path $bf2NeededFile)
						$bAlreadyDefinedInBf2ButModified=($bAlreadyDefinedInBf2 -and ((Get-FileHash $neededFile).hash -ne (Get-FileHash $bf2NeededFile).hash))
						If ($bAlreadyDefinedInBf2) {
							$exportFolderSuffix="_bf2"
						}
						If ($bAlreadyDefinedInBf2ButModified) {
							$exportFolderSuffix="_bf2_modified"
						}
					}
					If ((!$bHideDefinitionsInBf2 -or !$bAlreadyDefinedInBf2 -or $bAlreadyDefinedInBf2ButModified) -and (!$bHideDefinitionsInXpack -or !$bAlreadyDefinedInXpack -or $bAlreadyDefinedInXpackButModified)) {
						If ((!$bHideDefinitionsInCurrentConOrTweak) -or ([System.IO.Path]::Combine((Get-Item $file).DirectoryName,(Get-Item $file).Basename) -ne [System.IO.Path]::Combine($neededDirectory,(Get-Item $neededFile).Basename))) {
							#Write-Output "Template $templateDependency needs $neededFile"
							Write-Output "$neededFile"
						}
						If (($null -ne $exportFolder) -and ("" -ne $exportFolder)) {
							New-Item "$exportFolder$exportFolderSuffix" -ItemType directory -Force | Out-Null
							# Should check more in details any additional file if it is already in bf2/xpack...
							If ($bAllowExtraFiles -and ((Get-Item $neededDirectory).Basename -ieq "meshes") -and ((Get-Item "$neededDirectory\..").Basename -ieq (Get-Item $neededFile).Basename)) {
								$m=[regex]::Match("$neededDirectory\..", "$regesc\\?(.+)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
								$restOfPath=$m.Groups[1].value
								#"$restOfPath"
								$exportNeededDirectory=[System.IO.Path]::Combine("$exportFolder$exportFolderSuffix",$restOfPath)
								#"$exportNeededDirectory"
								New-Item "$exportNeededDirectory" -ItemType directory -Force | Out-Null
								Copy-Item -Path $neededDirectory\..\* -Destination $exportNeededDirectory -Force -Recurse
								If ($bPreProcessVehicles) {
									PreProcessVehicles $neededDirectory $exportNeededDirectory $true $true $true $false $false
								}
							}
							ElseIf ($bAllowExtraFiles -and ($bAlwaysCopyContainingFolder -or ((Get-Item $neededDirectory).Basename -ieq (Get-Item $neededFile).Basename))) {
								$m=[regex]::Match($neededDirectory, "$regesc\\?(.+)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
								$restOfPath=$m.Groups[1].value
								#"$restOfPath"
								$exportNeededDirectory=[System.IO.Path]::Combine("$exportFolder$exportFolderSuffix",$restOfPath)
								#"$exportNeededDirectory"
								New-Item "$exportNeededDirectory" -ItemType directory -Force | Out-Null
								Copy-Item -Path $neededDirectory\* -Destination $exportNeededDirectory -Force -Recurse
								If ($bPreProcessVehicles) {
									PreProcessVehicles $neededDirectory $exportNeededDirectory $true $true $true $false $false
								}
							}
							Else {
								If ($bAllowExtraFiles) {
									$neededFileWithoutExtension=[System.IO.Path]::Combine($neededDirectory,(Get-Item $neededFile).Basename)
									$neededFiles=Get-ChildItem "$neededFileWithoutExtension.*"
								}
								Else {
									$neededFiles=Get-ChildItem $neededFile
								}
								$neededFiles | ForEach-Object {
									$nf=$_.FullName
									$m=[regex]::Match($nf, "$regesc\\?(.+)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
									$restOfPath=$m.Groups[1].value
									#"$restOfPath"
									$exportNeededFile=[System.IO.Path]::Combine("$exportFolder$exportFolderSuffix",$restOfPath)
									#"$exportNeededFile"
									$exportNeededDirectory=([System.IO.FileInfo]$exportNeededFile).DirectoryName
									New-Item $exportNeededDirectory -ItemType directory -Force | Out-Null
									Copy-Item -Path $nf -Destination $exportNeededFile -Force -Recurse
									If ($bPreProcessVehicles) {
										PreProcessVehicles $nf $exportNeededDirectory $true $true $true $false $false
									}
								}
							}
						}
					}
				}
				Else {
					#Write-Warning "Template $templateDependency not found"
					Write-Warning "File $file has invalid dependencies"
				}
			}

}

#. .\mod_installer.ps1
#SplitToServerAndClientFolders C:\Users\Administrator\Downloads\Objects C:\Users\Administrator\Downloads\Objects_server C:\Users\Administrator\Downloads\Objects_client
function SplitToServerAndClientFolders($originalFolder,$serverFolder,$clientFolder,[bool]$bOverwrite=$false) {

	if (($null -eq $originalFolder) -or !(Test-Path -Path $originalFolder)) {
		Write-Error "Error: Invalid parameter ($originalFolder)"
		return
	}
	#New-Item "$serverFolder" -ItemType directory -Force | Out-Null
	#New-Item "$clientFolder" -ItemType directory -Force | Out-Null

	# Directory structures containing .tweak and .con, meshes\*.collisionmesh, ai\*.ai are copied to server...
	# Directory structures containing meshes\*.bundledmesh, meshes\*.skinnedmesh, meshes\*.staticmesh, Textures are copied to client...
	# How to correct wrong directory structures...
	# Objects vs Menu...

	$serverFiles=Get-ChildItem "$originalFolder\*" -R -Include *.tweak,*.con,*.ai,*.inc,*.tweak.bak,*.con.bak,*.ai.bak,*.inc.bak,*.ske,*.baf,*.tai,*.desc,*.txt,*.collisionmesh
	$clientFiles=Get-ChildItem "$originalFolder\*" -R -Exclude *.tweak,*.con,*.ai,*.inc,*.tweak.bak,*.con.bak,*.ai.bak,*.inc.bak,*.ske,*.baf,*.tai,*.desc,*.txt,*.collisionmesh

	$serverFiles | ForEach-Object {
		$file=$_.FullName
		#"$file"
		If (-not (Test-Path -Path "$file" -PathType Container)) {
			$regesc=[regex]::Escape($originalFolder)
			$m=[regex]::Match($file, "$regesc\\?(.+)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			$restOfPath=$m.Groups[1].value
			#"$restOfPath"
			$newPath=[System.IO.Path]::Combine($serverFolder,$restOfPath)
			#"$newPath"
			New-Item (split-path -parent $newPath) -ItemType directory -Force | Out-Null
			If ($bOverwrite) {
				Move-Item -Path "$file" -Destination "$newPath" -Force
			}
			Else {
				Move-Item -Path "$file" -Destination "$newPath"
			}
		}
	}
	$clientFiles | ForEach-Object {
		$file=$_.FullName
		#"$file"
		If (-not (Test-Path -Path "$file" -PathType Container)) {
			$regesc=[regex]::Escape($originalFolder)
			$m=[regex]::Match($file, "$regesc\\?(.+)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			$restOfPath=$m.Groups[1].value
			#"$restOfPath"
			$newPath=[System.IO.Path]::Combine($clientFolder,$restOfPath)
			#"$newPath"
			New-Item (split-path -parent $newPath) -ItemType directory -Force | Out-Null
			If ($bOverwrite) {
				Move-Item -Path "$file" -Destination "$newPath" -Force
			}
			Else {
				Move-Item -Path "$file" -Destination "$newPath"
			}
		}
	}
}

#function ExtractVehicles($downloadsFolder,$extractFolder,$modFolder,[bool]$bSeparateServerClient=$true,[bool]$bFixVehicleHudNameInconsistencies=$false,[bool]$bFixVehicleTypeInconsistencies=$false,[bool]$bConfirmEachFix=$false) {

	#$modFolder optional, would be to check the existence of includes...
	#if downloadsFolder empty, only use modFolder and use Server/ClientArchives.con

	#$bSeparateServerClient: Objects, Menu folders or Objects_server, Objects_client, etc.

	# TODO: There might be other archives inside the archives, and their extracted name might conflict with existing folders...

	#Get-ChildItem "$downloadsFolder\*" -R -Include *.zip,*.rar,*.7z | ForEach-Object {
	#	& 7z x -y $_.FullName `-o"$($_.DirectoryName)/$($_.Basename)"

		#first assume it follows std dir struct of objects_server/client.zip

		#first should find a .tweak which appears to correspond to a vehicle by checking its content...
		#then in its folder there should be a .con and potentially other .tweak and .con for subparts, as well as ai, meshes, textures, sound folders
		#.con, .tweak, ai should go to server, textures, sound to client. Directory structure?: vehicles\???\vehicleName?
		#should look for any remaining .dds, .tga which might be necessary for Menu... Should read vehicleName.tweak and check for menuicon, etc.
		#effects\vehicles...
		# meshes folder should be copied to server, and its sudirectory structure copied to client with only the .bundlemesh

	#}





	#use vehicleHudName to correct killname...

	#parses and get includes (including  menuincon to put in correct folder, etc.) to help extracting from other mods


#}

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

#Check xpack and bf2 existence...
#FindAllVehicles, check ServerArchives.con, fileManager.mountArchive XXX.zip Objects, if mods/bf2/Objects_server.zip or mods/xpack/Objects_server.zip, should make a copy of the .tweak and add the ref to the new efserv.zip, vehserv.zip, stsgarageserv.zip in ServerArchives.con

#Use git to create a repo and make commits inside...

#function AddNewVehicle($vehicleName, $vehicleType, $vehicleTeams, $downloadLink, $homePage=$null, $wiki=$null, $preCustomScript=$null, $postCustomScript=$null) {
#	$preCustomScript

#	#first should try to download directly from $downloadLink (how to get wget error code?), if it fails assumes it is moddb, how to do without ie...

#	# or if not easy to download auto, ask to manually download and gather in a folder, then extract all *.zip,*.rar,*.7z...

#	$ie = new-object -ComObject InternetExplorer.Application
#	$ie.Navigate($downloadLink)
#	$ln=$IE.Document.getElementsByTagName('a') | Where-Object {$_.href -match "/addons/start"}
#	$ie.Navigate($ln.IHTMLAnchorElement_href)
#	$ln=$IE.Document.getElementsByTagName('a') | Where-Object {$_.href -match "/downloads/mirror"}
#	$downloadLink=$ln.IHTMLAnchorElement_href

#	Invoke-WebRequest $downloadLink -UseBasicParsing -OutFile "C:\tmp\download.zip"
#	& 7z x -y "C:\tmp\download.zip" `-o"C:\tmp\download"
#	Get-ChildItem "C:\tmp\download\*" -R -Include *.zip,*.rar,*.7z | ForEach-Object {
#		& 7z x -y $_.FullName `-o"$($_.DirectoryName)/$($_.Basename)"
#		Remove-Item $_.FullName
#	}

##search for .bundlemesh, .collisionmesh, .tweak, .con, then move sounds
#	#sometimes also there are weapons, effects, for that use $postCustomScript?...
#	$postCustomScript
#}

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

#function SetLevelTeams($team1, $team2) {
#Levels\Gulf_of_Oman\server\Init.con 
#}
