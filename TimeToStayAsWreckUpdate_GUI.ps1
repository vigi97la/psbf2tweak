Add-Type -AssemblyName System.Windows.Forms

$offset = 0

$form = New-Object System.Windows.Forms.Form
$form.width = 640
$form.height = 480
$form.Text = "TimeToStayAsWreckUpdate"

$objectsFolder = "C:\Program Files (x86)\EA GAMES\Battlefield 2\mods\bf2\Objects_server"
#$objectsFolder = "U:\Other data\Games\Battlefield 2\Personal mods\GitHub\bf2"
$time = 10

$instructionsLabel = New-Object System.Windows.Forms.Label
$instructionsLabel.Location = New-Object System.Drawing.Point(300,200)
$instructionsLabel.Size = New-Object System.Drawing.Size(300,100)
$instructionsLabel.Text =
"A time of 10 s is usually the default, but 240 is the recommended setting for this mod (see more info in TimeToStayAsWreckUpdate.ps1). "+
"Warning: some vehicles are known to have problems with a value different from 0, check vehicles_db.csv."
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
if ($folderBrowser.ShowDialog() -eq "OK") {
	$objectsFolder = $folderBrowser.SelectedPath
	$objectsFolderTextBox.Text = $objectsFolder
}
})
$form.Controls.Add($changeobjectsFolderButton)

$offset += 60
$timeLabel = New-Object System.Windows.Forms.Label
$timeLabel.Location = New-Object System.Drawing.Point(10,$offset)
$timeLabel.Size = New-Object System.Drawing.Size(65,20)
$timeLabel.Text = "Time (in s): "
$form.Controls.Add($timeLabel)

$timeTextBox = New-Object System.Windows.Forms.TextBox
$timeTextBox.Location = New-Object System.Drawing.Point(80,$offset)
$timeTextBox.Size = New-Object System.Drawing.Size(260,20)
$timeTextBox.Text = $time
# From https://stackoverflow.com/questions/38404631/limiting-text-box-entry-to-numbers-or-numpad-only-no-special-characters
$timeTextBox.add_TextChanged({
    # Check if Text contains any non-Digits
    If ($timeTextBox.Text -match '\D') {
        # If so, remove them
        $timeTextBox.Text = $timeTextBox.Text -replace '\D'
        # If Text still has a value, move the cursor to the end of the number
        If ($timeTextBox.Text.Length -gt 0) {
            $timeTextBox.Focus()
            $timeTextBox.SelectionStart = $timeTextBox.Text.Length
        }
    }
})
$form.Controls.Add($timeTextBox)

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
	.\TimeToStayAsWreckUpdate.ps1 $objectsFolderTextBox.Text $timeTextBox.Text $bIncludeStationaryWeaponsCheckbox.Checked $bIncludeAllCheckbox.Checked | Write-Host
})
$form.Controls.Add($applyButton)

[void]$form.ShowDialog()
