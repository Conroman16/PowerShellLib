function Create-EncFile{
    # Get password
    $password = Read-Host -AsSecureString "Enter password"

    # Convert Password
    $fileContent = ConvertFrom-SecureString $password

    # Save file
    $filePath = Set-SaveLocation ([System.IO.Path]::Combine($env:USERPROFILE, "pw")) "enc" "Encoded files" "Hidden, Archive, NotContentIndexed"
    [System.IO.File]::WriteAllText($filePath, $fileContent)
    $fileInfo = New-Object System.IO.FileInfo $filePath 
    $fileInfo.Attributes = "Archive, ReadOnly, Hidden, NotContentIndexed"
}

function Get-PasswordFromEncFile{
param([string]$encFilePath)
    $fileContents = [System.IO.File]::ReadAllText($encFilePath).Trim()
    $secStr = ConvertTo-SecureString $fileContents
    $nc = New-Object System.Net.NetworkCredential
    $nc.SecurePassword = $secStr
    return $nc.Password
}

function Set-SaveLocation{
param([string]$initialDirectory, [string]$fileExtFilter, [string]$filterDescription, [string]$fileAttributeString)
    # Handle non-specified initial directory
    if ([string]::IsNullOrWhiteSpace($initialDirectory)){
        $initialDirectory = $env:USERPROFILE
    }

    # Handle '.' at beginning of file extension
    if ($fileExtFilter[0] -ne "."){
        $fileExtFilter = "." + $fileExtFilter
    }

    # Handle file filter description
    if ([string]::IsNullOrWhiteSpace($filterDescription)){
        $filterDescription = $fileExtFilter.Substring(1).ToUpper() + " files"
    }

    # Initialilze SaveFileDialog
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $SaveFileDialog.Filter = "$filterDescription (*$fileExtFilter)|*$fileExtFilter"
    $SaveFileDialog.InitialDirectory = $initialDirectory
    
    # Create directory if it doesn't exist
    if (![System.IO.Directory]::Exists($SaveFileDialog.InitialDirectory)){
        $dirInfo = [System.IO.Directory]::CreateDirectory($SaveFileDialog.InitialDirectory)
        $dirInfo.Attributes = "Directory, " + $fileAttributeString
    }

    # Return file path
    if ($SaveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){
        return $SaveFileDialog.FileName
    }
    else{
        return $initialDirectory
    }
}