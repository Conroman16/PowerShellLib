$name = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name;
if ($name.Contains('\')){
    $name = $name.Substring($name.LastIndexOf('\') + 1);
}
$name = $name.Chars(0).ToString().ToUpper() + $name.Substring(1)
$mappings = @{
    "V" = "`"\\TESLA\Backup`"";
    "W" = "`"\\TESLA\$name$`"";
    "X" = "`"\\TESLA\TWN Storage`"";
    "Y" = "`"\\TBOX\Torrents`"";
    "Z" = "`"\\TBOX\TorrentDrop`"";
};
$mappings = $mappings.GetEnumerator() | Sort-Object Name
for ($i=0; $i -lt $mappings.Count; $i++){
    $cmd = [System.String]::Format("net use {0}: {1} /persistent:yes", $mappings[$i].Key, $mappings[$i].Value)
    iex $cmd
}