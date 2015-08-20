###
# Console utility module
###

function Prompt-Host{
param([string]$message)
    while($true){
        Write-Host "$message (Y / N)?"
        $res = Read-Host

        if ($res -ieq "Y"){
            return $true
        }
        elseif ($res -ieq "N"){
            return $false
        }
    }
}