Add-Type -AssemblyName System.Drawing

# Load QRCoder DLL
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$qrcoderDll = Join-Path $scriptPath 'QRCoder.dll'

if (-not (Test-Path $qrcoderDll)) {
    Write-Host "QRCoder.dll not found. Please download it from https://www.nuget.org/packages/qrcoder/ rename the file extension to .zip > get the QRCoder.dll from netstandard2.0 > place in the same folder as the script." -ForegroundColor Red
    exit
}

# Unblock in case it's blocked
Unblock-File -Path $qrcoderDll
Add-Type -Path $qrcoderDll

function Generate-QRCode {
    param (
        [string]$content,
        [string]$outputPath,
        [string]$logoPath
    )

    $generator = [QRCoder.QRCodeGenerator]::new()
    $data = $generator.CreateQrCode($content, [QRCoder.QRCodeGenerator+ECCLevel]::H)

 # ASCII QR code display
    $asciiQr = [QRCoder.AsciiQRCode]::new($data)
    $asciiOutput = $asciiQr.GetGraphic(1)
    Write-Host "`nASCII QR Code:`n" -ForegroundColor Cyan
    Write-Host $asciiOutput

 # Generate PNG
    $qrCode = [QRCoder.QRCode]::new($data)
    $qrColor = [System.Drawing.Color]::FromArgb(48, 25, 52) # Dark purple
    $white = [System.Drawing.Color]::White
    $qrBitmap = $qrCode.GetGraphic(
        20,
        $qrColor,
        [System.Drawing.Color]::White,
        $null,
        0,
        0,
        $true
    )

# Composite the logo if provided
    if (Test-Path $logoPath) {
        $logo = [System.Drawing.Image]::FromFile($logoPath)
        $g = [System.Drawing.Graphics]::FromImage($qrBitmap)

        $g.SmoothingMode = "HighQuality"
        $g.InterpolationMode = "HighQualityBicubic"
        $g.CompositingQuality = "HighQuality"
        $g.PixelOffsetMode = "HighQuality"

       # Calculate logo size (15% of QR code size)
        $logoScale = 0.15
        $logoSize = [int]($qrBitmap.Width * $logoScale)
        $logoX = [int](($qrBitmap.Width - $logoSize) / 2)
        $logoY = [int](($qrBitmap.Height - $logoSize) / 2)

        # Define pastel color (light blue)
        $logobgColor = [System.Drawing.Color]::FromArgb(230, 230, 250) #lavender
        $brush = [System.Drawing.SolidBrush]::new($logobgColor)
        $backgroundRect = [System.Drawing.Rectangle]::new($logoX - 4, $logoY - 4, $logoSize + 8, $logoSize + 8)
        $g.FillEllipse($brush, $backgroundRect)

        # Draw the logo
        $g.DrawImage($logo, $logoX, $logoY, $logoSize, $logoSize)

        # Cleanup
        $g.Dispose()
        $logo.Dispose()
    }

    $qrBitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "QR code saved to: $outputPath" -ForegroundColor Green
}

do {
    $url = Read-Host "Enter the URL to encode in the QR code"
    $name = Read-Host "Enter a name for the QR code image (without extension)"
    $outputPath = Join-Path $scriptPath "$name.png"

    try {
        $logoPath = Join-Path $scriptPath 'logo.png'
	Generate-QRCode -content $url -outputPath $outputPath -logoPath $logoPath
    } catch {
        Write-Host "Error generating QR code: $_" -ForegroundColor Red
    }

    $again = Read-Host "Do you want to generate another QR code? (y/n)"
} while ($again -match '^(yes|y)$')
