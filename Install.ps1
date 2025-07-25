$ModsPath = "C:\Program Files (x86)\Steam\steamapps\common\The Binding of Isaac Rebirth\mods"
$ModsCollectionPath = Get-Item "C:\Users\jorge\Jorge\Archivos de Desarrollo\The Binding of Isaac Repentance Mod's Collection\mods"

Remove-Item -Path "$ModsPath" -Recurse

New-Item -Path $ModsPath -ItemType Directory
Copy-Item -Path "$ModsCollectionPath\*" -Destination $ModsPath -Recurse -Force