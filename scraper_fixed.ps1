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

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

foreach ($sec in $sections) {
    try {
        $dirPath = Join-Path $basePath $sec.name
        $outPath = Join-Path $dirPath "index.html"
        
        if (-not (Test-Path $dirPath)) {
            New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
        }

        Write-Host "Fetching $($sec.name) from $($sec.url) ..."
        
        $client = New-Object System.Net.WebClient
        $client.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36")
        
        $html = $client.DownloadString($sec.url)
        
        # Replace global apple domains with local index
        $html = [regex]::Replace($html, 'href=["'']https?://(?:www\.|store\.|support\.)?apple\.com[^"'']*["'']', 'href="../index.html"', 'IgnoreCase')
        
        # Fix relative Apple paths like href="/mac/" to point back to our local index 
        # (This prevents them from clicking a "/mac/" link and getting a totally broken path)
        $html = [regex]::Replace($html, 'href=["'']/[^/][^"'']*["'']', 'href="../index.html"', 'IgnoreCase') 
        
        # Apple's CDNs for images/styles/scripts. If it starts with /v/ or /ac/ we map it to https://www.apple.com
        $html = [regex]::Replace($html, 'src=["''](/v/[^"'']*)["'']', 'src="https://www.apple.com$1"', 'IgnoreCase')
        $html = [regex]::Replace($html, 'href=["''](/v/[^"'']*)["'']', 'href="https://www.apple.com$1"', 'IgnoreCase')
        $html = [regex]::Replace($html, 'src=["''](/ac/[^"'']*)["'']', 'src="https://www.apple.com$1"', 'IgnoreCase')
        $html = [regex]::Replace($html, 'href=["''](/ac/[^"'']*)["'']', 'href="https://www.apple.com$1"', 'IgnoreCase')
        
        # Base element injection to ensure relative images load
        $baseTag = "<base href=`"https://www.apple.com/`">"
        if ($html -match "<head.*?>") {
            $html = $html -replace "(<head.*?>)", "`$1`n    $baseTag"
        } else {
             $html = $baseTag + "`n" + $html
        }

        [System.IO.File]::WriteAllText($outPath, $html, [System.Text.Encoding]::UTF8)
        Write-Host "Success: Saved modified $($sec.name) section to $outPath"
    } catch {
        Write-Host "Failed to fetch $($sec.name): $($_.Exception.Message)"
    }
}
