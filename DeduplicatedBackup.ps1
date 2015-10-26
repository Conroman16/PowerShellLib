#############################################################################################################
#############################################################################################################
<#                                                                                                       ####
    INSTALL NOTES                                                                                        ####
        Yeah... this script has to be "installed".  There are two requirements, 1) an SMTP strver to     ####
        send emails from, and a copy of the AWESOME deduplication and compression program "eXdupe".      ####
        You can find eXdupe at www.exdupe.com.  It comes as a single '.exe' file so it's nice and        ####
        portable.  I placed it at 'C:\Program Files\eXdupe\exdupe.exe' but you can put it wherever.      ####
        Just make sure you update the '$exdupePath' variable to reflect where you placed it.  The        ####
        second requirement, email, is a bit more comlicated to get set up.  I use Mailgun                ####
        (mailgun.com) for all my SMTP needs.  They have a free account which allows you to send up       ####
        to 10,000 emails a month, which is plenty more than we're going to be sending here.  Get         ####
        some SMTP credentials set up from your 'SMTP Credentials' page.  I prefer to use their           ####
        'sandbox' domain (which for me is 'sandbox127.mailgun.org') as you don't have to set up and      ####
        verify a domain name.                                                                            ####
                                                                                                         ####
    STEP BY STEP INSTALL                                                                                 ####
        * Download eXdupe from www.exdupe.com                                                            ####
        * Import the 'FileUtils' module from the 'Modules' folder in this repo and run the               ####
          'Create-EncFile' cmdlet.  It'll ask you for the password to your SMTP server twice, and        ####
          then open a file browser to save the '.enc' file with your password (relax, it's totally       ####
          secure.  This file is never truly decrypted again by this script, and can only be fully        ####
          decrypted by the Windows user who created it).  Put the path to this file in the               ####
          '$smtpCredPasswordFilePath' variable.                                                          ####
        * Put the address of your SMTP server in the '$smtpServer' variable.  If you're using            ####
          Mailgun this would be 'smtp.mailgun.org'.                                                      ####
        * Put your SMTP username in the '$smtpCredUserName' variable.  I used the credentials that I     ####
          set up in my Mailgun control panel ('<MY_PC_NAME>@sandbox127.mailgun.org').                    ####
        * Put the email address at which you want to receieve notifications from this script in the      ####
          '$emailRecipientAddress' variable.                                                             ####
                                                                                                         ####
    WHAT THIS SCRIPT DOES                                                                                ####
        * Runs a wbAdmin backup of the drive set in '$drive' with 'allCritical' and 'vssfull' flags      ####
        * Runs eXdupe on that data and output it into the directory set in the '$exdupesDir' variable    ####
                                                                                                         ####
    NOTES                                                                                                ####
        * This script logs all of the console output to a timestamped log file in in the directory       ####
          specified in the '$logsRoot' variable.                                                         ####
        * If the number of '.diff' files exceeds the number set in the '$diffsBeforeRededup' variable    ####
          the script will decompress the most recent differential image and replace the old data with    ####
          a fresh '.full' file.                                                                          ####
        * The script will automatically elevate to 'Administrator' privalages if not run with them       ####
        * The ProcessWindowStyle set in the '$windowStyle' variable only applies to the main script      ####
          window and the 'wbAdmin' process window.  Unfortunately, eXdupe cannot be run within the       ####
          Windows shell and therefore its process window cannot be minimized programatically.            ####
#>                                                                                                       ####
#############################################################################################################
#############################################################################################################

################################################# SETTINGS ##################################################
#############################################################################################################
<##>    $drive = "C:"                                                                                    ####
<##>    $logsRoot = "C:\Logs"                                                                            ####
<##>    $backupRoot = "F:"                                                                               ####
<##>    $exdupesRoot = "G:"                                                                              ####
<##>    $exdupePath = "$env:ProgramFiles\eXdupe\exdupe.exe"                                              ####
<##>    $timestampFormat = "hh:mm:ss tt"                                                                 ####
<##>    $diffsBeforeRededup = 11                                                                         ####
<##>    $machineName = [System.Environment]::MachineName                                                 ####
<##>    $logFile = "$logsRoot\BACKUP_" + [DateTime]::Now.ToString("MM-dd-yyyy_HHmm") + ".log"            ####
<##>    $backupDir = "$backupRoot\$machineName" + "_BACKUPS"                                             ####
<##>    $exdupesDir = "$exdupesRoot\$machineName" + "_EXDUPES"                                           ####
<##>    $exdupesName = $machineName + "_BACKUP"                                                          ####
<##>    $smtpServer = "<YOUR_SMTP_SERVER_ADDRESS_HERE>"                                                  ####
<##>    $localhostDnsEntry = ($machineName + "." + $env:USERDNSDOMAIN).ToLower()                         ####
<##>    $emailSenderDisplayName = "$machineName Backup"                                                  ####
<##>    $emailSenderAddress = "backup@$localhostDnsEntry"                                                ####
<##>    $emailRecipientAddress = "<YOUR_EMAIL_RECIPIENT_ADDRESS_HERE>"                                   ####
<##>    $smtpCredUserName = "<YOUR_SMTP_USERNAME_HERE (IF YOU USE MAILGUN: sandbox127.mailgun.org)>"     ####
<##>    $smtpCredPasswordFilePath = [System.IO.Path]::Combine($env:USERPROFILE, "pw", "mailgun.enc")     ####
<##>    $windowStyle = [System.Diagnostics.ProcessWindowStyle]::Minimized                                ####
#############################################################################################################
#############################################################################################################

## Self-Elevation of script (if script was not run as Administrator, start PowerShell again as Administrator and run script)

# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole)){  # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = "AutoBackup (Administrator)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   Clear-Host
}
else{  # We are not running "as Administrator" - so relaunch as administrator   
   # Create a new process object that starts PowerShell
   $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas"

   # Set new window to run minimized
   $newProcess.WindowStyle = $windowStyle
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess)
   
   # Exit from the current, unelevated, process
   exit
}

try{
    # Start stopwatch
    $stopwatch = New-Object System.Diagnostics.Stopwatch
    $stopwatch.Start()

    # FUNCTIONS
    Function Get-TimeStamp{
    param([string]$timeFormat = $timestampFormat)
        return "[" + [DateTime]::Now.ToString($timeFormat) + "]"
    }
    Function WriteLog-Timestamped{
    param([string]$output)
        if (![System.IO.File]::Exists($logFile)){
            $fileTitle = $machineName + " BACKUP LOG " + [DateTime]::Now.ToString("MM-dd-yyyy hh:mm tt") + [System.Environment]::NewLine
            $titleLength = $fileTitle.Length - 1
            while ($fileTitle.Length -le ($titleLength * 2)){
                $fileTitle += '-'
            }
            $noop = New-Item -ItemType File -Path ([System.IO.Path]::GetDirectoryName($logFile)) -Name ([System.IO.Path]::GetFileName($logFile))
            $noop = Add-Content $logFile ("$fileTitle" + ([System.Environment]::NewLine))
        }
        $timeStamp = Get-TimeStamp
        $noop = Add-Content $logFile "$timeStamp $output"
    }
    Function WriteHost-Timestamped{
    param([string]$output)
        $timeStamp = Get-TimeStamp
        "$timeStamp $output"
        WriteLog-Timestamped $output
        return
    }
    Function Calculate-DiffNumber{
    param([string]$exdupesDir)

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

        return $diffNum
    }
    Function Create-RequiredDirectories{
        # Required directories
        $dirs = $logsRoot, $backupDir, $exdupesDir

        # Check if durectories need to be created, and create them if necessary
        foreach ($dir in $dirs){
            if (![System.IO.Directory]::Exists($dir)){
                $noop = New-Item -ItemType Directory -Path $dir
            }
        }
    }
    Function Run-Backup{
    param([string]$backupRoot, [string]$drive)

        ## Run backup
        ""
        WriteHost-Timestamped "Starting backup..."

        $backupProcess = New-Object System.Diagnostics.Process
        $backupProcess.StartInfo.FileName = "wbAdmin"
        $backupProcess.StartInfo.Arguments = "Start Backup -backupTarget:$backupRoot -include:$drive -allCritical -vssfull -quiet"
        $backupProcess.StartInfo.UseShellExecute = $true
        $backupProcess.StartInfo.WindowStyle = $windowStyle
        $bRes = $backupProcess.Start()
        if ($bRes -eq $true){
            WriteHost-Timestamped "Backup started"
            $backupProcess.WaitForExit()
            WriteHost-Timestamped "Backup completed"
            ""
            return
        }
        else{
            ""
            WriteHost-Timestamped "BACKUP COULD NOT BE STARTED!"

            # Stop stopwatch and send email
            $stopwatch.Stop()
            Send-Email "Backup failed" ("backup script failed with message 'BACKUP COULD NOT BE STARTED!' after " + $stopwatch.Elapsed.TotalSeconds + " seconds of execution.")

            # Throw exception to exit with code 1
            throw new-object System.Exception "BACKUP COULD NOT BE STARTED!"
        }
    }
    Function Run-CreateDotFull{
    param([string]$srcDir, [string]$destDir, [string]$outputFileName, [string]$exdupeExePath = "$env:ProgramFiles\eXdupe\exdupe.exe")
    
        $numThreads = [System.Environment]::ProcessorCount * 1.5
        $outputFilePath = "$destDir\$outputFileName.full"
        $exdupeProcess = New-Object System.Diagnostics.Process
        $exdupeProcess.StartInfo.FileName = $exdupeExePath
        $exdupeProcess.StartInfo.Arguments = "-t$numThreads $srcDir $outputFilePath"
        $exRes = $exdupeProcess.Start()
        if ($exRes -eq $true){
            WriteHost-Timestamped "Exdupe started"
            $exdupeProcess.WaitForExit()
            WriteHost-Timestamped "Exdupe completed"
            ""
            return [System.IO.Path]::GetFileName($outputFilePath)
        }
        else{
            ""
            WriteHost-Timestamped "EXDUPE WAS NOT STARTED PROPERLY!"

            # Stop stopwatch and send email
            $stopwatch.Stop()
            Send-Email "Backup failed" ("backup script failed with message 'EXDUPE WAS NOT STARTED PROPERLY!' after " + $stopwatch.Elapsed.TotalSeconds + " seconds of execution.")

            # Throw exception to exit with code 1
            throw New-Object System.Exception "EXDUPE WAS NOT STARTED PROPERLY!"
        }
    }
    Function Run-CreateDiff{
    param([string]$srcDir, [string]$exdupesDir, [string]$dotFullName, [string]$exdupePath = "$env:ProgramFiles\eXdupe\exdupe.exe")

        # Calculate diff number
        $diffNum = Calculate-DiffNumber $exdupesDir

        # Create diff file name
        $time = [DateTime]::Now.TimeOfDay
        $diffFileName = [String]::Format("{0}_{1}-{2}-{3}_{4}", $exdupesName, [DateTime]::Now.Month, [DateTime]::Now.Day, [DateTime]::Now.Year, ($time.ToString().Remove($time.ToString().LastIndexOf((':')))).Replace(':',''))
        $diffFileNameWithExt = [String]::Format("{0}.diff{1}", $diffFileName, $diffNum)
        $numThreads = [System.Environment]::ProcessorCount * 1.5

        # Initialize and start eXdupe process
        $exdupeProcess = New-Object System.Diagnostics.Process
        $exdupeProcess.StartInfo.FileName = $exdupePath
        $exdupeProcess.StartInfo.Arguments = "-t$numThreads -D $srcDir\ $exdupesDir\$dotFullName $exdupesDir\$diffFileNameWithExt"
        $exRes = $exdupeProcess.Start()
        if ($exRes -eq $true){
            WriteHost-Timestamped "Exdupe started"
            $exdupeProcess.WaitForExit()
            WriteHost-Timestamped "Exdupe completed"
            ""
        }
        else{
            ""
            WriteHost-Timestamped "EXDUPE WAS NOT STARTED PROPERLY!"

            # Stop stopwatch and send email
            $stopwatch.Stop()
            Send-Email "Backup failed" ("backup script failed with message 'EXDUPE WAS NOT STARTED PROPERLY!' after " + $stopwatch.Elapsed.TotalSeconds + " seconds of execution.")

            # Throw wxception to exit with code 1
            throw New-Object System.Exception "EXDUPE WAS NOT STARTED PROPERLY!"
        }
    }
    Function Run-DecompressDiff{
    param([string]$dotFullPath, [string]$diffPath, [string]$outputDir, [string]$exdupeExePath = "$env:ProgramFiles\eXdupe\exdupe.exe")

        $exdupeProcess = New-Object System.Diagnostics.Process
        $exdupeProcess.StartInfo.FileName = $exdupeExePath
        $exdupeProcess.StartInfo.Arguments = " -RD $dotFullPath $diffPath $outputDir"
        $exRes = $exdupeProcess.Start()
        if ($exRes -eq $true){
            WriteHost-Timestamped "Decompression started"
            $exdupeProcess.WaitForExit()
            WriteHost-Timestamped "Decompression completed"
            ""
            return $outputDir
        }
        else{
            ""
            WriteHost-Timestamped "EXDUPE WAS NOT STARTED PROPERLY!"

            # Stop stopwatch and send email
            $stopwatch.Stop()
            Send-Email "Backup failed" ("backup script failed with message 'EXDUPE WAS NOT STARTED PROPERLY!' after " + $stopwatch.Elapsed.TotalSeconds + " seconds of execution.")

            # Throw exception to exit with code 1
            throw New-Object System.Exception "EXDUPE WAS NOT STARTED PROPERLY!"
        }
    }
    Function Get-CredentialPassword{
    param([string]$encFilePath)
        $fileContents = [System.IO.File]::ReadAllText($encFilePath).Trim()
        return ConvertTo-SecureString $fileContents
    }
    Function Send-Email{
    param([string]$subject, [string]$bodyText)
        $to = $emailRecipientAddress
        $from = "$emailSenderDisplayName <$emailSenderAddress>"

        # Create SMTP credential
        $credPass = Get-CredentialPassword $smtpCredPasswordFilePath
        $cred = New-Object System.Management.Automation.PSCredential($smtpCredUserName, $credPass)

        # Send email message
        Send-MailMessage -To $to -From $from -SmtpServer $smtpServer -Subject $subject -Body $bodyText -Credential $cred
    }

    # Ensure all required directories are available
    Create-RequiredDirectories

    # Check if we need to re-dedupe
    $fi = Get-ChildItem $exdupesDir\*.* -Include *.diff*
    $fiCount = 0
    foreach ($f in $fi){
        $fiCount++
    }
    if ($fiCount -ge $diffsBeforeRededup){
        $lastDiff = $fi[$fi.Length - 1]
        $dotFull = Get-ChildItem $exdupesDir\*.* -Include *.full
        WriteHost-Timestamped "Starting Re-Dedup..."
    
        # Run decompression
        $decompressedFiles = Run-DecompressDiff "$exdupesDir\$dotFull" "$exdupesDir\$lastDiff" $backupDir $exdupePath

        # Delete all existing exdupes
        Remove-Item $exdupesDir\*.diff -Recurse -Force

        # Create new '.full' file
        Run-CreateDotFull $backupDir $exdupesDir $exdupesName $exdupePath
    }

    # Run backup
    Run-Backup $backupRoot $drive

    ## Process files for exdupe
    # Create WindowsImageBackup directory in backups folder
    WriteHost-Timestamped "Processing files..."
    $newDir = New-Item "$backupDir\WindowsImageBackup" -type Directory -Force

    # Move directory from drive root to backups folder
    Move-Item "$backupRoot\WindowsImageBackup\*" "$backupDir\WindowsImageBackup" -Force

    # Delete empty WindowsImageBackup directory at drive root
    Remove-Item "$backupRoot\WindowsImageBackup" -Recurse -Force
    WriteHost-Timestamped "Finished processing."
    WriteHost-Timestamped "Starting Exdupe..."

    ## Get .full file name
    $enumRes = [System.IO.Directory]::EnumerateFiles($exdupesDir, "*.full")
    if ($enumRes.Count -le 0){
        $dotFullName = Run-CreateDotFull -srcDir:$backupDir -destDir:$exdupesDir -outputFileName:$exdupesName -exdupeExePath:$exdupePath
    }
    else{
        $dotFullName = [System.IO.Path]::GetFileName($enumRes[0])
    }

    # Run exdupe
    Run-CreateDiff $backupDir $exdupesDir $dotFullName

    WriteHost-Timestamped "Deleting original backup image..."

    # Delete original backup
    Remove-Item "$backupDir\*" -Recurse -Force

    WriteHost-Timestamped "Original backup image deleted successfully"

    # Stop stopwatch
    $stopwatch.Stop()

    # Create final message
    $finalMessage = "Backup of '$drive' was completed successfully in " + $stopwatch.Elapsed.TotalSeconds + " seconds"

    # Write and email final message
    ""
    WriteHost-TimeStamped $finalMessage
    Send-Email "Backup successful" $finalMessage
}
catch [System.Exception]{
    $stopwatch.Stop()
    ""
    WriteHost-Timestamped ("ERR! > " + $_.Exception.Message)
    WriteHost-Timestamped ("Backup failed after " + $stopwatch.Elapsed.TotalSeconds + " of execution")
    Send-Email "BACKUP FAILED" ("Backup of $machineName failed with message " + $_.Exception.Message + " after " + $stopwatch.Elapsed.TotalSeconds + " of execution")
}
