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
# Use expand-archive instead?

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

function ChangeMapVehicles($levelFolder,$forcedTeam1="",$forcedTeam2="",[bool]$bRandomizeTeam1Vehicles=$true,[bool]$bRandomizeTeam2Vehicles=$true,[bool]$bEnforcePreferredTeams=$false,[bool]$bEnforceAmphibious=$true,[bool]$bEnforceFloating=$true,[bool]$bEnforceVTOL=$true,[bool]$bEnforceCanBeAirDropped=$true) {
	#extract $levelFolder\server.zip Expand-Archive -Force -LiteralPath "$levelFolder\server.zip" -DestinationPath "$levelFolder\server"
	#get which team is 1 or 2 in $levelFolder\server\Init.con
	#known teams: ALL (particular case),US,MEC,CH,SEAL,MECSF,Spetz,SAS,Chinsurgent,MEInsurgent,EU
	#in GamePlayObjects.con, search for ObjectTemplate.setObjectTemplate teamnumber vehicle
	#check if vehicle is available from $modFolder
	#find the vehicle in vehicles.db and determine vehicletype and compatible flags, if not found try to determine from name (tank : tank,tnk,mbt; Apc,amv,ifv; civilian,civ;jeep,jep;car;heli,the,ahe,che,the;plane,jet,air;flag: ru;us;ch;mec;eu)
	

}



#Maps
#https://www.moddb.com/games/battlefield-2/addons/gulf-of-oman-coop
https://www.moddb.com/downloads/mirror/247289/124/5f4ec9b939eab7f59874ca5109f2bbb5/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons

#Planes
#https://www.moddb.com/games/battlefield-2/addons/su-75-checkmate
https://www.moddb.com/downloads/mirror/235879/127/951429ad7a4a1b68cb58f3345738f7dd/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F4
#https://www.moddb.com/games/battlefield-2/addons/mig39-the-last-big-mig
https://www.moddb.com/downloads/mirror/228854/123/adb3fc5a0a61c666bedfba830815a30d/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F6
#https://www.moddb.com/games/battlefield-2/addons/indonesian-air-force-dassault-rafale
https://www.moddb.com/downloads/mirror/226587/130/1c36da39707a768a32480666ce045fe1/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F7
#https://www.moddb.com/games/battlefield-2/addons/aix-mirage2k1
https://www.moddb.com/downloads/mirror/224568/122/5ec1a5c883357aad6cb84b861c71da16/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F8
#https://www.moddb.com/games/battlefield-2/addons/su-57-osea-air-defence-forces
#https://www.moddb.com/downloads/mirror/223397/124/f9eab35ef89ec8438dffb5ba076329e8/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F8
#https://www.moddb.com/games/battlefield-2/addons/su-37-terminator-erusea-air-force
#https://www.moddb.com/downloads/mirror/223603/121/46a8f99e52fc4c0fcfa5489acddae4bd/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F8
#https://www.moddb.com/games/battlefield-2/addons/shenyang-j-31-gryfalcon
#https://www.moddb.com/downloads/mirror/220997/124/6503687c85f0fa5d553eaf4b2fe933aa/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F9
#https://www.moddb.com/games/battlefield-2/addons/su-35s-spare-15-trigger
#https://www.moddb.com/games/battlefield-2/addons/su35-paintingbf3-su35bm
#https://www.moddb.com/games/battlefield-2/addons/plaaf-j20
#https://www.moddb.com/games/battlefield-2/addons/b1-lancer
#https://www.moddb.com/games/battlefield-2/addons/f-22-raptor-stealth-fighter
#https://www.moddb.com/downloads/mirror/214322/122/5847544c3e3a1ca62f0719e5af3d158c/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F12
#https://www.moddb.com/games/battlefield-2/addons/super-etendard
#https://www.moddb.com/downloads/mirror/196993/127/32b86c476879b60fb3c44431df2d3015/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F21
#https://www.moddb.com/games/battlefield-2/addons/b52
https://www.moddb.com/addons/start/139711?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%3Ffilter%3Dt%26kw%3Db52%26category%3D%26licence%3D%26timeframe%3D

#Helis
#https://www.moddb.com/games/battlefield-2/addons/bf4-wz11-by-dorangokong-passengers-added
https://www.moddb.com/downloads/mirror/227889/122/9b118bbff7e1b2ded2faecd9fc88e713/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F6
#https://www.moddb.com/games/battlefield-2/addons/mh-x-silent-hawk-helicopters-pack

#Tanks
#https://www.moddb.com/games/battlefield-2/addons/msta-s
https://www.moddb.com/downloads/mirror/246299/124/25657821b97b7796c9208d8e98046435/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons
#https://www.moddb.com/games/battlefield-2/addons/leoclerc
https://www.moddb.com/downloads/mirror/219534/128/c6e33870de39ec27c1781ff6953bd34e/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F10
#https://www.moddb.com/games/battlefield-2/addons/sprutsd
https://www.moddb.com/downloads/mirror/199169/121/2474186001ef6ce9e1ab7c58a71b2be8/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F19
#https://www.moddb.com/games/battlefield-2/addons/leopard-2a7
https://www.moddb.com/downloads/mirror/200630/128/3e954ff35df6d4ea5779cca8b0845663/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F17

#APCs
#https://www.moddb.com/games/battlefield-2/addons/bf3-m1128
https://www.moddb.com/downloads/mirror/244191/123/394937a7c96e5850dd86866b5b8bf9bd/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F2
#https://www.moddb.com/games/battlefield-2/addons/wz551-120mm
https://www.moddb.com/downloads/mirror/244190/123/e6ade80ecab88e2e6e5679a17c716125/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F2
#https://www.moddb.com/games/battlefield-2/addons/bmp-2
https://www.moddb.com/downloads/mirror/208201/122/208e400f8e29f3e09fb3847d7040fdbb/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fruifv-bmp2-texture-pack
#https://www.moddb.com/games/battlefield-2/addons/ruifv-bmp2-texture-pack
https://www.moddb.com/downloads/mirror/240047/127/640386a9825b6a662a458b0e81db4034/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F2
#https://www.moddb.com/games/battlefield-2/addons/bmp-1
https://www.moddb.com/downloads/mirror/225444/130/011e93027d15c96d5389d057b123fc40/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F7
#https://www.moddb.com/games/battlefield-2/addons/usapc-m2a3
https://www.moddb.com/downloads/mirror/213884/123/42717d6c1cd9bd2fe951842b14c19d4e/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F12
#https://www.moddb.com/games/battlefield-2/addons/kto-rosomak-and-textures-pack
https://www.moddb.com/downloads/mirror/199163/121/0cda215a53db17af60869acf9bc523be/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F19

#Other land vehicles
#https://www.moddb.com/games/battlefield-2/addons/bf2-new-mods-vehicle-pack-and-textures-part1
https://www.moddb.com/downloads/mirror/247424/128/ed09cd104da16ce40ee55918385782e2/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons
#https://www.moddb.com/games/battlefield-2/addons/bf2-new-mods-vehicle-pack-and-textures
https://www.moddb.com/downloads/mirror/227724/131/7160a1c03d8389fcb1c16951e4838b67/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F6
#https://www.moddb.com/games/battlefield-2/addons/bf2-new-mods-tank-t-72b1-and-zbd04b
https://www.moddb.com/downloads/mirror/215984/127/a9f8d1ef1b92e4cfaa431ac5123bc37d/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F12
#https://www.moddb.com/games/battlefield-2/addons/bf2-new-mods-btr-t-ifv-puma-and-toyota-rocket-launcher
https://www.moddb.com/downloads/mirror/215067/124/d4b35398c6e6d3d61d76bd4b0abc69ff/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F12
#https://www.moddb.com/games/battlefield-2/addons/bf2-new-mods-tank-vt-5-boxer-crv-texture-pack
https://www.moddb.com/downloads/mirror/214231/124/ef760757d776b22f873028d0c36bcacb/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F12
#https://www.moddb.com/games/battlefield-2/addons/flugabwehrraketensystem-roland-auf-radkraftfahrzeug
#https://www.moddb.com/downloads/mirror/214556/124/5517a34d36c51d9f3a823563c4be01d8/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F12
#https://www.moddb.com/games/battlefield-2/addons/bf2-new-mods-bmd-2-and-lav-25a2-texture-pack
https://www.moddb.com/downloads/mirror/213684/128/1054452991f034345e2e4407b2aab2b1/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F12
#https://www.moddb.com/games/battlefield-2/addons/bf2-new-mods-tank-t-80bv-and-uaz-469-technical
https://www.moddb.com/downloads/mirror/212190/128/d8ce039808b3bbd385de2284ab77f076/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F13
#https://www.moddb.com/games/battlefield-2/addons/bmp-2
https://www.moddb.com/downloads/mirror/208201/131/f8b8b6b5d3a9dfd40c0f4485aeca2fd1/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F14
#https://www.moddb.com/games/battlefield-2/addons/bf2-new-mods-mrap-maxxpro-and-dacia
https://www.moddb.com/downloads/mirror/206918/128/c6a9f21fde32730c50cc8118137e0453/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F15
#https://www.moddb.com/games/battlefield-2/addons/bf2-new-mods-btr-82a-and-mercedes-w123
https://www.moddb.com/downloads/mirror/206678/130/6d3ea973cd97fccfd979df375843be04/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F15
#https://www.moddb.com/games/battlefield-2/addons/bushmasters
https://www.moddb.com/downloads/mirror/206617/130/38a221cfec555db93a6df7337ee9e826/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F15
#https://www.moddb.com/games/battlefield-2/addons/bf2-new-mods-bmp-2-toyota-zu23-bmw
https://www.moddb.com/downloads/mirror/206415/130/ea4601acefb37617746557ace5171f81/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F15

#Other vehicles pack
#https://www.moddb.com/games/battlefield-2/addons/wz10
#https://www.moddb.com/games/battlefield-2/addons/zfb05
#https://www.moddb.com/games/battlefield-2/addons/zbl09
#https://www.moddb.com/games/battlefield-2/addons/ztz99
#https://www.moddb.com/games/battlefield-2/addons/z9
#https://www.moddb.com/games/battlefield-2/addons/wz11
#https://www.moddb.com/games/battlefield-2/addons/type86
#https://www.moddb.com/games/battlefield-2/addons/sx1
#https://www.moddb.com/games/battlefield-2/addons/pgz95
#https://www.moddb.com/games/battlefield-2/addons/hmmwv-m973-avenger
#https://www.moddb.com/games/battlefield-2/addons/bmp2m
https://www.moddb.com/downloads/mirror/208191/131/c8e8eec33039056f35799885e36767f6/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F14
#https://www.moddb.com/games/battlefield-2/addons/bf2-new-mods-tank-object-780-and-zhalo-s2s14
#https://www.moddb.com/downloads/mirror/207425/128/2d286ca99e548d6ea2bf926fdae91f93/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F15
#https://www.moddb.com/games/battlefield-2/addons/h-6k-bomber
#https://www.moddb.com/downloads/mirror/207292/128/3e3590f6e7fc5fc4efbd2e4cec16d854/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F15
#https://www.moddb.com/games/battlefield-2/addons/bf2-new-mod-mtlb-6mb-and-textures
https://www.moddb.com/downloads/mirror/206375/130/d87634ac2c94155ead2658b8047e3648/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F15
#https://www.moddb.com/games/battlefield-2/addons/bf2-review-new-mod-bmp-2-and-textures-pack
https://www.moddb.com/downloads/mirror/202597/130/900a213cc54eda417f012ea1c5119885/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F16
#https://www.moddb.com/games/battlefield-2/addons/t-84-oplot-mbt-plain-desert-texture-blank-texture-modders-resource
#https://www.moddb.com/mods/operation-peacekeeper-2/downloads/opk2-v042-full
#https://www.moddb.com/games/battlefield-2/addons/battlefield-4-vehicles-pack
#https://www.moddb.com/downloads/mirror/198923/123/c2564984b0b07e1bf83d07a1e0e54c09/?referer=https%3A%2F%2Fwww.moddb.com%2Fgames%2Fbattlefield-2%2Faddons%2Fpage%2F19
