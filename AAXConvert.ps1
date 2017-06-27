####
##  AAXConvert.ps1 "C:\Users\connor\Desktop\KingsCage\KingsCage_ep6_QHCF48H2s8JRMEGO5kHh8mowNe6vrJWydNewyfVKtBQa9uzmBen9QjvH2l01.aax" 149x043
####

param(
    [string]$InputFile = $null,
    [string]$ActivationCode = $null,
    [string]$OutputFile = $null,
    [switch]$mp3 = $false,
    [switch]$aac = $false,
    [switch]$flac = $false,
    [string]$bitrate = $null
)

if (!$InputFile -or !$ActivationCode){
    "Invalid file name or activation code"
    exit 1
}

if (!$OutputFile){
    $OutputFile = [IO.Path]::GetFileNameWithoutExtension($InputFile)
}
else{
    $OutputFile = [IO.Path]::GetFileNameWithoutExtension($OutputFile)
}

if (!$mp3 -and !$aac -and !$flac){
    $mp3 = $true
}

if ($flac){
    ffmpeg -activation_bytes $ActivationCode -i $InputFile -vn -c:a flac "$OutputFile.flac"
}

if ($mp3){
    if (!$bitrate){
        $bitrate = 320
    }
    ffmpeg -activation_bytes $ActivationCode -i $InputFile -c:a libmp3lame -b "$($bitrate)k" "$OutputFile.mp3"
}

if ($aac){
    if (!$bitrate){
        $bitrate = 256
    }
    ffmpeg -activation_bytes $ActivationCode -i $InputFile -c:a aac -b:a "$($bitrate)k" "$OutputFile.m4a"
}