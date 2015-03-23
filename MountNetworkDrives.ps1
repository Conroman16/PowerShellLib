# Get current user's User Name
$name = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name;

# If it's a domain name, remove the domain info
if ($name.Contains('\')){
    $name = $name.Substring($name.LastIndexOf('\') + 1);
}

# Capitalize the first letter to keep things pretty
$name = $name.Chars(0).ToString().ToUpper() + $name.Substring(1)

# Set drive mappings
$mappings = @{
    "U" = "`"\\PLEX\Plex`"";
    "V" = "`"\\TESLA\Backup`"";
    "W" = "`"\\TESLA\$name$`"";
    "X" = "`"\\TESLA\TWN Storage`"";
    "Y" = "`"\\TBOX\Torrents`"";
    "Z" = "`"\\TBOX\TorrentDrop`"";
};
$mappings = $mappings.GetEnumerator() | Sort-Object Name

# Map drives
for ($i=0; $i -lt $mappings.Count; $i++){
    $cmd = [System.String]::Format("net use {0}: {1} /persistent:yes", $mappings[$i].Key, $mappings[$i].Value)
    iex $cmd  # Remove 'iex' to print out commands instead of run them
}