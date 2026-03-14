$domain = "https://www.apple.com"
$files = Get-ChildItem -Recurse -Filter "index.html" -Exclude "admin", "node_modules", ".git"

foreach ($file in $files) {
    Write-Host "Processing $($file.FullName)..."
    $content = Get-Content $file.FullName -Raw
    
    # 1. Fix href, src, data-src, data-href starting with /
    # Safe replacement: keep the start of the attribute and prefix the /
    $content = $content -replace 'href="/(?![./])', "href=""$domain/"
    $content = $content -replace 'src="/(?![./])', "src=""$domain/"
    $content = $content -replace 'data-src="/(?![./])', "data-src=""$domain/"
    $content = $content -replace 'data-href="/(?![./])', "data-href=""$domain/"
    $content = $content -replace 'data-srcset="/(?![./])', "data-srcset=""$domain/"
    $content = $content -replace 'action="/(?![./])', "action=""$domain/"
    
    # 2. Fix srcset/srcSet
    $content = $content -replace 'srcset="/(?![./])', "srcset=""$domain/"
    $content = $content -replace 'srcSet="/(?![./])', "srcSet=""$domain/"
    $content = $content -replace ',\s?/(?![./])', ", $domain/"
    
    # 3. Fix JSON assetPrefix and other internal JSON absolute paths
    # Use -replace with literal strings to be safe from regex quote issues
    $content = $content -replace '"assetPrefix":"/', "`"assetPrefix`":`"$domain/"
    
    # 4. FIX: Generic JSON absolute paths. 
    # The previous regex ":"/(?![./]) was stripping the second quote of the key.
    # We use a pattern that matches the colon and the opening quote of the value.
    $content = $content -replace '":"/(?![./])', "`":`"$domain/"
    
    # 5. Background images
    $content = $content -replace 'url\(''?/(?![./])', "url('$domain/"
    
    Set-Content $file.FullName $content -NoNewline
    Write-Host "Finished $($file.FullName)"
}
