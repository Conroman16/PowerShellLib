Function Start-NodeJsCmd{
param([string]$command, [string]$cwd = [System.Environment]::CurrentDirectory, [bool]$waitForExit = $false)
    $nodevarsPath = "$env:ProgramFiles\nodejs\nodevars.bat"
    $argStr = "/k `"`"$nodevarsPath`""
    $argStr
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

Function Ensure-NodeModules{
param([string]$path)
    # Check if 'node_modules' exists
    # If it doesn't, run 'npm install' here and wait for completion
    if ([System.IO.Directory]::Exists($path + "\node_modules") -eq $false){
        "Unable to locate 'node_modules' in '$path'... Running 'npm install'"
        StartNodeJsCmd $path "npm install & exit" $true
    }
}