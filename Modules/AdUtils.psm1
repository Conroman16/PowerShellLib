Import-Module .\NotepadUtils.psm1

function Get-UserGroups{
param([string]$UserName)
    $groups = Get-ADUser $UserName -Properties MemberOf | select -ExpandProperty MemberOf | % { (Get-ADGroup $_).Name }
    Open-Notepad ($groups -join $([Environment]::NewLine)) "AD Groups for '$UserName'"
}