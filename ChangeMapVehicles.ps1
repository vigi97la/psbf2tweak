
# vehicles_db.csv:
#vehicleName;vehicleType (tank: 0, mobile artillery: 0.1, heavily-armed APC: 1, anti-tank APC: 1.1, light-armed APC: 1.2, attack heli: 2, transport heli: 2.1, heavy armed car: 3, light armed car: 3.1, light ground vehicle: 3.2, light civilian car: 3.3, heavy civilian car: 3.4, spy car: 3.5, multi-purpose plane: 4, AA plane: 4.1, bombing plane: 4.2, spy plane: 4.3, light civilian plane: 4.4, heavy civilian plane: 4.5, AA: 5, light boat: 6, medium boat: 6.1, heavy boat: 6.2, light submarine: 6.3, heavy submarine: 6.4);preferredTeams;compatibleTeams (ALL (particular case),US,MEC,CH,SEAL,MECSF,Spetz,SAS,Chinsurgent,MEInsurgent,EU);bDisabled;bAmphibious;bFloating;bFlying;bVTOL;bNeedLargeAirfield;bCanBeAirDropped;bDisableSpawnPoint (e.g. when the passengers do not have any weapon and are not meant to be dropped);shortDescription;downloadLink;wikiLink

# Due to the fact some vehicles have more specificities (e.g. bAmphibious) than others from the same vehicleType, it is better to reset GamePlayObjects.con to its original before running again the script (e.g. use $bUseAutoBackup=$true).

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

#$levelFolder="C:\Users\Administrator\Downloads"
#$db=Import-Csv -Path ".\vehicles_db.csv" -Delimiter ";"
#$db|Format-Table
#$db|Where-Object -Property "bDisabled" -notlike "1"|Where-Object "compatibleTeams" -like "*EU*"
#$team="EU"
#$vehicle="air_f35b"

#params $gameMode=sp1,sp2,sp3,gpm_coop,gpm_cq, $mapSize=16,32,64,128...

function ChangeMapVehicles($levelFolder,$gameMode="sp3",$mapSize="64",$forcedTeam1="Spetz",$forcedTeam2="EU",[bool]$bEnforceVehicleType=$true,[bool]$bEnforceCompatibleTeams=$true,[bool]$bEnforcePreferredTeams=$false,[bool]$bEnforceAmphibious=$true,[bool]$bEnforceFloating=$true,[bool]$bEnforceFlying=$true,[bool]$bEnforceVTOL=$true,[bool]$bEnforceNeedAirfield=$true,[bool]$bEnforceNeedLargeAirfield=$true,[bool]$bEnforceCanBeAirDropped=$true,[bool]$bRandomizeTeam1Vehicles=$true,[bool]$bRandomizeTeam2Vehicles=$true,[bool]$bUseAutoBackup=$true) {
	
	#$knownTeams="EU","Spetz"

	$db=Import-Csv -Path "$scriptPath\vehicles_db.csv" -Delimiter ";"
	
	# Compress-Archive produces files not recognized by BF2...
	#Expand-Archive -Force -Path "$levelFolder\server.zip" -DestinationPath "$levelFolder\server"
	& 7z x -y "$levelFolder\server.zip" `-o"$levelFolder\server"

	#should get which team is 1 or 2 in $levelFolder\server\Init.con...?

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
		#$m=[regex]::Matches((Get-Content -Raw $_.FullName), $regexpr)
		$m=[regex]::Matches(([System.IO.File]::ReadAllText($_.FullName)), $regexpr)
		ForEach ($mi in $m) {
			$teamNumber=[int]($mi.Groups[2].value)
			$vehicle=($mi.Groups[4].value)
			#"$teamNumber, $vehicle"

			if ((($teamNumber -eq 1) -and (!$bRandomizeTeam1Vehicles)) -or (($teamNumber -eq 2) -and (!$bRandomizeTeam2Vehicles))) { Continue }

			$team=if ($teamNumber -eq 1) {$forcedTeam1} else {$forcedTeam2}
			
			$val=@($db|Where-Object {$_.vehicleName -ieq "$vehicle"})
			if ($val -ne $null) {
				$vehicleType=[double]$val[0].vehicleType
				$bAmphibious=[int]$val[0].bAmphibious
				$bFloating=[int]$val[0].bFloating
				$bFlying=[int]$val[0].bFlying
				$bVTOL=[int]$val[0].bVTOL
				$bNeedAirfield=[int]$val[0].bNeedAirfield
				$bNeedLargeAirfield=[int]$val[0].bNeedLargeAirfield
				$bCanBeAirDropped=[int]$val[0].bCanBeAirDropped

				$compatibleVehicles=@($db|Where-Object {$_.bDisabled -notlike "1"}|Where-Object {!$bEnforceCompatibleTeams -or ($bEnforceCompatibleTeams -and (($_.compatibleTeams -like "*$team*") -or ($_.compatibleTeams -like "ALL")))}|Where-Object {!$bEnforcePreferredTeams -or ($bEnforcePreferredTeams -and (($_.preferredTeams -like "*$team*") -or ($_.preferredTeams -like "ALL")))}|Where-Object {!$bEnforceVehicleType -or ($bEnforceVehicleType -and ($_.vehicleType -like $vehicleType))}|Where-Object {!$bEnforceAmphibious -or ($bEnforceAmphibious -and ($_.bAmphibious -eq $bAmphibious))}|Where-Object {!$bEnforceFloating -or ($bEnforceFloating -and ($_.bFloating -eq $bFloating))}|Where-Object {!$bEnforceFlying -or ($bEnforceFlying -and ($_.bFlying -eq $bFlying))}|Where-Object {!$bEnforceVTOL -or ($bEnforceVTOL -and ($_.bVTOL -eq $bVTOL))}|Where-Object {!$bEnforceNeedAirfield -or ($bEnforceNeedAirfield -and ($_.bNeedAirfield -eq $bNeedAirfield))}|Where-Object {!$bEnforceNeedLargeAirfield -or ($bEnforceNeedLargeAirfield -and ($_.bNeedLargeAirfield -eq $bNeedLargeAirfield))}|Where-Object {!$bEnforceCanBeAirDropped -or ($bEnforceCanBeAirDropped -and ($_.bCanBeAirDropped -eq $bCanBeAirDropped))})
					
				# Should check if vehicle is available from $modFolder...

				if ($compatibleVehicles.Count -ge 1) {
					$RandomNumber = [int](Get-Random -Minimum 0 -Maximum $compatibleVehicles.Count)
					$newVehicle=$compatibleVehicles[$RandomNumber].vehicleName

					"$teamNumber, $vehicle -> $newVehicle"

					# To improve, this might replace the wrong line...

					$regexpr2="(?<=ObjectTemplate.setObjectTemplate)(\s+)($teamNumber)(\s+)($vehicle)\s+?\r?\n"
					#(Get-Content -Raw $_.FullName) -replace $regexpr2," $teamNumber $newVehicle`r`n" | Set-Content $_.FullName
					([System.IO.File]::ReadAllText($_.FullName)) -replace $regexpr2," $teamNumber $newVehicle`r`n" | Set-Content $_.FullName
				}
				else {
					# Should try automatically to determine from name (tank: tank,tnk,mbt; Apc,amv,ifv; civilian,civ;jeep,jep;car;heli,the,ahe,che,the;plane,jet,air;flag: ru;us;ch;mec;eu)...?
					Write-Warning "Could not find a compatible vehicle, please check vehicles_db.csv"
				}
			}
		}
	}

	# Compress-Archive produces files not recognized by BF2...
	#Compress-Archive -Force -Path "$levelFolder\server\*" -DestinationPath "$levelFolder\server.zip"
	& 7z a -y "$levelFolder\server.zip" "$levelFolder\server\*"

	# Recycle extracted server folder?
}

ChangeMapVehicles @args
