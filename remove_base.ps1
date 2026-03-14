$basePath = "c:\Users\007\Desktop\apple"
$files = Get-ChildItem -Path $basePath -Recurse -Filter "index.html" -Exclude "node_modules", ".git"

foreach ($file in $files) {
    Write-Host "Cleaning $($file.FullName)..."
    $content = Get-Content $file.FullName -Raw
    $content = $content -replace '<base href=["'']\.\./index\.html["'']>', ''
    $content = $content -replace '<base href=["'']\./index\.html["'']>', ''
    $content = $content -replace '<base href=["'']index\.html["'']>', ''
    Set-Content $file.FullName $content -NoNewline
}
Write-Host "Done."
