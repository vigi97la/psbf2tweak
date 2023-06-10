Add-Type -AssemblyName System.Windows.Forms

$offset = 0

$form = New-Object System.Windows.Forms.Form
$form.width = 640
$form.height = 480
$form.Text = "AddArmorEffect"

$objectsFolder = "U:\Other data\Games\Battlefield 2\Personal mods\GitHub\bf2"

$instructionsLabel = New-Object System.Windows.Forms.Label
$instructionsLabel.Location = New-Object System.Drawing.Point(300,200)
$instructionsLabel.Size = New-Object System.Drawing.Size(300,100)
$instructionsLabel.Text =
"Add more fire and smoke on damaged vehicles and wrecks (see more info in AddArmorEffect.ps1). "+
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
	.\AddArmorEffect.ps1 $objectsFolderTextBox.Text $bIncludeStationaryWeaponsCheckbox.Checked $bIncludeAllCheckbox.Checked | Write-Host
})
$form.Controls.Add($applyButton)

[void]$form.ShowDialog()
