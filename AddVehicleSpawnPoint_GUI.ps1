Add-Type -AssemblyName System.Windows.Forms

$offset = 0

$form = New-Object System.Windows.Forms.Form
$form.width = 640
$form.height = 480
$form.Text = "AddVehicleSpawnPoint"

$objectsFolder = "C:\Program Files (x86)\EA GAMES\Battlefield 2\mods\bf2\Objects_server"
#$objectsFolder = "U:\Other data\Games\Battlefield 2\Personal mods\GitHub\bf2"

$instructionsLabel = New-Object System.Windows.Forms.Label
$instructionsLabel.Location = New-Object System.Drawing.Point(300,200)
$instructionsLabel.Size = New-Object System.Drawing.Size(300,100)
$instructionsLabel.Text =
"Add a mobile spawnpoint on vehicles (see more info in AddVehicleSpawnPoint.ps1 and vehicles_db.csv). "+
"Warning: there is no script to remove it, so make a backup before if needed."
$form.Controls.Add($instructionsLabel)

$offset += 20
$objectsFolderTextBox = New-Object System.Windows.Forms.TextBox
$objectsFolderTextBox.Location = New-Object System.Drawing.Point(10,$offset)
$objectsFolderTextBox.Size = New-Object System.Drawing.Size(480,60)
$objectsFolderTextBox.Text = $objectsFolder
$form.Controls.Add($objectsFolderTextBox)

$changeobjectsFolderButton = new-object System.Windows.Forms.Button
$changeobjectsFolderButton.Location = new-object System.Drawing.Size(500,$offset)
$changeobjectsFolderButton.Size = new-object System.Drawing.Size(100,60)
$changeobjectsFolderButton.Text = "Change Objects_server folder"
$changeobjectsFolderButton.Add_Click({
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
    RootFolder            = "MyComputer"
    Description           = "$Env:ComputerName - Select a folder"
}
If ($folderBrowser.ShowDialog() -eq "OK") {
	$objectsFolder = $folderBrowser.SelectedPath
	$objectsFolderTextBox.Text = $objectsFolder
}
})
$form.Controls.Add($changeobjectsFolderButton)

$offset += 20
$bUseVehiclesDBCheckbox = new-object System.Windows.Forms.checkbox
$bUseVehiclesDBCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bUseVehiclesDBCheckbox.Size = new-object System.Drawing.Size(250,20)
$bUseVehiclesDBCheckbox.Text = "bUseVehiclesDB"
$bUseVehiclesDBCheckbox.Checked = $true
$form.Controls.Add($bUseVehiclesDBCheckbox)

$offset += 20
$bIncludeStationaryWeaponsCheckbox = new-object System.Windows.Forms.checkbox
$bIncludeStationaryWeaponsCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bIncludeStationaryWeaponsCheckbox.Size = new-object System.Drawing.Size(250,20)
$bIncludeStationaryWeaponsCheckbox.Text = "bIncludeStationaryWeapons"
$bIncludeStationaryWeaponsCheckbox.Checked = $false
$form.Controls.Add($bIncludeStationaryWeaponsCheckbox)

$offset += 20
$bIncludeAllCheckbox = new-object System.Windows.Forms.checkbox
$bIncludeAllCheckbox.Location = new-object System.Drawing.Size(10,$offset)
$bIncludeAllCheckbox.Size = new-object System.Drawing.Size(250,20)
$bIncludeAllCheckbox.Text = "bIncludeAll"
$bIncludeAllCheckbox.Checked = $false
$form.Controls.Add($bIncludeAllCheckbox)

$offset += 20
$applyButton = new-object System.Windows.Forms.Button
$applyButton.Location = new-object System.Drawing.Size(500,$offset)
$applyButton.Size = new-object System.Drawing.Size(100,40)
$applyButton.Text = "Apply"
$applyButton.Add_Click({
	.\AddVehicleSpawnPoint.ps1 $objectsFolderTextBox.Text $bUseVehiclesDBCheckbox.Checked $bIncludeStationaryWeaponsCheckbox.Checked $bIncludeAllCheckbox.Checked | Write-Host
})
$form.Controls.Add($applyButton)

[void]$form.ShowDialog()
