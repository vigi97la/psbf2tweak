# DO NOT USE, TEMPORARY

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

function ReadConFileAndStripRem($file) {
	$content=""
	$remregexpr="^\s*rem\s+(.*)\s*" # To skip lines beginning with a comment.
	$beginremregexpr="^\s*beginrem\s*" # To skip block comments.
	$endremregexpr="^\s*endrem\s*" # To skip block comments.
	$bInsideBlockComment=$false
	$sr=[System.IO.StreamReader]$file
	while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
		$line=$sr.ReadLine()
		if ($bInsideBlockComment) {
			$m=[regex]::Match($line, $endremregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			if ($m.Success) {
				$bInsideBlockComment=$false
				Continue
			}
			Continue
		}
		$m=[regex]::Match($line, $remregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		if ($m.Success) {
			Continue
		}
		$m=[regex]::Match($line, $beginremregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		if ($m.Success) {
			$bInsideBlockComment=$true
			Continue
		}
		$content+=$line+"`r`n"
	}
	$sr.close()
	return $content
}

# Not finished...
function ReadConFileAndStripFalseIf($file) {
	$content=""
	$ifregexpr="^\s*if\s*" # Should add groups to check condition.......................
	$elseregexpr="^\s*else\s*"
	$endifregexpr="^\s*endIf\s*"
	$bInsideIf=$false
	$sr=[System.IO.StreamReader]$file
	while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
		$line=$sr.ReadLine()
		if ($bInsideIf) {
			$m=[regex]::Match($line, $ifregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
			if ($m.Success) {
				$bInsideIf=$false
				Continue
			}
			Continue
		}
		$m=[regex]::Match($line, $endifregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		if ($m.Success) {
			$bInsideIf=$true
			Continue
		}
		$content+=$line+"`r`n"
	}
	$sr.close()
	return $content
}

function ReadConFileWithArg($file, $v_arg1, $v_arg2, $v_arg3, $v_arg4, $v_arg5, $v_arg6, $v_arg7, $v_arg8, $v_arg9) {
	$content=""
	$sr=[System.IO.StreamReader]$file
	while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
		$line=$sr.ReadLine()
		$line=$line -replace "v_arg1","`"$v_arg1`""
		$line=$line -replace "v_arg2","`"$v_arg2`""
		$line=$line -replace "v_arg3","`"$v_arg3`""
		$line=$line -replace "v_arg4","`"$v_arg4`""
		$line=$line -replace "v_arg5","`"$v_arg5`""
		$line=$line -replace "v_arg6","`"$v_arg6`""
		$line=$line -replace "v_arg7","`"$v_arg7`""
		$line=$line -replace "v_arg8","`"$v_arg8`""
		$line=$line -replace "v_arg9","`"$v_arg9`""
		$content+=$line+"`r`n"
	}
	$sr.close()
	return $content
}

function ReadConFileAndProcessIncludes($file) {
	$content=""

	# ...


	$content | Set-Content $file.tmp
}

function ProcessVehicles($objectsFolder, [bool]$bIncludeStationaryWeapons=$false, [bool]$bIncludeAll=$false) {

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

			Write-Output "$file : $vehicleName"

			$remregexpr="^\s*rem\s+(.*)\s*" # To skip lines beginning with a comment.
			$sr=[System.IO.StreamReader]$file
			$sw=[System.IO.StreamWriter]"$file.tmp"
			while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
				$line=$sr.ReadLine()
				$m=[regex]::Match($line, $remregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
				if ($m.Success) {
					$sw.WriteLine($line)
					Continue
				}
				$m=[regex]::Match($line, "^\s*include\s+(\S+)(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?\s*")
				if ($m.Groups.Count -ge 2) {
					$includedfile=$m.Groups[1].value
										
					# should get args and process included file...

					# For aix2_reality...
					$v_arg1=$m.Groups[3].value
					$v_arg2=$m.Groups[5].value
					$v_arg3=$m.Groups[7].value
					$v_arg4=$m.Groups[9].value
					$v_arg5=$m.Groups[11].value
					$v_arg6=$m.Groups[13].value
					$v_arg7=$m.Groups[15].value
					$v_arg8=$m.Groups[17].value
					$v_arg9=$m.Groups[19].value
					$includedfilecontent=ReadConFileWithArg $includedfile $v_arg1 $v_arg2 $v_arg3 $v_arg4 $v_arg5 $v_arg6 $v_arg7 $v_arg8 $v_arg9

					# $includedfilecontent might have other includes...


					#if ("" -eq $v_arg1) {
					#	$sw.Write([System.IO.File]::ReadAllText($includedfile))
					#	Continue
					#}
					#if ("" -eq $v_arg2) {
						
					#	#should open includedfile and look inside for If/elseIf v_arg1 == "$v_arg1" and get the lines until else or elseIf or endIf


					#	$sw.Write([System.IO.File]::ReadAllText($includedfile))
					#	Continue
					#}

					#should open includedfile_without_extension/$varg_1.tweak and look inside for v_arg1 == "$v_arg1" and get the lines until else or elseIf or endIf



					#for ($i=2; $i -lt $m.Groups.Count; $i+=2) {
					#	$param=$m.Groups[$i+1].value
					#	$j=$i/2
					#	if ("" -eq $param) {
					#		break
					#	}
					#	# replace all occurences of v_arg$j with "$param"...
					#}


				}


				#get also vehicletype and replace hud with standard icons
				$regexprvehicleType="^\s*ObjectTemplate.vehicleHud.vehicleType\s+(\d+)\s*"

				$regexprtypeIcon="^\s*ObjectTemplate.vehicleHud.typeIcon\s+(\S+)\s*"
				$regexprminiMapIcon="^\s*ObjectTemplate.vehicleHud.miniMapIcon\s+(\S+)\s*"
				$regexprvehicleIcon="^\s*ObjectTemplate.vehicleHud.vehicleIcon\s+(\S+)\s*"


				$sw.WriteLine($line)
			}
			$sw.close()
			$sr.close()
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

#$modFolder="U:\Other data\Games\Battlefield 2\Personal mods\GitHub\psbf2tweak"
function ExtractModServerArchives($modFolder) {

	#$extractionFolder="."

	$serverArchives="$modFolder\ServerArchives.con"

	#Objects, Menu, Common, Fonts, Shaders, Scripts

	# First lines have more priority over the last in ServerArchives.con?

	$remregexpr="^\s*rem\s+(.*)\s*" # To skip lines beginning with a comment.
	$archiveregexpr="^\s*fileManager.mountArchive\s+(.+)`.zip\s+(.+)\s*"
	$sr=[System.IO.StreamReader]$serverArchives
	while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
		$line=$sr.ReadLine()
		$m=[regex]::Match($line, $remregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		if ($m.Success) {
			Continue
		}
		$m=[regex]::Match($line, $archiveregexpr)
		if ($m.Groups.Count -ne 3) {
			Continue
		}
		$file=$m.Groups[1].value #filename without .zip
		$folder=$m.Groups[2].value
		"$file -> $folder"
		If (Test-Path -Path "$modFolder\$file.zip") {
			$zipfile="$modFolder\$file.zip"
		}
		else {
			If (Test-Path -Path "$modFolder\..\..\$file.zip") {
				# Should add option to choose what to do with files outside current mod...?
				$zipfile="$modFolder\..\..\$file.zip"
				Write-Output "Skipping $zipfile since it is outside current mod"
				Continue
			}
			else {
				Write-Error "Could not find $modFolder\$file.zip or $modFolder\..\..\$file.zip"
			}
		}
		& 7z x -y "$zipfile" `-o"$modFolder\$file"
	}
	$sr.close()
}

function CompressModServerArchives($modFolder) {

}

#Read-Host -Prompt "Press Enter to continue"

exit

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
