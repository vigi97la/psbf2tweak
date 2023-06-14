Add-Type -AssemblyName System.Windows.Forms

$offset = 0

$form = New-Object System.Windows.Forms.Form
$form.width = 640
$form.height = 480
$form.Text = "ChangeMapVehicles"

$levelFolder = "C:\Program Files (x86)\EA GAMES\Battlefield 2\mods\bf2\Levels\Gulf_of_Oman"
#$levelFolder = "U:\Progs\EA Games\Battlefield 2\mods\xpack_alt\Levels\Gulf_of_Oman"
$gameMode = "sp3"
$mapSize = "64"
$forcedTeam1 = "MEC"
#$forcedTeam1 = "Spetz"
$forcedTeam2 = "US"
#$forcedTeam2 = "EU"

#should list detected available maps, gamemodes, mapsizes...

#dragdrop folder...

#Add config file to remember last modFolder, levelFolder,...

$instructionsLabel = New-Object System.Windows.Forms.Label
$instructionsLabel.Location = New-Object System.Drawing.Point(300,300)
$instructionsLabel.Size = New-Object System.Drawing.Size(300,100)
$instructionsLabel.Text =
"Please install 7z.exe (7-Zip) and ensure it is in Windows PATH, and reboot. "+
"Edit vehicles_db.csv with e.g. Microsoft Excel to change the list of available vehicles and for more options "+
"(see more info in ChangeMapVehicles.ps1)"
$form.Controls.Add($instructionsLabel)

$offset += 5
$levelFolderTextBox = New-Object System.Windows.Forms.TextBox
$levelFolderTextBox.Location = New-Object System.Drawing.Point(10,$offset)
$levelFolderTextBox.Size = New-Object System.Drawing.Size(480,40)
$levelFolderTextBox.Text = $levelFolder
$form.Controls.Add($levelFolderTextBox)

$changelevelFolderButton = new-object System.Windows.Forms.Button
$changelevelFolderButton.Location = new-object System.Drawing.Size(500,$offset)
$changelevelFolderButton.Size = new-object System.Drawing.Size(100,40)
$changelevelFolderButton.Text = "Change level folder"
$changelevelFolderButton.Add_Click({
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
    RootFolder            = "MyComputer"
    Description           = "$Env:ComputerName - Select a folder"
}
if ($folderBrowser.ShowDialog() -eq "OK") {
	$levelFolder = $folderBrowser.SelectedPath
	$levelFolderTextBox.Text = $levelFolder
}
})
$form.Controls.Add($changelevelFolderButton)

$offset += 30
$gameModeLabel = New-Object System.Windows.Forms.Label
$gameModeLabel.Location = New-Object System.Drawing.Point(10,$offset)
$gameModeLabel.Size = New-Object System.Drawing.Size(80,20)
$gameModeLabel.Text = "gameMode: "
$form.Controls.Add($gameModeLabel)

$gameModeTextBox = New-Object System.Windows.Forms.TextBox
$gameModeTextBox.Location = New-Object System.Drawing.Point(105,$offset)
$gameModeTextBox.Size = New-Object System.Drawing.Size(155,20)
$gameModeTextBox.Text = $gameMode
$form.Controls.Add($gameModeTextBox)

$offset += 20
$mapSizeLabel = New-Object System.Windows.Forms.Label
$mapSizeLabel.Location = New-Object System.Drawing.Point(10,$offset)
$mapSizeLabel.Size = New-Object System.Drawing.Size(80,20)
$mapSizeLabel.Text = "mapSize: "
$form.Controls.Add($mapSizeLabel)

$mapSizeTextBox = New-Object System.Windows.Forms.TextBox
$mapSizeTextBox.Location = New-Object System.Drawing.Point(105,$offset)
$mapSizeTextBox.Size = New-Object System.Drawing.Size(155,20)
$mapSizeTextBox.Text = $mapSize
$form.Controls.Add($mapSizeTextBox)

$offset += 20
$forcedTeam1Label = New-Object System.Windows.Forms.Label
$forcedTeam1Label.Location = New-Object System.Drawing.Point(10,$offset)
$forcedTeam1Label.Size = New-Object System.Drawing.Size(80,20)
$forcedTeam1Label.Text = "forcedTeam1: "
$form.Controls.Add($forcedTeam1Label)

$forcedTeam1TextBox = New-Object System.Windows.Forms.TextBox
$forcedTeam1TextBox.Location = New-Object System.Drawing.Point(105,$offset)
$forcedTeam1TextBox.Size = New-Object System.Drawing.Size(155,20)
$forcedTeam1TextBox.Text = $forcedTeam1
$form.Controls.Add($forcedTeam1TextBox)

$offset += 20
$forcedTeam2Label = New-Object System.Windows.Forms.Label
$forcedTeam2Label.Location = New-Object System.Drawing.Point(10,$offset)
$forcedTeam2Label.Size = New-Object System.Drawing.Size(80,20)
$forcedTeam2Label.Text = "forcedTeam2: "
$form.Controls.Add($forcedTeam2Label)

$forcedTeam2TextBox = New-Object System.Windows.Forms.TextBox
$forcedTeam2TextBox.Location = New-Object System.Drawing.Point(105,$offset)
$forcedTeam2TextBox.Size = New-Object System.Drawing.Size(155,20)
$forcedTeam2TextBox.Text = $forcedTeam2
$form.Controls.Add($forcedTeam2TextBox)

$offset += 20
$bEnforceVehicleTypeCheckbox = new-object System.Windows.Forms.checkbox
$bEnforceVehicleTypeCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforceVehicleTypeCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforceVehicleTypeCheckbox.Text = "bEnforceVehicleType"
$bEnforceVehicleTypeCheckbox.Checked = $true
$form.Controls.Add($bEnforceVehicleTypeCheckbox)

$offset += 20
$bEnforceCompatibleTeamsCheckbox = new-object System.Windows.Forms.checkbox
$bEnforceCompatibleTeamsCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforceCompatibleTeamsCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforceCompatibleTeamsCheckbox.Text = "bEnforceCompatibleTeams"
$bEnforceCompatibleTeamsCheckbox.Checked = $true
$form.Controls.Add($bEnforceCompatibleTeamsCheckbox)

$offset += 20
$bEnforcePreferredTeamsCheckbox = new-object System.Windows.Forms.checkbox
$bEnforcePreferredTeamsCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforcePreferredTeamsCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforcePreferredTeamsCheckbox.Text = "bEnforcePreferredTeams"
$bEnforcePreferredTeamsCheckbox.Checked = $false
$form.Controls.Add($bEnforcePreferredTeamsCheckbox)

$offset += 20
$bEnforceSizeCategoryCheckbox = new-object System.Windows.Forms.checkbox
$bEnforceSizeCategoryCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforceSizeCategoryCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforceSizeCategoryCheckbox.Text = "bEnforceSizeCategory"
$bEnforceSizeCategoryCheckbox.Checked = $false
$form.Controls.Add($bEnforceSizeCategoryCheckbox)

$offset += 20
$bEnforceAmphibiousCheckbox = new-object System.Windows.Forms.checkbox
$bEnforceAmphibiousCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforceAmphibiousCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforceAmphibiousCheckbox.Text = "bEnforceAmphibious"
$bEnforceAmphibiousCheckbox.Checked = $true
$form.Controls.Add($bEnforceAmphibiousCheckbox)

$offset += 20
$bEnforceFloatingCheckbox = new-object System.Windows.Forms.checkbox
$bEnforceFloatingCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforceFloatingCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforceFloatingCheckbox.Text = "bEnforceFloating"
$bEnforceFloatingCheckbox.Checked = $true
$form.Controls.Add($bEnforceFloatingCheckbox)

$offset += 20
$bEnforceFlyingCheckbox = new-object System.Windows.Forms.checkbox
$bEnforceFlyingCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforceFlyingCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforceFlyingCheckbox.Text = "bEnforceFlying"
$bEnforceFlyingCheckbox.Checked = $true
$form.Controls.Add($bEnforceFlyingCheckbox)

$offset += 20
$bEnforceVTOLCheckbox = new-object System.Windows.Forms.checkbox
$bEnforceVTOLCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforceVTOLCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforceVTOLCheckbox.Text = "bEnforceVTOL"
$bEnforceVTOLCheckbox.Checked = $true
$form.Controls.Add($bEnforceVTOLCheckbox)

$offset += 20
$bEnforceNeedWaterCheckbox = new-object System.Windows.Forms.checkbox
$bEnforceNeedWaterCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforceNeedWaterCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforceNeedWaterCheckbox.Text = "bEnforceNeedWater"
$bEnforceNeedWaterCheckbox.Checked = $true
$form.Controls.Add($bEnforceNeedWaterCheckbox)

$offset += 20
$bEnforceNeedAirfieldCheckbox = new-object System.Windows.Forms.checkbox
$bEnforceNeedAirfieldCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforceNeedAirfieldCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforceNeedAirfieldCheckbox.Text = "bEnforceNeedAirfield"
$bEnforceNeedAirfieldCheckbox.Checked = $true
$form.Controls.Add($bEnforceNeedAirfieldCheckbox)

$offset += 20
$bEnforceNeedLargeAirfieldCheckbox = new-object System.Windows.Forms.checkbox
$bEnforceNeedLargeAirfieldCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforceNeedLargeAirfieldCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforceNeedLargeAirfieldCheckbox.Text = "bEnforceNeedLargeAirfield"
$bEnforceNeedLargeAirfieldCheckbox.Checked = $true
$form.Controls.Add($bEnforceNeedLargeAirfieldCheckbox)

$offset += 20
$bEnforceHeavilyArmoredCheckbox = new-object System.Windows.Forms.checkbox
$bEnforceHeavilyArmoredCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforceHeavilyArmoredCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforceHeavilyArmoredCheckbox.Text = "bEnforceHeavilyArmored"
$bEnforceHeavilyArmoredCheckbox.Checked = $false
$form.Controls.Add($bEnforceHeavilyArmoredCheckbox)

$offset += 20
$bEnforceHeavilyArmedCheckbox = new-object System.Windows.Forms.checkbox
$bEnforceHeavilyArmedCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforceHeavilyArmedCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforceHeavilyArmedCheckbox.Text = "bEnforceHeavilyArmed"
$bEnforceHeavilyArmedCheckbox.Checked = $false
$form.Controls.Add($bEnforceHeavilyArmedCheckbox)

$offset += 20
$bEnforceHasManyPassengersCheckbox = new-object System.Windows.Forms.checkbox
$bEnforceHasManyPassengersCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforceHasManyPassengersCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforceHasManyPassengersCheckbox.Text = "bEnforceHasManyPassengers"
$bEnforceHasManyPassengersCheckbox.Checked = $false
$form.Controls.Add($bEnforceHasManyPassengersCheckbox)

$offset += 20
$bEnforceCanBeAirDroppedCheckbox = new-object System.Windows.Forms.checkbox
$bEnforceCanBeAirDroppedCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bEnforceCanBeAirDroppedCheckbox.Size = new-object System.Drawing.Size(250,20)
$bEnforceCanBeAirDroppedCheckbox.Text = "bEnforceCanBeAirDropped"
$bEnforceCanBeAirDroppedCheckbox.Checked = $false
$form.Controls.Add($bEnforceCanBeAirDroppedCheckbox)

$offset = 115
$bRemoveIncompatibleCheckbox = new-object System.Windows.Forms.checkbox
$bRemoveIncompatibleCheckbox.Location = new-object System.Drawing.Size(300,$offset)
$bRemoveIncompatibleCheckbox.Size = new-object System.Drawing.Size(250,20)
$bRemoveIncompatibleCheckbox.Text = "bRemoveIncompatible"
$bRemoveIncompatibleCheckbox.Checked = $false
$form.Controls.Add($bRemoveIncompatibleCheckbox)

$offset += 20
$bRandomizeTeam1VehiclesCheckbox = new-object System.Windows.Forms.checkbox
$bRandomizeTeam1VehiclesCheckbox.Location = new-object System.Drawing.Size(300,$offset)
$bRandomizeTeam1VehiclesCheckbox.Size = new-object System.Drawing.Size(250,20)
$bRandomizeTeam1VehiclesCheckbox.Text = "bRandomizeTeam1Vehicles"
$bRandomizeTeam1VehiclesCheckbox.Checked = $true
$form.Controls.Add($bRandomizeTeam1VehiclesCheckbox)

$offset += 20
$bRandomizeTeam2VehiclesCheckbox = new-object System.Windows.Forms.checkbox
$bRandomizeTeam2VehiclesCheckbox.Location = new-object System.Drawing.Size(300,$offset)
$bRandomizeTeam2VehiclesCheckbox.Size = new-object System.Drawing.Size(250,20)
$bRandomizeTeam2VehiclesCheckbox.Text = "bRandomizeTeam2Vehicles"
$bRandomizeTeam2VehiclesCheckbox.Checked = $true
$form.Controls.Add($bRandomizeTeam2VehiclesCheckbox)

$offset += 20
$bUseAutoBackupCheckbox = new-object System.Windows.Forms.checkbox
$bUseAutoBackupCheckbox.Location = new-object System.Drawing.Size(300,$offset)
$bUseAutoBackupCheckbox.Size = new-object System.Drawing.Size(250,20)
$bUseAutoBackupCheckbox.Text = "bUseAutoBackup"
$bUseAutoBackupCheckbox.Checked = $true
$form.Controls.Add($bUseAutoBackupCheckbox)

$offset += 20
$applyButton = new-object System.Windows.Forms.Button
$applyButton.Location = new-object System.Drawing.Size(500,400)
$applyButton.Size = new-object System.Drawing.Size(100,40)
$applyButton.Text = "Apply"
$applyButton.Add_Click({
	.\ChangeMapVehicles.ps1 $levelFolderTextBox.Text $gameModeTextBox.Text $mapSizeTextBox.Text $forcedTeam1TextBox.Text $forcedTeam2TextBox.Text $bEnforceVehicleTypeCheckbox.Checked $bEnforceCompatibleTeamsCheckbox.Checked $bEnforcePreferredTeamsCheckbox.Checked $bEnforceSizeCategoryCheckbox.Checked $bEnforceAmphibiousCheckbox.Checked $bEnforceFloatingCheckbox.Checked $bEnforceFlyingCheckbox.Checked $bEnforceVTOLCheckbox.Checked $bEnforceNeedWaterCheckbox.Checked $bEnforceNeedAirfieldCheckbox.Checked $bEnforceNeedLargeAirfieldCheckbox.Checked $bEnforceHeavilyArmoredCheckbox.Checked $bEnforceHeavilyArmedCheckbox.Checked $bEnforceHasManyPassengersCheckbox.Checked $bEnforceCanBeAirDroppedCheckbox.Checked $bRemoveIncompatibleCheckbox.Checked $bRandomizeTeam1VehiclesCheckbox.Checked $bRandomizeTeam2VehiclesCheckbox.Checked $bUseAutoBackupCheckbox.Checked | Write-Host
})
$form.Controls.Add($applyButton)

#$OKButton = new-object System.Windows.Forms.Button
#$OKButton.Location = '400, 400'
#$OKButton.Size = '100, 40'
#$OKButton.Text = 'OK'
#$OKButton.DialogResult = 'Ok'
#$form.Controls.Add($OKButton)

[void]$form.ShowDialog()
