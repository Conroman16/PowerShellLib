#############################################################################
#############################################################################
####                                                                     ####
####     Creates a new tiered virtual disk in the 'SP1' storage pool     ####
####               using the parameters specified below                  ####
####                                                                     ####
#############################################################################
################################ Disk Info ##################################
####                                                                     ####
<##>  $diskName = "Test1"                                                ####
<##>  $HDD_tierSize = "5gb"                                              ####
<##>  $SSD_tierSize = "2gb"                                              ####
<##>  $writeCacheSize = "2gb"                                            ####
<##>  $resiliencySetting = "Simple"  # Simple, Mirror, or Parity         ####
####                                                                     ####
#############################################################################
############################# Partition Info ################################
####                                                                     ####
<##>  $partitionStyle = "GPT"        # MBR or GPT                        ####
<##>  $fileSystem = "ReFS"           # NTFS, ReFS, exFAT, FAT32, or FAT  ####
<##>  $partitionName = "Test1"                                           ####
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
$cmd = "New-VirtualDisk -StoragePoolFriendlyName `"SP1`" -FriendlyName $diskName -StorageTiers @($ssds,$hdds) -StorageTierSizes @($SSD_tierSize,$HDD_tierSize) -ResiliencySettingName $resiliencySetting -WriteCacheSize $writeCacheSize"

# Run command to create virtual disk
$cmdRes = iex $cmd

"Disk `"$diskName`" was created successfully!"
""
"Formatting new disk..."
[System.Threading.Thread]::Sleep(500)

# Get newly created disk
$newDisk = Get-Disk | Where PartitionStyle -eq RAW | Where Size -eq $cmdRes.Size

# Initialize and format newly created disk
$newVolume = $newDisk | Initialize-Disk -PartitionStyle $partitionStyle -PassThru | 
New-Partition -AssignDriveLetter -UseMaximumSize | 
Format-Volume -FileSystem $fileSystem -NewFileSystemLabel $partitionName -Confirm:$false

# Get user-friendly size
$labels = @("B", "KB", "MB", "GB", "TB")
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
[String]::Format("The {0} partiton `"{1}`" was successfully created and mounted at {2}: with {3} of free space", $newVolume.FileSystem, $newVolume.FileSystemLabel, $newVolume.DriveLetter, $label)