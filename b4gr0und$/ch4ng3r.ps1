# AUthor: Cyb3rW1LL
# Created: 06/20/2024
#
#
#
# This will get the current execution policy of the host and save it in the $policy variable
# We reset the this value for the current security policy settings at the end.
$policy = Get-ExecutionPolicy

# Current Username variable
$user = $env:USERNAME

# File paths
$source = "C:\Users\$user\Pictures\Teams_Gifs\"
$destination = "C:\Users\$user\AppData\Local\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Backgrounds\Uploads\"

# This next section of code will run the script in an elevated powershell instance, a.k.a "Administrator"
# and prompt you to allow the execution, click "yes."
# First check if the script is running with administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    # Create a new process to run the script as Administrator
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"";
    $newProcess.Verb = "runas";
    
    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess) | Out-Null;
    
    # Exit the current condition
    exit;
}

# We test the path of the gif folder and create it if not already created
if (-Not (Test-Path -Path $source)) {
    Write-Host '"Teams_Gifs" does not exist! Creating the folder now!'
    New-Item -ItemType Directory -Path $source
    Write-Host '"Teams_Gifs" created!'
    Invoke-Item $source
} else {
    Write-Host "Folder already exists, opening!"
    Invoke-Item $source
}

# This gets the contents of the gif folder
$gifs = Get-ChildItem -Path $source -Filter *.gif -File

# For loop to iterate through the gif folder and generate a new GUID per gif in the folder
# Start the while loop for user input validation
while ($continue -ne "y") {
    # Prompt the user for input
    $continue = Read-Host "Copy your '.gifs' into the folder and PLEASE ENTER 'y' TO PROCEED"

    # Check if the input is not 'y'
    if ($continue -ne "y") {
        Write-Host "Invalid input. Please enter 'y' to proceed."
    }
}

# For loop to generate the GUIDs, copy, and rename them
foreach ($file in $gifs) {
    $GUID = [guid]::NewGuid().ToString()
    $new_filename = Join-Path -Path $file.DirectoryName -ChildPath "$GUID.jpg"
    $new_thumb_filename = Join-Path -Path $file.DirectoryName -ChildPath "${GUID}_thumb.jpg"

    # Rename the original file to the new GUID name with .jpg extension
    Rename-Item -Path $file.FullName -NewName $new_filename

    # Copy the renamed file to create a new _thumb.jpg file
    Copy-Item -Path $new_filename -Destination $new_thumb_filename
}

# Copy both the new files from your gif path to the Destination MS Teams Uploads path
copy-item -Path "C:\Users\$user\Pictures\Teams_Gifs\*" -Destination "C:\Users\$user\AppData\Local\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Backgrounds\Uploads\"

# We revert to the local machine execution policy
Set-ExecutionPolicy $policy -Force
