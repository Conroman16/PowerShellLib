############# GLOBAL CONFIG ########################
<##>                                            ####
<##>  $scriptName = "Storage Tier File Pinner"  ####
<##>  $scriptVersion = "2.0"                    ####
<##>                                            ####
####################################################

## Self-Elevation of script (if script was not run as Administrator, start PowerShell again as Administrator and run script)
# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole)){  # We are running "as Administrator"
    clear-host
}
else{  # We are not running "as Administrator" - so relaunch as administrator   
    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell"
   
    # Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition
    if ($t -eq $true){
        $newProcess.Arguments += " -t"
    }
   
    # Indicate that the process should be elevated
    $newProcess.Verb = "runas"
   
    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess)
   
    # Exit from the current, unelevated, process
    exit
}

## Initialization
$underline = ""
$scriptTitle = [String]::Format("{0} v{1}", $scriptName, $scriptVersion)
$Host.UI.RawUI.WindowTitle = "$scriptTitle (Administrator)"
""
""
$scriptTitle.Remove($scriptTitle.LastIndexOf(" ")).ToUpper() + $scriptTitle.Substring($scriptTitle.LastIndexOf(" "))
for ($i = 0; $i -lt $scriptTitle.Length; $i++){
    $underline += "-"
}
$underline
""


# Get file to pin
$filePath = Read-Host "Path to file"

# Check that file exists
while ([System.IO.File]::Exists($filePath).ToString() -eq "False"){
    $filePath = Read-Host "File does not exist!  Please re-enter the path"
}
""

# Read out storage tiers
$storageTiers = Get-StorageTier -MediaType SSD
for ($i=0; $i -lt $storageTiers.Count; $i++){
    [System.String]::Format("[{0}] {1}", $i, $storageTiers[$i].FriendlyName)
}

# Get tier number
""
$tn = Read-Host "Pin to tier number"

# Get storage tier
$tier = Get-StorageTier -FriendlyName $storageTiers[$tn].FriendlyName

# Set File Storage Tier to SSD
Set-FileStorageTier -DesiredStorageTier $tier -FilePath $filePath