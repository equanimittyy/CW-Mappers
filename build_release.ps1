# Zips the mappers into "Unit Mappers v<um_version>.zip" for the mapper update channel. The ZIP holds what the
# app's Release build copies into dist\unit mappers\attila: this folder without its repo files.
# The default output is the main repo's CW Staging\gdrive_host, never this folder, because the Release build
# ships every file in it. See the release steps in the main repo's docs/info/dev/staging.md.
param(
    [string]$OutDir = [IO.Path]::Combine($PSScriptRoot, '..', 'CW Staging', 'gdrive_host')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

$root = $PSScriptRoot
$repoFiles = @('.gitattributes', 'README.md', 'build_release.cmd', 'build_release.ps1')

$versionText = Get-Content -LiteralPath (Join-Path $root 'um_version.txt') -Raw
if ($versionText -notmatch 'version="(\d+(\.\d+){0,3})"') {
    throw 'um_version.txt has no version="X.Y.Z".'
}
$version = $Matches[1]
$OutDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutDir)
if (-not (Test-Path -LiteralPath (Split-Path -Parent $OutDir))) {
    throw "$(Split-Path -Parent $OutDir) does not exist. Clone this repo into the main repo, or pass -OutDir."
}
$zipPath = [IO.Path]::Combine($OutDir, "Unit Mappers v$version.zip")

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
if (Test-Path -LiteralPath $zipPath) {
    Write-Host "[CW-Mappers] Replacing $zipPath"
    Remove-Item -LiteralPath $zipPath
}

$count = 0
$zip = [IO.Compression.ZipFile]::Open($zipPath, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -File -Force) {
        $rel = $file.FullName.Substring($root.Length + 1).Replace('\', '/')
        if ($rel.StartsWith('.git/') -or $repoFiles -contains $rel) { continue }
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $rel, [IO.Compression.CompressionLevel]::Optimal) | Out-Null
        $count++
    }
}
finally {
    $zip.Dispose()
}

Write-Host ('[CW-Mappers] {0}: {1} files.' -f $zipPath, $count)
