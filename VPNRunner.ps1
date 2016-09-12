param([string]$connectionName, [string]$user, [string]$password, [switch]$autoConnect = $false)

# Make sure important args are not empty
if ([string]::IsNullOrWhiteSpace($connectionName) -or [string]::IsNullOrWhiteSpace($user) -or [string]::IsNullOrWhiteSpace($password)){
    "Invalid arguments!"
    exit
}

$vpnExeFilePath = [System.IO.Path]::Combine($env:ProgramFiles, "ShrewSoft", "VPN Client", "ipsecc.exe")

function Get-PasswordFromEncFile{
param([string]$encFilePath)
    $fileContents = [System.IO.File]::ReadAllText($encFilePath).Trim()
    $secStr = ConvertTo-SecureString $fileContents
    $nc = New-Object System.Net.NetworkCredential
    $nc.SecurePassword = $secStr
    return $nc.Password
}
function Restart-Services{ # Must be running as Administrator to do this
    Restart-Service iked,ipsecd
}

# If password is a path to an encoded file, handle that
if ([System.IO.Directory]::Exists([System.IO.Path]::GetDirectoryName($password))){
    $password = Get-PasswordFromEncFile $password
}

# Construct argument string
$sb = New-Object System.Text.StringBuilder
$noop = $sb.Append("-r $connectionName ")
$noop = $sb.Append("-u $user")
if (![string]::IsNullOrWhiteSpace($password)){
    $noop = $sb.Append(" -p $password")
}
if ($autoConnect){
    $noop = $sb.Append(" -a")
}

# Initialize process
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.UseShellExecute = $true
$startInfo.FileName = $vpnExeFilePath
$startInfo.Arguments = $sb.ToString()
if ($autoConnect){
    $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Minimized
}

# Restart services to ensure we're running fresh
Restart-Services

# Start process
$startRes = [System.Diagnostics.Process]::Start($startInfo)