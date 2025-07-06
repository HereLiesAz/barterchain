param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,
    [Parameter(Mandatory=$true)]
    [string]$OutputFilePath
)
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
Get-ChildItem -Path $ProjectPath -Recurse -File | ForEach-Object {
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
