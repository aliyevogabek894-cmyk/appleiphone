$domain = "https://www.apple.com"
$basePath = "c:\Users\007\Desktop\apple"

# Navigation mappings (must match those in fix_assets_v3 logic)
$navMappings = @{
    "store"         = "store/index.html";
    "mac"           = "mac/index.html";
    "ipad"          = "ipad/index.html";
    "iphone"        = "iphone/index.html";
    "watch"         = "watch/index.html";
    "vision"        = "vision/index.html";
    "airpods"       = "airpods/index.html";
    "tv-home"       = "tv-home/index.html";
    "entertainment" = "entertainment/index.html";
    "accessories"   = "accessories/index.html";
    "support"       = "support/index.html"
}

$dirs = Get-ChildItem -Path $basePath -Directory -Exclude "node_modules", ".git", "admin", "user"

foreach ($dir in $dirs) {
    $dirName = $dir.Name
    $rawFile = Get-ChildItem -Path $dir.FullName -Filter "apple_*_raw.html" | Select-Object -First 1
    $targetFile = Join-Path $dir.FullName "index.html"

    if ($rawFile) {
        Write-Host "Recovering $dirName from $($rawFile.Name)..."
        $content = Get-Content $rawFile.FullName -Raw
    } elseif (Test-Path $targetFile) {
        Write-Host "Processing existing $targetFile..."
        $content = Get-Content $targetFile -Raw
    } else {
        continue
    }

    # 1. Fix Navigation Links (data-globalnav-item-name)
    foreach ($key in $navMappings.Keys) {
        $localPath = $navMappings[$key]
        $pattern = "data-globalnav-item-name=`"$key`".*?href=`"/.*?/`""
        $replacement = "data-globalnav-item-name=`"$key`" href=`"../$localPath`""
        $content = [regex]::Replace($content, $pattern, $replacement)
        
        # Also catch non-attribute links if any
        $content = $content -replace "href=`"/$key/`"", "href=`"../$localPath`""
    }

    # 2. Fix Assets (root-relative paths that are NOT in navMappings)
    $attributes = "href|src|srcset|srcSet|data-src|data-href|data-srcset|content|action"
    $content = [regex]::Replace($content, "(($attributes)\s*=\s*[`"'])/(?![./])", "`$1$domain/")
    
    # Handle the second/third URLs in a srcset list: ", /"
    $content = $content -replace ', /', ", $domain/"
    
    # 3. Fixed JSON paths logic (prefixing /_next, /metrics, etc.)
    $content = [regex]::Replace($content, "([`"']\s*:\s*[`"'])/(?![./])", "`$1$domain/")
    $content = $content -replace '"assetPrefix":"/', "`"assetPrefix`":`"$domain/"
    
    # 4. Background images
    $content = $content -replace 'url\(''?/(?![./])', "url('$domain/"
    
    Set-Content $targetFile $content -NoNewline
    Write-Host "Finished $targetFile"
}
