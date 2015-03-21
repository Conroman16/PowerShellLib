############################ DEFAULTS ######################################
############################################################################
<##>    $drive = "C:"                                                   ####
<##>    $backupRoot = "K:"                                              ####
<##>    $backupDir = "K:\TESLA_BACKUPS"                                 ####
<##>    $exdupesDir = "F:\TESLA_EXDUPES"                                ####
<##>    $exdupesName = [System.Environment]::MachineName + "_BACKUP"    ####
<##>    $version = "1.2"                                                ####
<##>    $exdupePath = "C:\Exdupe\exdupe.exe"                            ####
############################################################################
############################################################################

## Self-Elevation of script (if script was not run as Administrator, start PowerShell again as Administrator and run script)

# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole)){  # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = "AutoBackup v$version (Administrator)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
}
else{  # We are not running "as Administrator" - so relaunch as administrator   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell"
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas"

   # Set new window to run minimized
   $newProcess.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Minimized
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess)
   
   # Exit from the current, unelevated, process
   exit
}

## Run backup
""
"Starting backup..."

$backupProcess = New-Object System.Diagnostics.Process
$backupProcess.StartInfo.FileName = "wbAdmin"
$backupProcess.StartInfo.Arguments = "Start Backup -backupTarget:$backupRoot -include:$drive -allCritical -systemState -vssfull -quiet"
$backupProcess.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Minimized
$bRes = $backupProcess.Start()
if ($bRes -eq "True"){
    "Backup started."
    $backupProcess.WaitForExit()
    "Backup completed."
    ""
}
else{
    ""
    "BACKUP COULD NOT BE STARTED!"
    "Exiting..."
    exit
}

## Process files for exdupe
# Create WindowsImageBackup directory in backups folder
"Processing files..."
$newDir = New-Item "$backupDir\WindowsImageBackup" -type Directory -Force

# Move directory from drive root to backups folder
Move-Item "$backupRoot\WindowsImageBackup\*" "$backupDir\WindowsImageBackup" -Force

# Delete empty WindowsImageBackup directory at drive root
Remove-Item "$backupRoot\WindowsImageBackup" -Recurse -Force
""
"Finished processing.  Starting Exdupe..."

## Get .full file name
$dotFullName = [System.IO.Path]::GetFileName([System.IO.Directory]::EnumerateFiles($exdupesDir, "*.full"))

# Get diff number
$diffNum = 0
$folderItems = Get-ChildItem $exdupesDir\*.* -Include *.diff*
if ($folderItems.Count -eq 0){
    $diffNum = 1
}
else{
    foreach ($item in $folderItems){
        $extension = $item.Extension
        $eNum = $extension.Substring(5)
        if ($eNum -ge $diffNum){
            $diffNum = ([Int]::Parse($eNum) + 1)
        }
    }
}

# Create diff file name
$time = [DateTime]::Now.TimeOfDay
$diffFileName = [String]::Format("{0}_{1}-{2}-{3}_{4}", $exdupesName, [DateTime]::Now.Month, [DateTime]::Now.Day, [DateTime]::Now.Year, ($time.ToString().Remove($time.ToString().LastIndexOf((':')))).Replace(':',''))
$diffFileNameWithExt = [String]::Format("{0}.diff{1}", $diffFileName, $diffNum)

## Run Exdupe
$exdupeArgs = " -D $backupDir\ $exdupesDir\$dotFullName $exdupesDir\$diffFileNameWithExt"

$exdupeProcess = New-Object System.Diagnostics.Process
$exdupeProcess.StartInfo.FileName = $exdupePath
$exdupeProcess.StartInfo.Arguments = $exdupeArgs
$exdupeProcess.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Minimized
$exRes = $exdupeProcess.Start()
if ($exRes -eq "True"){
    "Exdupe Started."
    $exdupeProcess.WaitForExit()
    "Exdupe completed."
    ""
}
else{
    ""
    "EXDUPE WAS NOT STARTED PROPERLY!"
    "Exiting..."
    exit
}

"Deleting original backup image..."

# Delete original backup
Remove-Item "$backupDir\*" -Recurse -Force

"Original backup image deleted successfully"