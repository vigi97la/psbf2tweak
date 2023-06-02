#"Modern vehicle pack mainly from https://www.moddb.com/games/battlefield-2/addons, with some modified maps"

#"Please ensure Battlefield 2 is installed (tested with Complete Collection)."

# Change or set to $null if you do not need/want.
$timeToStayAsWreck=240 # Vehicles wrecks stay longer (in s).
$armorEffectTemplateFile=$null # It will try to add additional smoke and fire effect depending on damages.
$vehicleSupplyObjectTemplateFile=$null
$vehicleSpawnPointTemplateFile=$null

#$bforceStandardBF2Only
#$bforceStandardBF2CompleteCollectionOnly

# Give 30 s to decide to continue with defaults (above) or not...
#...

# Should show that only if user has chosen options that requires it...
#if ((Get-Command "7z.exe" -ErrorAction SilentlyContinue) -eq $null) 
#{ 
#   "Please install 7z.exe (7-Zip) and ensure it is in Windows PATH, and reboot"
#}
# Use expand-archive instead? 7z might still be necessary for vehicle packs from the Internet...

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
	$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

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
	#ArmorEffectUpdate $objectsFolder $null
	BasicTempUpdate $objectsFolder 0.01
	TimeToStayAsWreckUpdate $objectsFolder $timeToStayAsWreck
	#all apcs get supplyobject and spawnpoints
	#Use git to create a repo and make commits inside...

}

function AddNewVehicle($vehicleName, $vehicleType, $vehicleTeams, $downloadLink, $homePage=$null, $wiki=$null, $preCustomScript=$null, $postCustomScript=$null) {
	$preCustomScript

	#first should try to download directly from $downloadLink (how to get wget error code?), if it fails assumes it is moddb, how to do without ie...

	$ie = new-object -ComObject InternetExplorer.Application
	$ie.Navigate($downloadLink)
	$ln=$IE.Document.getElementsByTagName('a') | Where-Object {$_.href -match "/addons/start"}
	$ie.Navigate($ln.IHTMLAnchorElement_href)
	$ln=$IE.Document.getElementsByTagName('a') | Where-Object {$_.href -match "/downloads/mirror"}
	$downloadLink=$ln.IHTMLAnchorElement_href

	wget $downloadLink -UseBasicParsing -OutFile "C:\tmp\download.zip"
	7z x "C:\tmp\download.zip" -o"C:\tmp\download" -y
	Get-ChildItem "C:\tmp\download\*" -R -Include *.zip,*.rar,*.7z | ForEach-Object {
		7z x $_.FullName -o"$($_.DirectoryName)/$($_.Basename)" -y
		Remove-Item $_.FullName
	}

#search for .bundlemesh, .collisionmesh, .tweak, .con, then move sounds
	#sometimes also there are weapons, effects, for that use $postCustomScript?...
	$postCustomScript
}

function ArmorEffectUpdate($objectsFolder, $armorEffectTemplateFile) {
	Get-ChildItem "$objectsFolder\*" -R -Include "*.tweak" | ForEach-Object {
		$bVehicle=[regex]::Match($_.FullName, "(.*Vehicles)").Success
		If ($bVehicle) {
			$regexpr="(?<=ObjectTemplate.armor.addArmorEffect)(\s+)(-?\d+)"
			#$m=Select-String $regexpr "C:\tmp\download\Objects_server\Vehicles\Land\apc_btr_t\apc_btr_t.tweak"
			#$m.Matches[0].value

			#$mc=[regex]::Matches((Get-Content "C:\tmp\download\Objects_server\Vehicles\Land\apc_btr_t\apc_btr_t.tweak"), $regexpr)
			#$mc[0].Groups[2].value

			#$m=[regex]::Matches((Get-Content "C:\tmp\download\Objects_server\Vehicles\Land\apc_btr_t\apc_btr_t.tweak"), $regexpr)
			$m=[regex]::Matches((Get-Content $_.FullName), $regexpr)
			ForEach ($mi in $m) {
				$val=[int]($mi.Groups[2].value)
				If ($val -ge 9) {
					$mi.Groups[2].value
					#"$_ : updating aiTemplate.basicTemp from $val to $temp"
					continue
				}
				Else {
					#match and replace the line with $armorEffectTemplateFile + itself...
					break
				}
			}
		}
	}
}

main

Read-Host -Prompt "Press Enter to continue"

exit



function CreateNewModFromTemplate($modFolder) {
	If (Test-Path -Path $modFolder\..\xpack) {
		$bxpack=$true
	}
	Else {
		$bxpack=$false
		"Error: Missing Special Forces"
		exit
	}
	If (Test-Path -Path $modFolder\..\bf2\Booster_server.zip) {
		$bbooster=$true
	}
	Else {
		$bbooster=$false
		"Error: Missing Armored Fury"
		exit
	}
	If (Test-Path -Path $modFolder\..\bf2\Levels\OperationSmokeScreen) {
		$bef=$true
	}
	Else {
		$bef=$false
		"Error: Missing Euro Force"
		exit
	}

	New-Item $modFolder\Levels -ItemType directory -Force
	Copy-Item -Path python\game\scoringCommon.py,FS.bat,WINDOWED.bat -Destination $modFolder\ -Force -Recurse
	Copy-Item -Path $modFolder\..\xpack\*  -Include AI,Localization,Logs,menu,movies,Objects,python,Settings,shaders,Common_client.zip,Common_server.zip,Fonts_client.zip,Menu_client.zip,Menu_server.zip,Objects_client.zip,Objects_server.zip,Shaders_client.zip,ClientArchives.con,GameLogicInit.con,ServerArchives.con,Mod.desc,bf2xpack.ico,mod.jpg,mod_icon.jpg,bst_archive.md5,bst_archive_mod.md5,std_archive.md5,std_archive_mod.md5,mod.png,mod_icon.png,WINDOWED.bat -Destination $modFolder\ -Force -Recurse
	Copy-Item -Path $modFolder\..\xpack\Levels\Gulf_of_Oman -Destination $modFolder\Levels\ -Force -Recurse

	# Need to replace xpack_alt (which is a template)
	(Get-Content $modFolder\FS.bat) -replace "xpack_alt",(Get-Item $modFolder).Name | Set-Content $modFolder\FS.bat
	(Get-Content $modFolder\WINDOWED.bat) -replace "xpack_alt",(Get-Item $modFolder).Name | Set-Content $modFolder\WINDOWED.bat

	# Specific...
	Copy-Item -Path ServerArchives.con -Destination $modFolder\ -Force -Recurse
	Copy-Item -Path ClientArchives.con -Destination $modFolder\ -Force -Recurse
	Copy-Item -Path Levels\Gulf_of_Oman -Destination $modFolder\Levels\ -Force -Recurse
	cmd.exe /c $modFolder\Levels\update_server.bat # Need 7z
	#if $bef OperationSmokeScreen, Taraba_Quarry need specific fixes to avoid vehicles conflicts...





}

function SetLevelTeams($team1, $team2) {
#Levels\Gulf_of_Oman\server\Init.con 
}
