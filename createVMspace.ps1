<#
 #
 #   Creates a new simple virtual disk in the "SP1" storage pool called "VMspace" with 200GB SSD and 500GB HDD qith a 16GB write-back cache
 #
 #>

 "Getting SSD Tier..."
# Get storage tiers
$ssds = Get-StorageTier -FriendlyName Microsoft_SSD_Template
"Completed.  Getting HDD Tier..."
$hdds = Get-StorageTier -FriendlyName Microsoft_HDD_Template
"Completed.  Creating VMspace..."

# Create virtual disk
New-VirtualDisk -StoragePoolFriendlyName "SP1" -FriendlyName "VMspace" -StorageTiers @($ssds,$hdds) -StorageTierSizes @(200GB,500GB) -ResiliencySettingName simple -WriteCacheSize 16gb
"Completed."