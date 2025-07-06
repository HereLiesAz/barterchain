param (
    # OutputFilePath is no longer a mandatory parameter as it will be set relative to the script's location.
    # [Parameter(Mandatory=$true)]
    # [string]$OutputFilePath
)

# Assume the project root is the directory where this script is stored
$ProjectPath = $PSScriptRoot

# Define the output file path relative to the project root
$OutputFileName = "flutter_project_backup.txt" # You can change this name
$OutputFilePath = Join-Path -Path $ProjectPath -ChildPath $OutputFileName

$excludeDirs = @(
    "build",
    ".dart_tool",
    ".idea",
    "ios/Pods",
    "ios/.symlinks",
    "android/.gradle",
    "android/app/build",
    "windows/build",
    "linux/build",
    "macos/build",
    "web/build",
    "xcuserdata",
    "DerivedData"
)
$excludeFiles = @(
    "pubspec.lock",
    ".packages",
    ".flutter-plugins",
    ".flutter-plugins-dependencies",
    "*.iml",
    "*.ipr",
    "*.iws",
    "*.DS_Store",
    "Thumbs.db",
    "*.log",
    "*.apk",
    "*.ipa",
    "*.exe",
    "*.app",
    "*.dmg",
    "*.deb",
    "*.rpm",
    "*.png",
    "*.jpg",
    "*.jpeg",
    "*.gif",
    "*.bmp",
    "*.webp",
    "*.svg",
    "*.ico",
    "*.ttf",
    "*.otf",
    "*.woff",
    "*.woff2",
    "*.mp3",
    "*.wav",
    "*.ogg",
    "*.mp4",
    "*.avi",
    "*.mov",
    "*.flv"
)
if (-not (Test-Path $ProjectPath -PathType Container)) {
    Write-Error "Error: Project path '$ProjectPath' does not exist."
    exit 1
}
Clear-Content $OutputFilePath -ErrorAction SilentlyContinue
Write-Host "Backing up Flutter project from '$ProjectPath' to '$OutputFilePath'..."

# Get the full path of the current script to exclude it
$scriptFullPath = $MyInvocation.MyCommand.Path

Get-ChildItem -Path $ProjectPath -Recurse -File | ForEach-Object {
    $currentFileFullPath = $_.FullName

    # Exclude the script itself and the output backup file
    if ($currentFileFullPath -eq $scriptFullPath -or $currentFileFullPath -eq $OutputFilePath) {
        Write-Host "  Skipping (self/backup file): $($_.Name)"
        return # Skip to the next file
    }

    $relativePath = $_.FullName.Substring($ProjectPath.Length).TrimStart('\/')
    $isExcludedDir = $false
    foreach ($dir in $excludeDirs) {
        if ($relativePath -like "$dir/*" -or $relativePath -eq $dir) {
            $isExcludedDir = $true
            break
        }
    }
    $isExcludedFile = $false
    foreach ($filePattern in $excludeFiles) {
        if ($_.Name -like $filePattern) {
            $isExcludedFile = $true
            break
        }
    }
    if (-not $isExcludedDir -and -not $isExcludedFile) {
        try {
            $content = Get-Content $_.FullName -Raw -Encoding UTF8
            Add-Content -Path $OutputFilePath -Value "--- FILE_PATH: $relativePath ---" -Encoding UTF8
            Add-Content -Path $OutputFilePath -Value $content -Encoding UTF8
            if ($content -notmatch "\n$") {
                Add-Content -Path $OutputFilePath -Value "`n" -Encoding UTF8
            }
            Write-Host "  Backed up: $relativePath"
        } catch {
            Write-Warning "Could not read file '$relativePath': $($_.Exception.Message)"
        }
    }
}
Write-Host "Backup complete."
