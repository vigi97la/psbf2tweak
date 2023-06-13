# See also ReadMe.txt.

# Due to the fact some vehicles have more specificities (e.g. bAmphibious) than others from the same vehicleType, it is better to reset GamePlayObjects.con to its original before running again the script (e.g. use $bUseAutoBackup=$true).

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

#$levelFolder="C:\Users\Administrator\Downloads"
#$db=Import-Csv -Path ".\vehicles_db.csv" -Delimiter ";"
#$db|Format-Table
#$db|Where-Object -Property "Disabled" -notlike "1"|Where-Object "compatibleTeams" -like "*EU*"
#$team="EU"
#$vehicle="air_f35b"

#params $gameMode=sp1,sp2,sp3,gpm_coop,gpm_cq, $mapSize=16,32,64,128...

function ChangeMapVehicles($levelFolder,$gameMode="sp3",$mapSize="64",$forcedTeam1="Spetz",$forcedTeam2="EU",[bool]$bEnforceVehicleType=$true,[bool]$bEnforceCompatibleTeams=$true,[bool]$bEnforcePreferredTeams=$false,[bool]$bEnforceSizeCategory=$false,[bool]$bEnforceAmphibious=$true,[bool]$bEnforceFloating=$true,[bool]$bEnforceFlying=$true,[bool]$bEnforceVTOL=$true,[bool]$bEnforceNeedWater=$true,[bool]$bEnforceNeedAirfield=$true,[bool]$bEnforceNeedLargeAirfield=$true,[bool]$bEnforceHeavilyArmored=$false,[bool]$bEnforceHeavilyArmed=$false,[bool]$bEnforceHasManyPassengers=$false,[bool]$bEnforceCanBeAirDropped=$false,[bool]$bRemoveIncompatible=$false,[bool]$bRandomizeTeam1Vehicles=$true,[bool]$bRandomizeTeam2Vehicles=$true,[bool]$bUseAutoBackup=$true) {

	#$knownTeams="EU","Spetz"

	$db=Import-Csv -Path "$scriptPath\vehicles_db.csv" -Delimiter ";"

	If (-not (Test-Path -Path "$levelFolder\server.zip")) {
		Write-Error "Could not find $levelFolder\server.zip"
		Return
	}

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

	If (-not (Test-Path -Path "$file")) {
		Write-Error "Could not find $file"
		Return
	}

	$remregexpr="^\s*rem\s+(.*)\s*" # To skip lines beginning with a comment.
	$regexpr="^\s*ObjectTemplate.setObjectTemplate\s+([1-2])\s+(\S+)\s*"
	$sr=[System.IO.StreamReader]$file
	$sw=[System.IO.StreamWriter]"$file.tmp"
	while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
		$line=$sr.ReadLine()
		$m=[regex]::Match($line, $remregexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
		if ($m.Success) {
			$sw.WriteLine($line)
			Continue
		}
		$m=[regex]::Match($line, $regexpr)
		if ($m.Groups.Count -ne 3) {
			$sw.WriteLine($line)
			Continue
		}
		$teamNumber=[int]($m.Groups[1].value)
		$vehicle=($m.Groups[2].value)
		#"$teamNumber, $vehicle"

		$newVehicle=$vehicle

		if ((($teamNumber -eq 1) -and (!$bRandomizeTeam1Vehicles)) -or (($teamNumber -eq 2) -and (!$bRandomizeTeam2Vehicles))) {
			$sw.WriteLine($line)
			Continue
		}

		$team=if ($teamNumber -eq 1) {$forcedTeam1} else {$forcedTeam2}

		$val=@($db|Where-Object {$_.vehicleName -ieq "$vehicle"})
		if ($val.Count -ge 1) {
			$vehicleType=[double]$val[0].vehicleType
			$sizeCategory=[int]$val[0].sizeCategory
			$bAmphibious=[int]$val[0].bAmphibious
			$bFloating=[int]$val[0].bFloating
			$bFlying=[int]$val[0].bFlying
			$bVTOL=[int]$val[0].bVTOL
			$bNeedWater=[int]$val[0].bNeedWater
			$bNeedAirfield=[int]$val[0].bNeedAirfield
			$bNeedLargeAirfield=[int]$val[0].bNeedLargeAirfield
			$bHeavilyArmored=[int]$val[0].bHeavilyArmored
			$bHeavilyArmed=[int]$val[0].bHeavilyArmed
			$bHasManyPassengers=[int]$val[0].bHasManyPassengers
			$bCanBeAirDropped=[int]$val[0].bCanBeAirDropped

			$compatibleVehicles=@($db|Where-Object {[double]$_.Disabled -lt 1.0}|Where-Object {!$bEnforceCompatibleTeams -or ($bEnforceCompatibleTeams -and (($_.compatibleTeams -like "*$team*") -or ($_.compatibleTeams -like "ALL")))}|Where-Object {!$bEnforcePreferredTeams -or ($bEnforcePreferredTeams -and (($_.preferredTeams -like "*$team*") -or ($_.preferredTeams -like "ALL")))}|Where-Object {!$bEnforceVehicleType -or ($bEnforceVehicleType -and ($_.vehicleType -like $vehicleType))}|Where-Object {!$bEnforceSizeCategory -or ($bEnforceSizeCategory -and ($_.sizeCategory -like $sizeCategory))}|Where-Object {!$bEnforceAmphibious -or ($bEnforceAmphibious -and ($_.bAmphibious -eq $bAmphibious))}|Where-Object {!$bEnforceFloating -or ($bEnforceFloating -and ($_.bFloating -eq $bFloating))}|Where-Object {!$bEnforceFlying -or ($bEnforceFlying -and ($_.bFlying -eq $bFlying))}|Where-Object {!$bEnforceVTOL -or ($bEnforceVTOL -and ($_.bVTOL -eq $bVTOL))}|Where-Object {!$bEnforceNeedWater -or ($bEnforceNeedWater -and ($_.bNeedWater -eq $bNeedWater))}|Where-Object {!$bEnforceNeedAirfield -or ($bEnforceNeedAirfield -and ($_.bNeedAirfield -eq $bNeedAirfield))}|Where-Object {!$bEnforceNeedLargeAirfield -or ($bEnforceNeedLargeAirfield -and ($_.bNeedLargeAirfield -eq $bNeedLargeAirfield))}|Where-Object {!$bEnforceHeavilyArmored -or ($bEnforceHeavilyArmored -and ($_.bHeavilyArmored -eq $bHeavilyArmored))}|Where-Object {!$bEnforceHeavilyArmed -or ($bEnforceHeavilyArmed -and ($_.bHeavilyArmed -eq $bHeavilyArmed))}|Where-Object {!$bEnforceHasManyPassengers -or ($bEnforceHasManyPassengers -and ($_.bHasManyPassengers -eq $bHasManyPassengers))}|Where-Object {!$bEnforceCanBeAirDropped -or ($bEnforceCanBeAirDropped -and ($_.bCanBeAirDropped -eq $bCanBeAirDropped))})

			# Should check if vehicle is available from $modFolder...

			if ($compatibleVehicles.Count -ge 1) {
				#$RandomNumber=[int](Get-Random -Minimum 0 -Maximum $compatibleVehicles.Count)
				#$newVehicle=$compatibleVehicles[$RandomNumber].vehicleName

				$best=0.0
				$i_best=0
				for ($i=0; $i -lt $compatibleVehicles.Count; $i++) {
					$RandomNumber=[double](Get-Random -Minimum 0.0 -Maximum 1.0)
					$cur=(1.0-[double]$compatibleVehicles[$i].Disabled)*$RandomNumber
					if ($cur -gt $best) {
						$best=$cur
						$i_best=$i
					}
				}
				$newVehicle=$compatibleVehicles[$i_best].vehicleName

				"$teamNumber, $vehicle -> $newVehicle"
			}
			else {
				if ($bRemoveIncompatible) {
					Write-Warning "Removed $vehicle (team $teamNumber): could not find a compatible vehicle, please check vehicles_db.csv"
					Continue
				}
				else {
					Write-Warning "Could not find a vehicle compatible with $vehicle (team $teamNumber), please check vehicles_db.csv"
				}
			}
		}
		else {
			# Should try automatically to determine from name (tank: tank,tnk,mbt; Apc,amv,ifv; civilian,civ;jeep,jep;car;heli,the,ahe,che,the;plane,jet,air;flag: ru;us;ch;mec;eu)...?
			Write-Warning "Could not find $vehicle (team $teamNumber), please check vehicles_db.csv"
		}
		$sw.WriteLine("ObjectTemplate.setObjectTemplate $teamNumber $newVehicle")
	}
	$sw.close()
	$sr.close()

	Move-Item -Path "$file.tmp" -Destination "$file" -Force

	# Compress-Archive produces files not recognized by BF2...
	#Compress-Archive -Force -Path "$levelFolder\server\*" -DestinationPath "$levelFolder\server.zip"
	& 7z a -y "$levelFolder\server.zip" "$levelFolder\server\*"

	# Recycle extracted server folder?
}

ChangeMapVehicles @args
