$directories = @(
    "mac", "ipad", "user", "watch", "vision", "airpods", 
    "tv-home", "entertainment", "accessories", "support"
)

foreach ($dir in $directories) {
    if (Test-Path "c:\Users\007\Desktop\apple\$dir\index.html") {
        Write-Host "Fixing assets in $dir\index.html"
        $filePath = "c:\Users\007\Desktop\apple\$dir\index.html"
        $content = Get-Content -Path $filePath -Raw -Encoding UTF8
        
        # Replace root-relative src, href, srcSet, srcset
        # Be careful not to replace `//` (protocol relative)
        $content = [regex]::Replace($content, 'src="/([^/])', 'src="https://www.apple.com/$1')
        $content = [regex]::Replace($content, 'href="/([^/])', 'href="https://www.apple.com/$1')
        $content = [regex]::Replace($content, 'srcSet="/([^/])', 'srcSet="https://www.apple.com/$1', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        $content = [regex]::Replace($content, 'action="/([^/])', 'action="https://www.apple.com/$1')
        
        # Replace background-image styles using url(/...)
        $content = [regex]::Replace($content, 'url\("/([^/])', 'url("https://www.apple.com/$1')
        $content = [regex]::Replace($content, 'url\(''/([^/])', 'url(''https://www.apple.com/$1')
        
        Set-Content -Path $filePath -Value $content -Encoding UTF8
    }
}
Write-Host "Asset paths fixed."
