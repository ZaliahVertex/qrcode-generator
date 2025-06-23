Add-Type -AssemblyName System.Drawing

# Load QRCoder DLL
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$qrcoderDll = Join-Path $scriptPath 'QRCoder.dll'

if (-not (Test-Path $qrcoderDll)) {
    Write-Host "QRCoder.dll not found. Please download it and place it in this folder." -ForegroundColor Red
    exit
}

# Unblock in case it's blocked
Unblock-File -Path $qrcoderDll
Add-Type -Path $qrcoderDll

function Generate-QRCode {
    param (
        [string]$content,
        [string]$outputPath
    )

    # Create generator and data
    $generator = New-Object QRCoder.QRCodeGenerator
    $data = $generator.CreateQrCode($content, [QRCoder.QRCodeGenerator+ECCLevel]::Q)

    # Display QR code as ASCII
    $asciiQr = [QRCoder.AsciiQRCode]::new($data)
    $asciiOutput = $asciiQr.GetGraphic(1)
    Write-Host "`n$asciiOutput`n" -ForegroundColor Cyan

    # Also generate and save PNG
    $qr = New-Object QRCoder.QRCode $data
    $bmp = $qr.GetGraphic(20)
    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "QR code image saved to: $outputPath" -ForegroundColor Green
}

do {
    $url = Read-Host "Enter the URL to encode in the QR code"
    $name = Read-Host "Enter a name for the QR code image (without extension)"
    $outputPath = Join-Path $scriptPath "$name.png"

    try {
        Generate-QRCode -content $url -outputPath $outputPath
    } catch {
        Write-Host "Error generating QR code: $_" -ForegroundColor Red
    }

    $again = Read-Host "Do you want to generate another QR code? (yes/no)"
} while ($again -match '^(yes|y)$')
