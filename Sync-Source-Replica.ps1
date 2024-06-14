# Parameters declaration
param (
    [string]$sourceFolder,
    [string]$replicaFolder,
    [string]$logFile
)

# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    Write-Output $message
    Add-Content -Path $logFile -Value $message
}

# Ensure both folders exists, otherwise prompt an error message
if (-Not (Test-Path -Path $sourceFolder)) {
    Log-Message "Source folder '$sourceFolder' does not exist."
    exit 1
}

if (-Not (Test-Path -Path $replicaFolder)) {
    New-Item -ItemType Directory -Path $replicaFolder
    Log-Message "Replica folder '$replicaFolder' created."
}

# Synchronize folders
function Sync-Folders {
    param (
        [string]$source,
        [string]$replica
    )

    # Get list of all files and directories in source
    $sourceItems = Get-ChildItem -Path $source -Recurse

    # Sync files and directories from source to replica
    foreach ($item in $sourceItems) {
        $relativePath = $item.FullName.Substring($source.Length)
        $replicaPath = Join-Path -Path $replica -ChildPath $relativePath

        if ($item.PSIsContainer) {
            # Create directory if it doesn't exist in replica
            if (-Not (Test-Path -Path $replicaPath)) {
                New-Item -ItemType Directory -Path $replicaPath
                Log-Message "Directory created: $replicaPath"
            }
        } else {
            # Copy file if it doesn't exist in replica or is different
            if (-Not (Test-Path -Path $replicaPath) -or (Get-FileHash -Path $item.FullName).Hash -ne (Get-FileHash -Path $replicaPath).Hash) {
                Copy-Item -Path $item.FullName -Destination $replicaPath -Force
                Log-Message "File copied: $replicaPath"
            }
        }
    }

    # Get list of all files and directories in replica
    $replicaItems = Get-ChildItem -Path $replica -Recurse

    # Remove files and directories from replica that are not in source
    foreach ($item in $replicaItems) {
        $relativePath = $item.FullName.Substring($replica.Length)
        $sourcePath = Join-Path -Path $source -ChildPath $relativePath

        if (-Not (Test-Path -Path $sourcePath)) {
            if ($item.PSIsContainer) {
                Remove-Item -Path $item.FullName -Recurse -Force
                Log-Message "Directory removed: $item.FullName"
            } else {
                Remove-Item -Path $item.FullName -Force
                Log-Message "File removed: $item.FullName"
            }
        }
    }
}

# Start synchronization
Log-Message "Starting synchronization from '$sourceFolder' to '$replicaFolder'"
Sync-Folders -source $sourceFolder -replica $replicaFolder
Log-Message "Synchronization completed"