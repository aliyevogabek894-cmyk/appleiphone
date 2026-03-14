$domain = "https://www.apple.com"
$basePath = "c:\Users\007\Desktop\apple"
# Script will now loop through directories and look for raw or index files

$navMappings = @{
    "/mac/" = "mac/index.html"
    "/ipad/" = "ipad/index.html"
    "/iphone/" = "iphone/index.html"
    "/watch/" = "watch/index.html"
    "/apple-vision-pro/" = "vision/index.html"
    "/airpods/" = "airpods/index.html"
    "/tv-home/" = "tv-home/index.html"
    "/entertainment/" = "entertainment/index.html"
    "/accessories/" = "accessories/index.html"
    "/support/" = "support/index.html"
    "/store/" = "store/index.html"
    "/shop/" = "shop/index.html"
    "/" = "index.html"
}

foreach ($dir in (Get-ChildItem -Directory)) {
    if ($dir.Name -match "admin|node_modules|\.git") { continue }
    
    $rawFile = Get-ChildItem -Path $dir.FullName -Filter "apple_*_raw.html" | Select-Object -First 1
    $targetFile = Join-Path $dir.FullName "index.html"
    
    if ($rawFile) {
        Write-Host "Recovering $($dir.Name) from $($rawFile.Name)..."
        $content = Get-Content $rawFile.FullName -Raw
    } elseif (Test-Path $targetFile) {
        Write-Host "Processing existing $($targetFile)..."
        $content = Get-Content $targetFile -Raw
    } else {
        continue
    }

    # Calculate relative prefix (e.g. "../")
    $relDir = $dir.FullName.Substring($basePath.Length).TrimStart('\')
    if ($relDir -eq "") {
        $prefix = ""
    } else {
        $depth = ($relDir -split '\\').Count
        $prefix = ""
        for ($i=0; $i -lt $depth; $i++) { $prefix += "../" }
    }
    
    # 1. Map Navigation by URL (Original strategy)
    # Sort keys by length descending to match /mac/ before /
    $sortedKeys = $navMappings.Keys | Sort-Object Length -Descending
    foreach ($key in $sortedKeys) {
        $localPath = $prefix + $navMappings[$key]
        $escKey = [regex]::Escape($key)
        
        # Match href="/mac/" or href="https://www.apple.com/mac/"
        # Support both double and single quotes
        $content = [regex]::Replace($content, "href=`"($domain)?$escKey`"", "href=`"$localPath`"")
        $content = [regex]::Replace($content, "href='($domain)?$escKey'", "href='$localPath'")
        
        # Also handle JSON links that are exactly these paths
        $content = $content -replace "`":`"($domain)?$escKey`"", "`":`"$localPath`""
    }
    
    # 1b. Robust Recovery: Map by data-globalnav-item-name
    $itemMappings = @{
        "apple" = "index.html"
        "store" = "store/index.html"
        "mac" = "mac/index.html"
        "ipad" = "ipad/index.html"
        "iphone" = "iphone/index.html"
        "watch" = "watch/index.html"
        "vision" = "vision/index.html"
        "airpods" = "airpods/index.html"
        "tv-home" = "tv-home/index.html"
        "entertainment" = "entertainment/index.html"
        "accessories" = "accessories/index.html"
        "support" = "support/index.html"
    }
    foreach ($item in $itemMappings.Keys) {
        $localPath = $prefix + $itemMappings[$item]
        # Simple reliable replacement for the most common broken pattern
        $content = $content -replace "href=`"../index.html`" data-globalnav-item-name=`"$item`"", "href=`"$localPath`" data-globalnav-item-name=`"$item`""
        $content = $content -replace "href='../index.html' data-globalnav-item-name='$item'", "href='$localPath' data-globalnav-item-name='$item'"
    }
    
    # 2. Fix Assets (root-relative paths that are NOT in navMappings)
    # Target common attributes with flexible spacing: attr = "/...
    $attributes = "href|src|srcset|srcSet|data-src|data-href|data-srcset|content|action"
    $content = [regex]::Replace($content, "(($attributes)\s*=\s*[`"'])/(?![./])", "`$1$domain/")
    
    # Handle the second/third URLs in a srcset list: ", /"
    $content = $content -replace ', /', ", $domain/"
    
    # 3. Fixed JSON paths logic (prefixing /_next, /metrics, etc.)
    # Target "key": "/... or 'key': '/...
    $content = [regex]::Replace($content, "([`"']\s*:\s*[`"'])/(?![./])", "`$1$domain/")
    # Specialized fix for assetPrefix to be sure
    $content = $content -replace '"assetPrefix":"/', "`"assetPrefix`":`"$domain/"
    
    # 4. Background images
    $content = $content -replace 'url\(''?/(?![./])', "url('$domain/"
    
    Set-Content $targetFile $content -NoNewline
    Write-Host "Finished $($targetFile)"
}
