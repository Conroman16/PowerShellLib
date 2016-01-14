function Get-PasswordFromEncFile{
param([string]$encFilePath)
    $fileContent = Get-Content -Path $encFilePath
    if ($fileContent.GetType().Name.ToLower() -eq "object[]"){
        $fileContent = [System.Text.Encoding]::UTF8.GetString($fileContent).Trim()
    }
    $secStr = ConvertTo-SecureString $fileContent
    $nc = New-Object System.Net.NetworkCredential
    $nc.SecurePassword = $secStr
    return $nc.Password
}

function New-EncFile{
    # Get password
    $password = Read-Host -AsSecureString "Enter password"
    $password2 = Read-Host -AsSecureString "Re-enter password"

    # Compare passwords
    $pwdsAreEqual = Compare-SecureStrings $password $password2

    # Loop until passwords are equal
    while (!$pwdsAreEqual){
        "Passwords did not match!"
        $password = Read-Host -AsSecureString "Enter password"
        $password2 = Read-Host -AsSecureString "Re-enter password"
        $pwdsAreEqual = Compare-SecureStrings $password $password2
    }

    # Convert password
    $fileBytes = [System.Text.Encoding]::UTF8.GetBytes((ConvertFrom-SecureString $password))

    # Save file
    $filePath = Set-SaveLocation ([System.IO.Path]::Combine($env:USERPROFILE, "pw")) "enc" "Encoded files" "Hidden, Archive, NotContentIndexed"
    Set-Content -Path $filePath -Value $fileBytes -Encoding Unknown
    $fileInfo = New-Object System.IO.FileInfo $filePath
    $fileInfo.Attributes = "Archive, ReadOnly, Hidden, NotContentIndexed"
}

function Compare-SecureStrings{
param([securestring]$str1, [SecureString]$str2)
    $str1_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($str1))
    $str2_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($str2))
 
    if ($str1_text -ceq $str2_text) {
        return $true
    }
    else {
        return $false
    }
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