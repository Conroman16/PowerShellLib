########################## GLOBAL CONFIG ##########################
<##>                                                           ####
<##>  $scriptName = "DevPortable Environment Variable Setter"  ####
<##>  $scriptVersion = "1.0"                                   ####
<##>                                                           ####
###################################################################

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
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";
   
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

## START MAIN LOGIC
## ----------------

# Set at global level
$variableTarget = [System.EnvironmentVariableTarget]::Machine

"Set variable at:"
"[0] User Level"
"[1] Machine Level"
$res = Read-Host ""
while($true){
    if ($res -eq 0){
        $variableTarget = [System.EnvironmentVariableTarget]::User
        break
    }
    elseif ($res -eq 1){
        break
    }
}

# Get environment variable name
$variableName = Read-Host "Environment variable name"

# Get path from user
$variableValue = Read-Host "Path to DevPortable"

# Set environment variable
[System.Environment]::SetEnvironmentVariable($variableName, $variableValue, $variableTarget)

## --------------
## END MAIN LOGIC