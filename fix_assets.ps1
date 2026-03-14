$directories = @("mac", "ipad", "iphone", "watch", "vision", "airpods", "tv-home", "entertainment", "accessories", "support")
$baseUrl = "https://www.apple.com"

foreach ($dir in $directories) {
    $filePath = "C:\Users\007\Desktop\apple\$dir\index.html"
    if (Test-Path $filePath) {
        Write-Host "Processing $filePath..."
        
        $content = Get-Content -Path $filePath -Encoding UTF8 -Raw
        
        # 1. Base tag and malformed links
        $content = $content -replace '<base href="\.\./index\.html">', ''
        $content = $content -replace 'href="\.\./index\.html"apple"', 'href="../index.html"'
        
        # 2. Comprehensive asset replacement
        # Target common Apple asset paths
        $paths = @("/assets-www/", "/_apps/", "/v/", "/ac/", "/artisan/")
        
        foreach ($p in $paths) {
            # HTML attributes: ="/path/
            $content = $content -replace "=`"$p", "=`"$baseUrl$p"
            # JSON properties: :"/path/
            $content = $content -replace ":`"$p", ":`"$baseUrl$p"
            # srcSet lists: , /path/
            $content = $content -replace ", $p", ", $baseUrl$p"
        }
        
        # Catch other root-relative extensions
        # HTML: ="/file.ext"
        $content = $content -replace '="/([^/][^"]+\.(js|css|png|jpg|jpeg|svg|json|ico))"', "=`"$baseUrl/`$1`""
        # JSON: :"/file.ext"
        $content = $content -replace ':"/([^/][^"]+\.(js|css|png|jpg|jpeg|svg|json|ico))"', ":`"$baseUrl/`$1`""

        # Write back
        Set-Content -Path $filePath -Value $content -Encoding UTF8
    }
}

Write-Host "Done!"
