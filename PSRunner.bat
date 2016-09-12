:: The purpose of this script is to execute a powershell script and bypass the system execution policy

:: Usage:
::    PSrunner.bat "<NameOfPowerShellScript.ps1>"

powershell.exe -ExecutionPolicy "Unrestricted" -File "%1"