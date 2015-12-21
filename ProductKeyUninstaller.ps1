function Get-ActivationID{
    $output = cscript C:\Windows\System32\slmgr.vbs /dlv
    $activationID = $output | Where-Object { $_.Contains("Activation ID") }
    return $activationID.Replace("Activation ID:", "").Trim()
}

function Uninstall-ProductKey{
    $activationID = Get-ActivationID
    cscript C:\Windows\System32\slmgr.vbs /upk $activationID
}

# Uninstall the product key
Uninstall-ProductKey