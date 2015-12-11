<#
    "Automatic Proxy Detection" Disabler

    # Disables the "Automatic Proxy Detection" setting which has a
    durastic impact on the performance of the WebDAV protocol.  The setting
    is burried in Internet Explorer, so this script eliminates the trouble of
    locating it and setting it correctly.

    # Issue description:
      - https://support.microsoft.com/en-us/kb/2445570

    # This script sets the value of the 9th byte in the 'DefaultConnectionSettings' registry 
    key binary data.  This key contains the data for the 'LAN Settings' dialog.  This dialog 
    is found in Internet Explorer under Tools > Internet Options > Connections (tab) > LAN Settings

    # Example of key data:
      46 00 00 00 07 00 00 00
      01 00 00 00 00 00 00 00 
      00 00 00 00 00 00 00 00
      01 00 00 00 00 00 00 00
      00 00 00 00 00 00 00 00
      00 00 00 00 00 00 00 00
      00 00 00 00 00 00 00 00

      # Explanation of key data:
      1. Byte 0 is always either 0x3C (60) or 0x46 (70).  (?? - Not much documentation about this).
      2. Bytes 1 - 3 are all 0x0 (0).
      3. Byte 4 is a counter that increments each settings are modified from the LAN Settings dialog.
         Seems useless but must have a value.
      4. Bytes 5 - 7 are all 0x0 (0).
      5. Byte 8 is different depending on your settings:
         (Menu location: Internet Explorer > Tools > Internet Options > Connections (tab) > LAN Settings)
         - 0x01 (1)  = No boxes checked
         - 0x03 (3)  = Only "Use a proxy server for your LAN" checked
         - 0x05 (5)  = Only "Use Automatic Configuration Script" checked
         - 0x09 (9)  = Only "Automatically Detect Settings" checked
         - 0x0b (11) = Both "Automatically Detect Settings" and "Use a proxy server for your LAN" checked
         - 0x0d (13) = Both "Automatically Detect Settings" and "Use Automatic Configuration Script" checked
         - 0x0f (15) = All three boxes checked
      6. Bytes 9 - B (9-11) are all 0x0 (0).
      7. Byte C (12) contains the length of the proxy server address (ex: 127.0.0.1:80 = 12).
      8. Bytes D - F (13-15) are all 0x0 (0).
      9. Byte 10 (16) contains the proxy server address (ex: 127.0.0.1:80).
      10. Next byte after the address contains the length of any additional information
          (ex: "Bypass proxy server for local addresses" box is checked, this byte would be 0x07 (7)).
          If there is no additional information, the length is 0 and no extra data is appended.
      11. The byte immediately after the additional information is the length of the "Automatic 
          Configuraiton Script" address.
      12. Next three bytes are 0x0 (0).
      13. Next bytes are the "Automatic Configuration Script" address.
      14. After that, 32 zeros are appended.  (?? - Not much documentation about this).
#>

# Path to key we want to change
$keyPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections"

# Name of key we want to change
$keyName = "DefaultConnectionSettings"

# Index of setting we want to change in byte[] array
# (9th byte in array)
$byteArrIndex = 8

# Setting (see #5 above)
$settingValue = 0x01

# Get key
$property = Get-ItemProperty -Path $keyPath
$key = $property.$keyName

# Set new value
$key[$byteArrIndex] = $settingValue

# Set key value
Set-ItemProperty -Path $keyPath -Name $keyName -Value $key

<#
    # Since we're messing with the registry here, it's always good to have a backup.
    This is the value from my (Connor's) machine.  This key is contains all the data
    for the "LAN Settings" dialog, and this backup data represents a dialog with no 
    boxes checked and no fields filled out.

    46 00 00 00 07 00 00 00
    01 00 00 00 00 00 00 00 
    00 00 00 00 00 00 00 00
    01 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
#>