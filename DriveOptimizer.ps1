###############################################################################################################################################
###############################################################################################################################################
#### ------------------------------------------------------------------------------------------------------------------------------------- ####
#### |                                                                                                                                   | ####
#### |                                                  |  This script optimizes your SSD-tiered drives by drive letter.  Since drive    | ####
#### |   Drive Optimizer  |  Written by Connor Kennedy  |  drive optimization has to be run with Administrator privileges, the script    | ####
#### |                                                  |  will self-elevate if it was not run with Administrator permissions.           | ####
#### |                                                                                                                                   | ####
#### ------------------------------------------------------------------------------------------------------------------------------------- ####
#### ------------------------------------------------------------------------------------------------------------------------------------- ####
####                                                                                                                                       ####
####                                                     CONFIGURATION OF DEFAULT DRIVES                                                   ####
####                                                     -------------------------------                                                   ####
####                                                                                                                                       ####
<##>                                                     $defaultDrives = @("I","J","K")                                                   ####
####                                                                                                                                       ####
#### ------------------------------------------------------------------------------------------------------------------------------------- ####
###############################################################################################################################################
###############################################################################################################################################

# Initializations
$version = 4.3
$defDrives = ""
$numDrives = 0
$driveNum = 1
$arrayString = ""
$underline = ""
$scriptName = "SSD Tiered Drive Optimizer v$version"


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
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
}

# Initialize window
$Host.UI.RawUI.WindowTitle = $scriptName + " (Administrator)"
""
""
$scriptName.Remove($scriptName.LastIndexOf(" ")).ToUpper() + $scriptName.Substring($scriptName.LastIndexOf(" "))
for ($i = 0; $i -lt $scriptName.Length; $i++){
    $underline += "-"
}
$underline
""

### Optimization of drives
## Initialize program
# Build string of default drives for use when asking user if they want to use default drives
foreach($i in $defaultDrives){
    If($defDrives -eq ""){
        $defDrives = $i
    }
    Else{
        $defDrives = $defDrives + "," + $i
    }
}

## Run program
# Loop until negative ('N',"NO','0') or affirmative ('Y','YES','1') is received from user
while(1){
    $userOption = Read-Host "Use default drive(s) [$defDrives]? "
    If($userOption -eq "Y" -or $userOption -eq "YES" -or $userOption -eq 1){ # Affirmative input options (sends $option = 1)
        $option = 1
        break
    }
    ElseIf($userOption -eq "N" -or $userOption -eq "NO" -or $userOption -eq 0){ # Negative input options (sends $option = 0)
        $option = 0
        break
    }
    ElseIf($userOption -eq ""){}
    Else{
        ""
        "INVALID INPUT!"
        ""
    }
}

# If user's answer is affirmative [$option = 1]
If($option -eq "1"){
    foreach($i in $defaultDrives){
        If($arrayString -eq ""){
            $arrayString = $i
        }
        Else{
            $arrayString = $arrayString + "," + $i
        }
    }
    $numDrives = $defaultDrives.Count
    $driveLets = $arrayString
}

# If user's option is not affirmative (which means it has to be negative) [$option = 0]
Else{
    $userDriveLets = ""
	
    # Loop until user enters drive letters
    while($userDriveLets -eq ""){
        $userDriveLets = Read-Host "└-> Letters of drives to optimize"
    }
    $userDriveLets.Split(",") | ForEach {
        $numDrives++
    }
    $driveLets = $userDriveLets
}

# Perform drive optimization
$driveLets.Split(",") | ForEach {
    $letter = $_.ToUpper()
    ""
    [String]::Format("Optimizing Drive {0}: ...  [{1}/{2}]", $letter, $driveNum, $numDrives)
    Optimize-Volume -DriveLetter $letter -TierOptimize
    [String]::Format("Drive {0}: Optimized", $letter)
    $driveNum++
}

""
"DRIVE OPTIMIZATION COMPLETE!"
"Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")