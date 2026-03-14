$sections = @(
    @{ name="mac"; url="https://www.apple.com/mac/" },
    @{ name="ipad"; url="https://www.apple.com/ipad/" },
    @{ name="iphone"; url="https://www.apple.com/iphone/" },
    @{ name="watch"; url="https://www.apple.com/watch/" },
    @{ name="vision"; url="https://www.apple.com/apple-vision-pro/" },
    @{ name="airpods"; url="https://www.apple.com/airpods/" },
    @{ name="tv-home"; url="https://www.apple.com/tv-home/" },
    @{ name="entertainment"; url="https://www.apple.com/services/" },
    @{ name="accessories"; url="https://www.apple.com/shop/accessories/all" },
    @{ name="support"; url="https://support.apple.com/" }
)
$basePath = "c:\Users\007\Desktop\apple"

# Set up TLS properly
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

foreach ($sec in $sections) {
    try {
        $outPath = Join-Path $basePath $sec.name "index.html"
        $dirPath = Join-Path $basePath $sec.name
        
        if (-not (Test-Path $dirPath)) {
            New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
        }

        Write-Host "Fetching $($sec.name) from $($sec.url) ..."
        
        # User-Agent spoofing to get actual HTML content instead of robot block
        $client = New-Object System.Net.WebClient
        $client.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36")
        
        $html = $client.DownloadString($sec.url)
        
        # We need to correct URLs strictly after downloading before saving.
        # We map all Apple Global Nav routes to our local routes.
        
        # Step 1: Base Apple URL fixes
        $html = [regex]::Replace($html, 'href=["'']https?://(?:www\.|store\.|support\.)?apple\.com[^"'']*["'']', 'href="../index.html"', 'IgnoreCase')
        $html = [regex]::Replace($html, 'href=["'']/[^/][^"'']*["'']', 'href="../index.html"', 'IgnoreCase') 
        
        # Step 2: Specific routing maps
        $html = $html -replace 'href="\.\./index\.html"', 'href="../index.html"'
        
        # Fixing relative assets path so we pull them live from CDNs instead of breaking 
        $html = [regex]::Replace($html, 'src=["''](/v/[^"'']*)["'']', 'src="https://www.apple.com$1"', 'IgnoreCase')
        $html = [regex]::Replace($html, 'href=["''](/v/[^"'']*)["'']', 'href="https://www.apple.com$1"', 'IgnoreCase')

        [System.IO.File]::WriteAllText($outPath, $html, [System.Text.Encoding]::UTF8)
        Write-Host "Success: Saved modified $($sec.name) section to $outPath"
    } catch {
        Write-Host "Failed to fetch $($sec.name): $($_.Exception.Message)"
    }
}
