# تحميل خطوط IBM Plex Sans Arabic

$fontsDir = "assets/fonts"
if (!(Test-Path $fontsDir)) {
    New-Item -ItemType Directory -Path $fontsDir
}

$fonts = @{
    "IBMPlexSansArabic-Regular.ttf" = "https://github.com/IBM/plex/raw/master/IBM-Plex-Sans-Arabic/fonts/complete/ttf/IBMPlexSansArabic-Regular.ttf"
    "IBMPlexSansArabic-Bold.ttf" = "https://github.com/IBM/plex/raw/master/IBM-Plex-Sans-Arabic/fonts/complete/ttf/IBMPlexSansArabic-Bold.ttf"
    "IBMPlexSansArabic-SemiBold.ttf" = "https://github.com/IBM/plex/raw/master/IBM-Plex-Sans-Arabic/fonts/complete/ttf/IBMPlexSansArabic-SemiBold.ttf"
    "IBMPlexSansArabic-Medium.ttf" = "https://github.com/IBM/plex/raw/master/IBM-Plex-Sans-Arabic/fonts/complete/ttf/IBMPlexSansArabic-Medium.ttf"
}

foreach ($font in $fonts.GetEnumerator()) {
    $outputPath = Join-Path $fontsDir $font.Key
    Write-Host "تحميل $($font.Key)..."
    try {
        Invoke-WebRequest -Uri $font.Value -OutFile $outputPath -UseBasicParsing
        Write-Host "✓ تم تحميل $($font.Key)" -ForegroundColor Green
    } catch {
        Write-Host "✗ فشل تحميل $($font.Key): $_" -ForegroundColor Red
    }
}

Write-Host "`nتم الانتهاء!" -ForegroundColor Cyan

