############ CONFIG ############
<##>    $version = "1.0"    ####
################################

""
"STORAGE-TIER FILE PINNER v$version"
"-----------------------------"
""

# Get file to pin
$filePath = Read-Host "Path to file"

# Check that file exists
while ([System.IO.File]::Exists($filePath).ToString() -eq "False"){
    $filePath = Read-Host "File does not exist!  Please re-enter the path"
}
""

# Read out storage tiers
$storageTiers = Get-StorageTier -MediaType SSD
for ($i=0; $i -lt $storageTiers.Count; $i++){
    $str = [System.String]::Format("[{0}] {1}", $i, $storageTiers[$i].FriendlyName)
    $str
}

# Get tier number
""
$tn = Read-Host "Pin to tier number"

# Get storage tier
$tier = Get-StorageTier -FriendlyName $storageTiers[$tn].FriendlyName

# Set File Storage Tier to SSD
Set-FileStorageTier -DesiredStorageTier $tier -FilePath $filePath