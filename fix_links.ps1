$basePath = "c:\Users\007\Desktop\apple"
$files = Get-ChildItem -Path $basePath -Include *.html,*.js -Recurse | Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.FullName -notmatch '\\node_modules\\' }

foreach ($f in $files) {
    if (-not (Test-Path $f.FullName)) { continue }

    $content = Get-Content -Raw -Encoding UTF8 $f.FullName
    $newContent = $content

    $relPath = $f.FullName.Substring($basePath.Length + 1)
    $parts = $relPath.Split('\')
    $depth = $parts.Count - 1
    
    $rootIndex = ""
    if ($depth -eq 0) {
        $rootIndex = "index.html"
    } else {
        for ($i = 0; $i -lt $depth; $i++) {
            if ($i -eq 0) { $rootIndex += ".." } else { $rootIndex += "/.." }
        }
        $rootIndex += "/index.html"
    }

    # Replace href="https://*.apple.com/*"
    $newContent = [regex]::Replace($newContent, 'href=["'']https?://(?:www\.|store\.|support\.)?apple\.com[^"'']*["'']', 'href="' + $rootIndex + '"', 'IgnoreCase')

    # Replace JSON "https://*.apple.com/*"
    $newContent = [regex]::Replace($newContent, '["'']https?://(?:www\.|store\.|support\.)?apple\.com[^"'']*["'']', '"' + $rootIndex + '"', 'IgnoreCase')

    if ($content -ne $newContent) {
        Set-Content -Path $f.FullName -Value $newContent -Encoding UTF8
        Write-Host "Updated $($f.FullName)"
    }
}
