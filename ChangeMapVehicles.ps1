
# vehicles_db.csv:
#vehicleName;vehicleType (tank: 0, mobile artillery: 0.1, heavily-armed APC: 1, anti-tank APC: 1.1, light-armed APC: 1.2, attack heli: 2, transport heli: 2.1, heavy armed car: 3, light armed car: 3.1, light ground vehicle: 3.2, light civilian car: 3.3, heavy civilian car: 3.4, spy car: 3.5, multi-purpose plane: 4, AA plane: 4.1, bombing plane: 4.2, spy plane: 4.3, light civilian plane: 4.4, heavy civilian plane: 4.5, AA: 5, light boat: 6, medium boat: 6.1, heavy boat: 6.2, light submarine: 6.3, heavy submarine: 6.4);preferredTeams;compatibleTeams (ALL (particular case),US,MEC,CH,SEAL,MECSF,Spetz,SAS,Chinsurgent,MEInsurgent,EU);bDisabled;bAmphibious;bFloating;bVTOL;bCanBeAirDropped;shortDescription;downloadLink;wikiLink

# Due to the fact some vehicles have more specificities (e.g. bAmphibious) than others from the same vehicleType, it is better to reset GamePlayObjects.con to its original before running again the script...

# need gui to list detected maps, gamemodes...

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition


#temporary...

#$levelFolder="C:\Users\Administrator\Downloads"
$levelFolder="U:\Progs\EA Games\Battlefield 2\mods\xpack_alt\Levels\Gulf_of_Oman"
$gameMode="sp3"
$mapSize="64"
$forcedTeam1="Spetz"
$forcedTeam2="EU"
$db=Import-Csv -Path ".\vehicles_db.csv" -Delimiter ";"
#$db|Format-Table
#$db|Where-Object -Property "bDisabled" -notlike "1"|Where-Object "compatibleTeams" -like "*EU*"
$team="EU"
$vehicle="air_f35b"

function ChangeMapVehicles($levelFolder,$gameMode="sp3",$mapSize="64",$forcedTeam1="Spetz",$forcedTeam2="EU",[bool]$bRandomizeTeam1Vehicles=$true,[bool]$bRandomizeTeam2Vehicles=$true,[bool]$bUseAutoBackup=$true,[bool]$bEnforcePreferredTeams=$false,[bool]$bEnforceAmphibious=$true,[bool]$bEnforceFloating=$true,[bool]$bEnforceVTOL=$true,[bool]$bEnforceCanBeAirDropped=$true) {

	#params gamemode=sp1,gpm_coop..., mapsize=16,32,64,128...

	$knownTeams="EU","Spetz"

	$db=Import-Csv -Path "$scriptPath\vehicles_db.csv" -Delimiter ";"
	
	# Compress-Archive produces files not recognized by BF2...
	#Expand-Archive -Force -Path "$levelFolder\server.zip" -DestinationPath "$levelFolder\server"
	7z x -y "$levelFolder\server.zip" -o"$levelFolder\server"

	#should get which team is 1 or 2 in $levelFolder\server\Init.con

	$file="$levelFolder\server\GameModes\$gameMode\$mapSize\GamePlayObjects.con"
	If ($bUseAutoBackup) {
		If (Test-Path -Path "$file.bak") {
			Copy-Item -Path "$file.bak" -Destination "$file" -Force -Recurse		
		}
		Else {
			Copy-Item -Path "$file" -Destination "$file.bak" -Force -Recurse		
		}
	}

	$regexpr="(?<=ObjectTemplate.setObjectTemplate)(\s+)([1-2])(\s+)(.*?)\s+?\r?\n"
	Get-ChildItem "$file" -R | ForEach-Object {
		$m=[regex]::Matches((Get-Content -Raw $_.FullName), $regexpr)
		ForEach ($mi in $m) {
			$teamNumber=[int]($mi.Groups[2].value)
			$vehicle=($mi.Groups[4].value)
			#"$teamNumber, $vehicle"

			$team=if ($teamNumber -EQ 1) {$forcedTeam1} else {$forcedTeam2}
			
			$val=$db|Where-Object "vehicleName" -ieq "$vehicle"
			if ($val -ne $null) {
				$vehicleType=[double]$val[0].vehicleType
				$bFloating=[int]$val[0].bFloating
				$bVTOL=[int]$val[0].bVTOL

				$compatibleVehicles=@($db|Where-Object -Property "bDisabled" -notlike "1"|Where-Object {($_.compatibleTeams -like "*$team*") -or ($_.compatibleTeams -like "ALL")}|Where-Object "vehicleType" -like $vehicleType|Where-Object "bFloating" -eq $bFloating|Where-Object "bVTOL" -eq $bVTOL)
				$RandomNumber = [int](Get-Random -Minimum 0 -Maximum $compatibleVehicles.Count)
				$newVehicle=$compatibleVehicles[$RandomNumber].vehicleName

				"$teamNumber, $vehicle -> $newVehicle"
				$regexpr2="(?<=ObjectTemplate.setObjectTemplate)(\s+)($teamNumber)(\s+)($vehicle)\s+?\r?\n"
				(Get-Content -Raw $_.FullName) -replace $regexpr2," $teamNumber $newVehicle`r`n" | Set-Content $_.FullName
			}
		}
	}
	
	#find the vehicle in vehicles.db and determine vehicleType and compatible flags, if not found try to determine from name (tank: tank,tnk,mbt; Apc,amv,ifv; civilian,civ;jeep,jep;car;heli,the,ahe,che,the;plane,jet,air;flag: ru;us;ch;mec;eu)
	#check if vehicle is available from $modFolder

	# Compress-Archive produces files not recognized by BF2...
	#Compress-Archive -Force -Path "$levelFolder\server\*" -DestinationPath "$levelFolder\server.zip"
	7z a -y "$levelFolder\server.zip" "$levelFolder\server\*"

	#recycle extracted server folder?
}

ChangeMapVehicles @args
