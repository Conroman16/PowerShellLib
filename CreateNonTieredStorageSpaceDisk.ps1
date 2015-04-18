#############################################################################
#############################################################################
####                                                                     ####
####             Creates a new non-tiered virtual disk using             ####
####                   the parameters specified below                    ####
####                                                                     ####
#############################################################################
################################ Disk Info ##################################
####           Configuration info for 'New-VirtualDisk' cmdlet           ####
####      https://technet.microsoft.com/en-us/library/hh848643.aspx      ####
####                                                                     ####
<##>  $storagePool = "Pool1"         # Pool in which to create disk      ####
<##>  $diskName = "Disk1"            # Name of new disk                  ####
<##>  $diskSize = "2048gb"           # Size of new disk                  ####
<##>  $writeCacheSize = "8gb"        # Writeback cache size              ####
<##>  $resiliencySetting = "Mirror"  # Simple, Mirror, or Parity         ####
<##>  $provisioningType = "Thin"     # Fixed, Thin, or Unknown           ####
####                                                                     ####
#############################################################################
############################# Partition Info ################################
####                                                                     ####
<##>  $partitionStyle = "GPT"        # MBR or GPT                        ####
<##>  $fileSystem = "ReFS"           # NTFS, ReFS, exFAT, FAT32, or FAT  ####
<##>  $partitionName = "Partition1"  # Name of new partition             ####
####                                                                     ####
#############################################################################
########################### Deduplication Info ##############################
####                                                                     ####
<##>  $enableDeduplication = $true   # $true or $false                   ####
<##>  $minimumFileAge = 1            # Age in days before dedup occurs   ####
####                                                                     ####
#############################################################################
#############################################################################

""
"Creating $diskName..."

# Create command
$cmd = "New-VirtualDisk -StoragePoolFriendlyName `"$storagePool`" -FriendlyName `"$diskName`" -ResiliencySettingName $resiliencySetting -WriteCacheSize $writeCacheSize -ProvisioningType $provisioningType -Size $diskSize"

# Run command to create virtual disk
$cmdRes = iex $cmd

"Disk `"$diskName`" was created successfully!"
""
"Formatting new disk..."

# Stop ShellHWDetection service so we don't get the UI popup about formatting
# the disk before it can be used
Stop-Service -Name ShellHWDetection

# Get newly created disk
$newDisk = Get-Disk | Where PartitionStyle -eq RAW | Where Size -eq $cmdRes.Size

# Initialize and format newly created disk
$newVolume = $newDisk | Initialize-Disk -PartitionStyle $partitionStyle -PassThru | 
New-Partition -AssignDriveLetter -UseMaximumSize | 
Format-Volume -FileSystem $fileSystem -NewFileSystemLabel $partitionName -Confirm:$false

"Format completed successfully!"

# Start the ShellHWDetection service again
Start-Service -Name ShellHWDetection

# Enable data deduplication if desired (NTFS only)
if ($enableDeduplication -eq $true -and $newVolume.FileSystem.ToLower() -eq "ntfs"){
    ""
    "Enabling Data Deduplication..."
    $dl = [String]::Format("{0}:", $newVolume.DriveLetter)
    $r = Enable-DedupVolume $dl
    Set-DedupVolume $dl -MinimumFileAgeDays $minimumFileAge
    "Data Deduplication enabled successfully!"
}

# Get user-friendly size
$labels = @("B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
$runs = 0
$size = $newVolume.SizeRemaining
$label = ""
while (1){
    if ($size / 1024 -lt 1){
        $label = [String]::Format("{0:0.##} {1}", $size, $labels[$runs])
        break
    }
    else{
        $runs++
        $size = $size / 1024
    }
}

## Display final output
$fo = [String]::Format("The {0} partiton `"{1}`" was created successfully and mounted at {2}: with {3} of free space.{4}", $newVolume.FileSystem, $newVolume.FileSystemLabel, $newVolume.DriveLetter, $label, [Environment]::NewLine)
if ($enableDeduplication -eq $true){
    $fo += "Data Deduplication was enabled with a minimum file age of $minimumFileAge "
    if ($minimumFileAge -gt 1){
        $fo += "days."
    }
    else{
        $fo += "day."
    }
}
""
Write-Host $fo -ForegroundColor "Green"