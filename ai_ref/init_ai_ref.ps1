# init_ai_ref.ps1
# Called by LTspice to initialize AI reference files in the current working directory.
# Usage: powershell.exe -ExecutionPolicy Bypass -File init_ai_ref.ps1 -aiRefDir <path>
param(
    [Parameter(Mandatory=$true)]
    [string]$aiRefDir
)

$ErrorActionPreference = 'Stop'

try {

if (-not (Test-Path $aiRefDir -PathType Container)) {
    Write-Error "ai_reference directory not found: $aiRefDir"
    exit 1
}

$cwd = Get-Location
$subDir = Join-Path $cwd 'ltspice_reference'

if (-not (Test-Path $subDir)) {
    New-Item -ItemType Directory -Path $subDir | Out-Null
}

# Copy .md files (excluding README_TOP.md) into ltspice_reference
Get-ChildItem -Path $aiRefDir -Filter '*.md' -File | Where-Object { $_.Name -ne 'README_TOP.md' } | ForEach-Object {
    $dest = Join-Path $subDir $_.Name
    if (-not (Test-Path $dest)) {
        Copy-Item -Path $_.FullName -Destination $dest -ErrorAction Stop
    }
}

# Prepend source file content to README.md, CLAUDE.md, and .github/copilot-instructions.md
# In the future, this will need to detect if the files contain text exactly matching old versions of the source
    function PrependTo([string]$sourcePath, [string]$destPath) {
        if (-not (Test-Path $sourcePath)) { return }
        $topContent = [System.IO.File]::ReadAllBytes($sourcePath)
        $destDir = Split-Path $destPath -Parent
        if ($destDir -and -not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir | Out-Null
        }
        if (Test-Path $destPath) {
            $existing = [System.IO.File]::ReadAllBytes($destPath)
            # Check if file already starts with topContent
            if ($existing.Length -ge $topContent.Length) {
                $alreadyPrepended = $true
                for ($i = 0; $i -lt $topContent.Length; $i++) {
                    if ($existing[$i] -ne $topContent[$i]) {
                        $alreadyPrepended = $false
                        break
                    }
                }
                if ($alreadyPrepended) { return }
            }
            $combined = $topContent + $existing
            [System.IO.File]::WriteAllBytes($destPath, $combined)
        } else {
            [System.IO.File]::WriteAllBytes($destPath, $topContent)
        }
    }

    $readmeTop = Join-Path $aiRefDir 'README_TOP.md'
    $readme = Join-Path $aiRefDir 'README.md'
    PrependTo $readmeTop (Join-Path $cwd 'README.md')
    PrependTo $readme (Join-Path $cwd 'CLAUDE.md')
    PrependTo $readme (Join-Path $cwd '.github' 'copilot-instructions.md')

} catch {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "LTspice init_ai_ref failed:`n`n$($_.Exception.Message)",
        "LTspice",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

exit 0
