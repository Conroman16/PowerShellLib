Function StartNodeJsCmd{
param([string]$cwd, [string]$command, [bool]$waitForExit = $false)
    $nodevarsPath = "C:\Program Files\nodejs\nodevars.bat"
    $argStr = "/k `"`"$nodevarsPath`" & cd `"$cwd`" & $command`""

    # Initialize process
    $nodeCmdProcStartInfo = New-Object System.Diagnostics.ProcessStartInfo "cmd"
    $nodeCmdProcStartInfo.Verb = "runas"
    $nodeCmdProcStartInfo.Arguments = $argStr

    # Start process
    $proc = [System.Diagnostics.Process]::Start($nodeCmdProcStartInfo)

    # Wait for exit if necessary
    if ($waitForExit -eq $true){
        $proc.WaitForExit()
    }
}