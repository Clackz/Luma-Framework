<#
.SYNOPSIS
    Adds the licence, the user-facing README, provenance and checksums to an extracted package.

.DESCRIPTION
    Both packaging paths in .github/workflows/build.yml call this script, so the two archives
    cannot drift apart:

      Kind = full    the upstream-style archive that `build` produces: addon, shader mounts,
                     ReShade as dxgi.dll and the NGX DLSS runtime. Directly installable on a
                     clean game folder.
      Kind = nexus   the filtered archive that `nexus-package` produces: no dxgi.dll, no NGX
                     runtime. For the Nexus upload.

    It writes into the archive root:
      LICENSE.md       copied from the repository root (redistribution requires it)
      README.txt       from Scripts/Full-README.txt or Scripts/Nexus-README.txt
      build-info.txt   version, commit, configuration, addon hash
      SHA256SUMS.txt   hash of every other file, written last so it cannot list itself

    Run as a child process; a non-zero exit code means the step failed.

.PARAMETER StageDir
    Directory holding the extracted package. Must contain exactly one .addon at its root.

.PARAMETER Kind
    full or nexus - selects the README source and the wording of build-info.txt.

.PARAMETER Version
    Release version, without a leading "v". Names the archive and is recorded in build-info.txt.

.EXAMPLE
    pwsh -File Scripts/package-metadata.ps1 -StageDir stage -Kind full -Version 1.3 -Commit abc1234
#>
param(
    [Parameter(Mandatory = $true)][string]$StageDir,
    [Parameter(Mandatory = $true)][ValidateSet("full", "nexus")][string]$Kind,
    [Parameter(Mandatory = $true)][string]$Version,
    [string]$Configuration = "Publishing-Release / x64 (not TEST, not DEVELOPMENT)",
    [string]$Commit = "unknown",
    [string]$RefName = "unknown",
    [string]$RunId = "local",
    [string]$RunNumber = "local"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

if (-not (Test-Path -LiteralPath $StageDir -PathType Container)) {
    Write-Host "::error::$StageDir does not exist"
    exit 1
}
$StageDir = (Resolve-Path -LiteralPath $StageDir).Path.TrimEnd('\', '/')

# The package is useless without its mod, and every later step assumes one addon at the root.
$addon = @(Get-ChildItem -LiteralPath $StageDir -Filter *.addon -File)
if ($addon.Count -ne 1) {
    Write-Host "::error::expected exactly one .addon at the package root, found $($addon.Count)"
    exit 1
}

# 1. Licence. The Luma licence allows redistribution with attribution and asks to be
#    contacted first for commercial use, so shipping the text is not optional.
$licence = Join-Path $repoRoot "LICENSE.md"
if (-not (Test-Path -LiteralPath $licence)) {
    Write-Host "::error::LICENSE.md is missing from the repository root"
    exit 1
}
Copy-Item -LiteralPath $licence -Destination (Join-Path $StageDir "LICENSE.md") -Force

# 2. The README that ships inside the archive. It is user-facing text that has to be re-read
#    before every release, so it lives in its own file rather than in a here-string nobody
#    opens. See RELEASE.md.
$readmeName = if ($Kind -eq "nexus") { "Nexus-README.txt" } else { "Full-README.txt" }
$readmePath = Join-Path $PSScriptRoot $readmeName
if (-not (Test-Path -LiteralPath $readmePath)) {
    Write-Host "::error::Scripts/$readmeName is missing"
    exit 1
}
$readme = (Get-Content -LiteralPath $readmePath -Raw) -replace "`r`n", "`n"
if ([string]::IsNullOrWhiteSpace($readme)) {
    Write-Host "::error::Scripts/$readmeName is empty"
    exit 1
}
Write-Host "--- README shipped in this archive (Scripts/$readmeName) ---"
Write-Host $readme
Write-Host "--- end README ---"
Set-Content -Path (Join-Path $StageDir "README.txt") -Value $readme -Encoding utf8

# 3. Provenance, so a build can always be traced back to a commit. The PE timestamp is worth
#    recording separately: it is set at link time, so it also tells a repackaged binary from a
#    freshly compiled one.
function Get-PeTimeStamp([string]$Path) {
    try {
        $fs = [System.IO.File]::OpenRead($Path)
        try {
            $br = New-Object System.IO.BinaryReader($fs)
            $fs.Position = 0x3C
            $peOffset = $br.ReadInt32()
            $fs.Position = $peOffset + 8
            $seconds = $br.ReadUInt32()
            return ([DateTimeOffset]::FromUnixTimeSeconds($seconds)).UtcDateTime.ToString("yyyy-MM-ddTHH:mm:ssZ")
        } finally { $fs.Dispose() }
    } catch { return "unavailable" }
}

$packageKind = if ($Kind -eq "nexus") {
    "nexus (no dxgi.dll / nvngx_dlss.dll, for the Nexus upload)"
} else {
    "full (ReShade as dxgi.dll and the NGX DLSS runtime included, for a clean install)"
}

$addonHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $addon[0].FullName).Hash.ToLowerInvariant()
$buildInfo = @(
    "Luma for Snowbreak: Containment Zone - $Kind package",
    "version:       $Version",
    "package:       $packageKind",
    "commit:        $Commit",
    "ref:           $RefName",
    "workflow run:  $RunId (build $RunNumber)",
    "configuration: $Configuration",
    "addon:         $($addon[0].Name)",
    "addon size:    $($addon[0].Length) bytes",
    "addon sha256:  $addonHash",
    "addon PE TimeDateStamp: $(Get-PeTimeStamp -Path $addon[0].FullName)",
    "generated:     $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))"
) -join "`n"
Set-Content -Path (Join-Path $StageDir "build-info.txt") -Value $buildInfo -Encoding utf8

# 4. Checksums, written after everything else so the file cannot end up listing itself.
$sums = Get-ChildItem -LiteralPath $StageDir -Recurse -File | Sort-Object FullName | ForEach-Object {
    $rel = $_.FullName.Substring($StageDir.Length).TrimStart('\', '/') -replace '\\', '/'
    "$((Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash.ToLowerInvariant())  $rel"
}
Set-Content -Path (Join-Path $StageDir "SHA256SUMS.txt") -Value $sums -Encoding utf8

Write-Host "Packaged as $Kind package, version $Version, $(@($sums).Count) files hashed:"
Get-ChildItem -LiteralPath $StageDir -Recurse -File | ForEach-Object {
    Write-Host "  $($_.FullName.Substring($StageDir.Length).TrimStart('\', '/'))"
}
