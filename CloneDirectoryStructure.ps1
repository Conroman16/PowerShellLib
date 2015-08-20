#
# Recursively clones a directory structure (and certain files in it - if desired)
#

function Prompt-Host{
param([string]$message)
    while($true){
        Write-Host "$message (Y / N)?"
        $res = Read-Host

        if ($res -ieq "Y"){
            return $true
        }
        elseif ($res -ieq "N"){
            return $false
        }
    }
}

function CopyFiles{
param([string]$currDir)

    $dirs = [System.IO.Directory]::EnumerateDirectories($currDir)
    $files = Get-Item "$currDir\*"

    $files = $files | Where-Object { $_.Extension.Replace(".", "") -in $fileExts }

    foreach ($file in $files){
        $newPath = $file.FullName.Replace($rootPath, $destPath)
        $newPathDir = [System.IO.Path]::GetDirectoryName($newPath)
        if (![System.IO.Directory]::Exists($newPathDir)){
            $noop = [System.IO.Directory]::CreateDirectory($newPathDir)
        }
        if (![System.IO.File]::Exists($newPath)){
            "Copying '" + $file.FullName.Replace($rootPath, "") + "' to '$newPath'..."
            [System.IO.File]::Copy($file.FullName, $newPath)
        }
        else{
            if (Prompt-Host ("File '" + $file.FullName + "' exists!  Overwrite?")){
                [System.IO.File]::Copy($file.FullName, $newPath, $true)
            }
        }
    }

    foreach ($dir in $dirs){
        CopyFiles $dir
    }
}

$rootPath = "G:\"                     # Root of directory structure to copy
$destPath = "C:\"                     # Path where directory structure clone will be output
$fileExts = @("jpg", "jpeg", "png")   # File extensions to copy into new directory structure

# Kick it off
CopyFiles $rootPath $fileExts