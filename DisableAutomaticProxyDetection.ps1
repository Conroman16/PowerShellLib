<#
    "Automatic Proxy Detection" Disabler

    This script disables the "Automatic Proxy Detection" setting in which has a
    durastic impact on the performance of WebDAV file transfers.  The setting
    is burried in Internet Explorer, so this script eliminates the trouble of
    locating it.

    Issue description:
    - https://support.microsoft.com/en-us/kb/2445570
#>

# Path to key we want to change
$keyPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections"

# Name of key we want to change
$keyName = "DefaultConnectionSettings"

# Index of setting we want to change in byte[] array
$byteArrIndex = 8

# -------------
# | HEX | INT | # Both work
# | --- | --- | # Menu location: Internet Explorer > Tools > Internet Options > Connection > LAN Settings
# | 01  |  1  | = NEITHER -- Neither box checked
# | 05  |  5  | = ONLY ----- Only "Use Automatic Configuration Script" checked
# | 09  |  9  | = ONLY ----- Only "Automatically Detect Settings" checked
# | 0d  | 13  | = BOTH ----- Both boxes checked
# -------------
$settingValue = 0x01

# Get key
$property = Get-ItemProperty -Path $keyPath
$key = $property.$keyName

# Set new value
$key[$byteArrIndex] = $settingValue
about
# Set key value
Set-ItemProperty -Path $keyPath -Name $keyName -Value $key

## BACKUP
## ------
<#
  Value from Connor's machine

    46 00 00 00 07 00 00 00
    01 00 00 00 00 00 00 00 
    00 00 00 00 00 00 00 00
    01 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
#>