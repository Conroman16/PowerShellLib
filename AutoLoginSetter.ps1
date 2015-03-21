param([switch]$t)
$version = "1.0"

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
    if ($t -eq $true){
        $newProcess.Arguments += " -t";
    }
   
    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";
   
    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);
   
    # Exit from the current, unelevated, process
    exit
}

## Initialization
$Host.UI.RawUI.WindowTitle = "AutoLogin Setter $version (Administrator)"
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

""
"AutoLogin Setter v$version"
"---------------------"
""

if ($t -eq $true){
    "---------"
    "TEST MODE"
    "---------"
    ""
}

# Get user information
while(1){
    $domainName = [System.Environment]::UserDomainName
    $userName = [System.Environment]::UserName
    $credential = Get-Credential -UserName "$domainName\$userName" -Message "Enter credentials for automatic login:"

    if ($credential -eq $nul){
        exit
    }
    elseif (!([String]::IsNullOrWhiteSpace($credential.UserName)) -and !([String]::IsNullOrWhiteSpace($credential.GetNetworkCredential().Password))){
        break
    }
}

## Set registry values
"Setting registry values..."
Set-ItemProperty $regPath "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty $regPath "DefaultUserName" -Value $credential.UserName -type String
Set-ItemProperty $regPath "DefaultPassword" -Value $credential.GetNetworkCredential().Password -type String
"Done!"
""

## If in test mode, prompt for immediate reset/removal of affected registry keys
if ($t -eq $true){

    # Loop until negative ('N',"NO','0') or affirmative ('Y','YES','1') is received from user
    while(1){
        $userOption = Read-Host "Undo current changes?"
        If($userOption -eq "Y" -or $userOption -eq "YES" -or $userOption -eq 1){ # Affirmative input options (sends $option = 1)
            $ucOption = 1
            break
        }
        ElseIf($userOption -eq "N" -or $userOption -eq "NO" -or $userOption -eq 0){ # Negative input options (sends $option = 0)
            $ucOption = 0
            break
        }
        ElseIf($userOption -eq ""){}
        Else{
            ""
            "INVALID INPUT!"
            ""
        }
    }

    # If option was affirmative, do reset/removal
    if ($ucOption -eq 1){
        "Undoing registry changes..."
        Set-ItemProperty $regPath "AutoAdminLogon" -Value "0" -type String
        Remove-ItemProperty $regPath "DefaultUserName"
        Remove-ItemProperty $regPath "DefaultPassword"
        "Done!  Goodbye..."
    }
}