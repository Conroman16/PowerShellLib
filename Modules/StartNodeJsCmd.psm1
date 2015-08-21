Function StartNodeJsCmd{
param([string]$cwd, [string]$command, [bool]$waitForExit = $false)
    $nodevarsPath = "$env:ProgramFiles\nodejs\nodevars.bat"
    $argStr = "/k `"`"$nodevarsPath`""
    if (![string]::IsNullOrWhiteSpace($cwd)){
        $argStr = $argStr + " & cd `"$cwd`""
    }
    if (![string]::IsNullOrWhiteSpace($command)){
        $argStr = $argStr + " & $command"
    }
    $argStr += "`""

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