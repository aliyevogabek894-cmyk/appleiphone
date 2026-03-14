$files = Get-ChildItem -Recurse -Filter *.html

foreach ($file in $files) {
    Write-Host "Processing $($file.FullName)..."
    $content = Get-Content $file.FullName -Raw

    # 1. Fix absolute paths starting with /
    $content = $content -replace '(?<=src=")/(?![/])', 'https://www.apple.com/'
    $content = $content -replace '(?<=href=")/(?![/])', 'https://www.apple.com/'
    $content = $content -replace '(?<=action=")/(?![/])', 'https://www.apple.com/'
    $content = $content -replace '(?<=data-src=")/(?![/])', 'https://www.apple.com/'
    $content = $content -replace '(?<=data-href=")/(?![/])', 'https://www.apple.com/'
    
    # 2. Fix srcSet paths
    $content = [regex]::Replace($content, 'srcSet="([^"]+)"', {
        param($m)
        $val = $m.Groups[1].Value
        $newVal = $val -replace '(?<=^|,)\s*/', ' https://www.apple.com/'
        return "srcSet=""$newVal"""
    })

    # 3. Fix absolute paths in JSON blocks (e.g., ":"/path")
    $content = $content -replace '(?<=":")/(?![/])', 'https://www.apple.com/'
    
    # 4. Fix assetPrefix in Next.js data
    $content = $content -replace '(?<="assetPrefix":")(?=")', 'https://www.apple.com'
    
    # 5. Fix /_next/ paths that might not be prefixed with ":" in JSON or scripts
    $content = $content -replace '(?<=")/_next/', 'https://www.apple.com/_next/'
    
    # 6. Fix style background-image: url(/...)
    $content = $content -replace '(?<=url\()/(?![/])', 'https://www.apple.com/'

    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}
