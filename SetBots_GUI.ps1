Add-Type -AssemblyName System.Windows.Forms

$offset = 0

$form = New-Object System.Windows.Forms.Form
$form.width = 640
$form.height = 480
$form.Text = "SetBots"

$modFolder = "C:\Program Files (x86)\EA GAMES\Battlefield 2\mods\bf2"
#$modFolder = "U:\Other data\Games\Battlefield 2\Personal mods\GitHub\bf2"
$nbBots = [int]47
$maxBotsIncludeHumans = [int]0
$botSkill = [double]1.0

$instructionsLabel = New-Object System.Windows.Forms.Label
$instructionsLabel.Location = New-Object System.Drawing.Point(300,300)
$instructionsLabel.Size = New-Object System.Drawing.Size(300,100)
$instructionsLabel.Text =
"16 bots is usually the default, but 47 is the recommended setting for this mod (see more info in SetBots.ps1). "
$form.Controls.Add($instructionsLabel)

$offset += 20
$modFolderTextBox = New-Object System.Windows.Forms.TextBox
$modFolderTextBox.Location = New-Object System.Drawing.Point(10,$offset)
$modFolderTextBox.Size = New-Object System.Drawing.Size(480,60)
$modFolderTextBox.Text = $modFolder
$form.Controls.Add($modFolderTextBox)

$changemodFolderButton = new-object System.Windows.Forms.Button
$changemodFolderButton.Location = new-object System.Drawing.Size(500,$offset)
$changemodFolderButton.Size = new-object System.Drawing.Size(100,60)
$changemodFolderButton.Text = "Change mod folder"
$changemodFolderButton.Add_Click({
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
    RootFolder            = "MyComputer"
    Description           = "$Env:ComputerName - Select a folder"
}
if($folderBrowser.ShowDialog() -eq "OK") {
	$modFolder = $folderBrowser.SelectedPath
	$modFolderTextBox.Text = $modFolder
}
})
$form.Controls.Add($changemodFolderButton)

$offset += 60
$nbBotsLabel = New-Object System.Windows.Forms.Label
$nbBotsLabel.Location = New-Object System.Drawing.Point(10,$offset)
$nbBotsLabel.Size = New-Object System.Drawing.Size(65,40)
$nbBotsLabel.Text = "Number of bots: "
$form.Controls.Add($nbBotsLabel)

$nbBotsTextBox = New-Object System.Windows.Forms.TextBox
$nbBotsTextBox.Location = New-Object System.Drawing.Point(80,$offset)
$nbBotsTextBox.Size = New-Object System.Drawing.Size(260,20)
$nbBotsTextBox.Text = $nbBots
# From https://stackoverflow.com/questions/38404631/limiting-text-box-entry-to-numbers-or-numpad-only-no-special-characters
$nbBotsTextBox.add_TextChanged({
    # Check if Text contains any non-Digits
    if ($nbBotsTextBox.Text -match '\D') {
        # If so, remove them
        $nbBotsTextBox.Text = $nbBotsTextBox.Text -replace '\D'
        # If Text still has a value, move the cursor to the end of the number
        if ($nbBotsTextBox.Text.Length -gt 0) {
            $nbBotsTextBox.Focus()
            $nbBotsTextBox.SelectionStart = $nbBotsTextBox.Text.Length
        }
    }
})
$form.Controls.Add($nbBotsTextBox)

$offset += 40
$maxBotsIncludeHumansLabel = New-Object System.Windows.Forms.Label
$maxBotsIncludeHumansLabel.Location = New-Object System.Drawing.Point(10,$offset)
$maxBotsIncludeHumansLabel.Size = New-Object System.Drawing.Size(65,40)
$maxBotsIncludeHumansLabel.Text = "maxBotsIncludeHumans (0 or 1): "
$form.Controls.Add($maxBotsIncludeHumansLabel)

$maxBotsIncludeHumansTextBox = New-Object System.Windows.Forms.TextBox
$maxBotsIncludeHumansTextBox.Location = New-Object System.Drawing.Point(80,$offset)
$maxBotsIncludeHumansTextBox.Size = New-Object System.Drawing.Size(260,20)
$maxBotsIncludeHumansTextBox.Text = $maxBotsIncludeHumans
# From https://stackoverflow.com/questions/38404631/limiting-text-box-entry-to-numbers-or-numpad-only-no-special-characters
$maxBotsIncludeHumansTextBox.add_TextChanged({
    # Check if Text contains any non-Digits
    if ($maxBotsIncludeHumansTextBox.Text -match '[^01]') {
        # If so, remove them
        $maxBotsIncludeHumansTextBox.Text = $maxBotsIncludeHumansTextBox.Text -replace '[^01]'
        # If Text still has a value, move the cursor to the end of the number
        if ($maxBotsIncludeHumansTextBox.Text.Length -gt 0) {
            $maxBotsIncludeHumansTextBox.Focus()
            $maxBotsIncludeHumansTextBox.SelectionStart = $maxBotsIncludeHumansTextBox.Text.Length
        }
    }
	if (($maxBotsIncludeHumansTextBox.Text.Length -le 0) -or ($maxBotsIncludeHumansTextBox.Text.Length -gt 1)) {
		$maxBotsIncludeHumansTextBox.Text = $maxBotsIncludeHumans
	}
})
$form.Controls.Add($maxBotsIncludeHumansTextBox)

$offset += 40
$botSkillLabel = New-Object System.Windows.Forms.Label
$botSkillLabel.Location = New-Object System.Drawing.Point(10,$offset)
$botSkillLabel.Size = New-Object System.Drawing.Size(65,40)
$botSkillLabel.Text = "botSkill (between 0.0 and 1.0): "
$form.Controls.Add($botSkillLabel)

$botSkillTextBox = New-Object System.Windows.Forms.TextBox
$botSkillTextBox.Location = New-Object System.Drawing.Point(80,$offset)
$botSkillTextBox.Size = New-Object System.Drawing.Size(260,20)
$botSkillTextBox.Text = $botSkill
$form.Controls.Add($botSkillTextBox)

$offset += 20
$applyButton = new-object System.Windows.Forms.Button
$applyButton.Location = new-object System.Drawing.Size(500,$offset)
$applyButton.Size = new-object System.Drawing.Size(100,40)
$applyButton.Text = "Apply"
$applyButton.Add_Click({
	.\SetBots.ps1 $modFolderTextBox.Text $nbBotsTextBox.Text $maxBotsIncludeHumansTextBox.Text $botSkillTextBox.Text | Write-Host
})
$form.Controls.Add($applyButton)

[void]$form.ShowDialog()
