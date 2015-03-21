$rootPath = [System.IO.Path]::GetFullPath("C:\Adobe Photoshop CC 2014 v15.1 WIN64\")

removeExt $rootPath

## Function to remove extension
function removeExt{
param([String]$pathStr)
    $path = [System.IO.Path]::GetFullPath($pathStr)
    $directories = [System.IO.Directory]::EnumerateDirectories($path)
    $files = [System.IO.Directory]::EnumerateFiles($path)

    foreach ($file in $files){
        if ([System.IO.Path]::GetExtension($file) -eq ".!ut"){
            $f = [System.IO.Path]::GetFileName($file)
            $f = $f.Replace(".!ut", "")
            [System.IO.Path]::
        }        
    }

    <#foreach ($directory in $directories){
        removeExt $directories
    }#>
}