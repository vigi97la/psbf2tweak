
function BasicTempUpdate($objectsFolder, [double]$tempMultiplier=100, [bool]$bIncludeStationaryWeapons=$false, [bool]$bIncludeAll=$false) {

	Get-ChildItem "$objectsFolder\*" -R -Include "Objects.ai" | ForEach-Object {
		$file=$_.FullName
		$bVehicle=[regex]::Match($file, "(.*Vehicles.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		$bStationaryWeapon=[regex]::Match($file, "(.*Weapons\\stationary.*)",[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant").Success
		If (($bVehicle) -or ($bStationaryWeapon -and $bIncludeStationaryWeapons) -or ($bIncludeAll)) {
			$regexpr="^\s*aiTemplate.basicTemp\s+(-?\d+)\s*"
			$sr=[System.IO.StreamReader]$file
			$sw=[System.IO.StreamWriter]"$file.tmp"
			while (($null -ne $sr) -and (-not $sr.EndOfStream)) {
				$line=$sr.ReadLine()
				$m=[regex]::Match($line, $regexpr,[Text.RegularExpressions.RegexOptions]"IgnoreCase, CultureInvariant")
				if ($m.Groups.Count -ne 2) {
					$sw.WriteLine($line)
					Continue
				}
				$val=[int]($m.Groups[1].value)
				$temp=[int]($tempMultiplier*$val)
				Write-Output "$file : updating aiTemplate.basicTemp from $val to $temp"
				$sw.WriteLine("aiTemplate.basicTemp $temp")
			}
			$sw.close()
			$sr.close()
			Move-Item -Path "$file.tmp" -Destination "$file" -Force
		}
	}
}

BasicTempUpdate @args
