﻿param([switch]$t)

$pbExePath = "C:\Program Files\PeerBlock\peerblock.exe"
$testModeSleepTime = 1000 * 15  # 15 seconds

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
    if ($t -eq $true){
        $newProcess.Arguments += " -t";
    }
   
    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";
   
    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess)
   
    # Exit from the current, unelevated, process
    exit
}

## Initialization
$Host.UI.RawUI.WindowTitle = "PeerBlock Starter (Administrator)"

## Test Mode
if ($t -eq $true){
    "---------"
    "TEST MODE"
    "---------"
    ""
}

# Initialize process
$pbStartInfo = new-object System.Diagnostics.ProcessStartInfo "$pbExePath"
$pbStartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Minimized

# Start
$pb = [System.Diagnostics.Process]::Start($pbStartInfo)

## If in test mode, kill new process
if ($t -eq $true){
    $date = Get-Date
    $killDate = $date.AddMilliseconds($testModeSleepTime)
    "Sleeping for " + $testModeSleepTime / 1000 + " seconds.  New process will be killed at $killDate." 
    [System.Threading.Thread]::Sleep($testModeSleepTime)
    Stop-Process -InputObject $pb
    "Killed off new process successfully."
}