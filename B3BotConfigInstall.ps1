$sourceFolder = "C:\Users\admin\Desktop\B3BotSourceFiles"
$b3BotRootFolder = "C:\Apps\bigbrotherbot"

# Delete old .ini and .xml files
Get-ChildItem -Path "$b3BotRootFolder\conf" -Filter "CallOfDuty*.ini" | ForEach-Object {
    $file = $_

    Write-Output "Deleting $($file.FullName)"
    Remove-Item -Path $file.FullName
}

Get-ChildItem -Path "$b3BotRootFolder\conf" -Filter "plugin_portal_CallOfDuty*.ini" | ForEach-Object {
    $file = $_

    Write-Output "Deleting $($file.FullName)"
    Remove-Item -Path $file.FullName
}

# Delete scheduled tasks
Get-ScheduledTask | Where-Object { $_.TaskName -match "CallOfDuty" } | ForEach-Object {
    $task = $_

    Write-Host "Deleting scheduled task $($task.TaskName)"
    Stop-ScheduledTask -TaskName $task.TaskName
    Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false
}

# Copy over new .ini and .xml files
Get-ChildItem -Path $sourceFolder -Filter "CallOfDuty*.ini" | ForEach-Object {
    $file = $_

    $targetPath = "$b3BotRootFolder\conf\$($file.Name)"

    Write-Output "Copying $($file.FullName) to $targetPath"
    Copy-Item -Path $file.FullName -Destination $targetPath
}

Get-ChildItem -Path $sourceFolder -Filter "plugin_portal_CallOfDuty*.ini" | ForEach-Object {
    $file = $_

    $targetPath = "$b3BotRootFolder\conf\$($file.Name)"

    Write-Output "Copying $($file.FullName) to $targetPath"
    Copy-Item -Path $file.FullName -Destination $targetPath
}

# Install scheduled tasks
Get-ChildItem -Path $sourceFolder -Filter "CallOfDuty*.xml" | ForEach-Object {
    $file = $_

    Write-Output "Installing scheduled task $($file.FullName)"
    Register-ScheduledTask -TaskName $file.Name.Replace(".xml", "") -Xml (Get-Content $file.FullName | Out-String) -Force
    Start-ScheduledTask -TaskName $file.Name.Replace(".xml", "")
}
