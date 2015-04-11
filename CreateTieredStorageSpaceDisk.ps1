#############################################################################
#############################################################################
####                                                                     ####
####             Creates a new tiered virtual disk using                 ####
####                 the parameters specified below                      ####
####                                                                     ####
#############################################################################
################################ Disk Info ##################################
####                                                                     ####
<##>  $storagePool = "Pool1"         # Pool in which to create disk      ####
<##>  $diskName = "Test1"            # Name of new disk                  ####
<##>  $HDD_tierSize = "123gb"        # Size of HDD storage tier          ####
<##>  $SSD_tierSize = "45gb"         # Size of SSD storage tier          ####
<##>  $writeCacheSize = "67gb"       # Size of writeback cache           ####
<##>  $resiliencySetting = "Simple"  # Simple, Mirror, or Parity         ####
####                                                                     ####
#############################################################################
############################# Partition Info ################################
####                                                                     ####
<##>  $partitionStyle = "GPT"        # MBR or GPT                        ####
<##>  $fileSystem = "ReFS"           # NTFS, ReFS, exFAT, FAT32, or FAT  ####
<##>  $partitionName = "Test1"       # Name of new partition             ####
####                                                                     ####
#############################################################################
########################### Deduplication Info ##############################
####                                                                     ####
<##>  $enableDeduplication = $true   # $true or $false                   ####
<##>  $minimumFileAge = 1            # Days                              ####
####                                                                     ####
#############################################################################
#############################################################################

 "Getting SSD Tier..."
# Get storage tiers
$ssds = Get-StorageTier -FriendlyName Microsoft_SSD_Template
"Completed.  Getting HDD Tier..."
$hdds = Get-StorageTier -FriendlyName Microsoft_HDD_Template
"Completed.  Creating VMspace..."

##
## TODO: Figure out why this is breaking
##
# Create virtual disk
$cmd = "New-VirtualDisk -StoragePoolFriendlyName `"$storagePool`" -FriendlyName `"$diskName`" -StorageTiers $ssds,$hdds -StorageTierSizes $SSD_tierSize,$HDD_tierSize -ResiliencySettingName $resiliencySetting -WriteCacheSize $writeCacheSize"

# Run command to create virtual disk
$cmdRes = iex $cmd

"Disk `"$diskName`" was created successfully!"
""
"Formatting new disk..."

# Wait for new disk to mount after creation
# This might need to be adjusted if the machine has a slow storage interface
# There might be a better way to do this than to just wait half a second
[System.Threading.Thread]::Sleep(500)

# Get newly created disk
$newDisk = Get-Disk | Where PartitionStyle -eq RAW | Where Size -eq $cmdRes.Size

# Initialize and format newly created disk
$newVolume = $newDisk | Initialize-Disk -PartitionStyle $partitionStyle -PassThru | 
New-Partition -AssignDriveLetter -UseMaximumSize | 
Format-Volume -FileSystem $fileSystem -NewFileSystemLabel $partitionName -Confirm:$false

# Get user-friendly size
$labels = @("B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
$runs = 0
$size = $newVolume.SizeRemaining
$label = ""
while (1){
    if ($size / 1024 -lt 1){
        $label = [String]::Format("{0} {1}", $size, $labels[$runs])
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