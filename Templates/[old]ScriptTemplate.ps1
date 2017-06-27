# Command line paramaters
param([switch]$t)  # Test mode switch

# Module imports
############################
## MODULE IMPORTS GO HERE ##
############################

## Functions
#######################
## FUNCTIONS GO HERE ##
#######################

#################### GLOBAL CONFIG #####################
<##>                                                ####
<##>  $testModeSleepTime = 1000 * 15 #Milliseconds  ####
<##>  $scriptName = ""                              ####
<##>  $scriptVersion = "1.0"                        ####
<##>                                                ####
########################################################

## Self-Elevation of script (if script was not run as Administrator, start PowerShell again as Administrator and run script)
# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole)){  # We are running "as Administrator"
    Clear-Host
}
else{  # We are not running "as Administrator" - so relaunch as administrator   
    # Create a new process object that starts PowerShell
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
   
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

# Test mode
if ($t -eq $true){
    "---------"
    "TEST MODE"
    "---------"
    ""
}

## START MAIN LOGIC
## ----------------

#########################
## MAIN CODE GOES HERE ##
#########################

## --------------
## END MAIN LOGIC

## Code to be executed in test mode
if ($t -eq $true){
    
    # Sleep for the specified amount fo time before running test mode code
    [System.Threading.Thread]::Sleep($testModeSleepTime)

    ##############################
    ## TEST MODE CODE GOES HERE ##
    ##############################
}