# Load QRCoder DLL
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$qrcoderDll = Join-Path $scriptPath 'QRCoder.dll'

if (-not (Test-Path $qrcoderDll)) {
    Write-Host "QRCoder.dll not found. Please download it from https://www.nuget.org/packages/qrcoder/, rename the .nupkg to .zip, extract QRCoder.dll from netstandard2.0, and place it in this folder." -ForegroundColor Red
    exit
}

# Unblock and load DLL
Unblock-File -Path $qrcoderDll
Add-Type -Path $qrcoderDll

function Generate-QRCodeSVG {
    param (
        [string]$content,
        [string]$outputPath
    )

    # Create QR code data
    $generator = [QRCoder.QRCodeGenerator]::new()
    $data = $generator.CreateQrCode($content, [QRCoder.QRCodeGenerator+ECCLevel]::H)

    # Display ASCII version
    $asciiQr = [QRCoder.AsciiQRCode]::new($data)
    $asciiOutput = $asciiQr.GetGraphic(1)
    Write-Host "`nASCII QR Code:`n" -ForegroundColor Cyan
    Write-Host $asciiOutput

    # Load ModuleShape enum via reflection
    $moduleShapeType = [System.AppDomain]::CurrentDomain.GetAssemblies() |
        ForEach-Object { $_.GetType("QRCoder.SvgQRCode+ModuleShape", $false) } |
        Where-Object { $_ -ne $null } |
        Select-Object -First 1

    if (-not $moduleShapeType) {
        Write-Host "Error: Could not resolve 'ModuleShape' from QRCoder.SvgQRCode." -ForegroundColor Red
        return
    }

    $roundedShape = [Enum]::Parse($moduleShapeType, "Round")

    # SVG Style config
    $svgRendererClass = [QRCoder.SvgQRCode]::new($data)
    $svgOptions = [QRCoder.SvgQRCode+SvgQRCodeStyle]::new()
    $svgOptions.DrawQuietZones = $true
    $svgOptions.ModuleSize = 20
    $svgOptions.ModuleShape = $roundedShape
    $svgOptions.BackgroundColor = "#f0f0f0"      # Light pastel background
    $svgOptions.BackgroundRoundCorners = $true   # Round the square
    $svgOptions.DarkColor = "#301934"            # Dark purple
    $svgOptions.LightColor = "#ffffff"           # White background

    $svg = $svgRendererClass.GetGraphic($svgOptions)

    # Save SVG to file
    [System.IO.File]::WriteAllText($outputPath, $svg)
    Write-Host "`nSVG QR code saved to: $outputPath" -ForegroundColor Green
}

do {
    $url = Read-Host "Enter the URL to encode in the QR code"
    $name = Read-Host "Enter a name for the QR code image (without extension)"
    $outputPath = Join-Path $scriptPath "$name.svg"

    try {
        Generate-QRCodeSVG -content $url -outputPath $outputPath
    } catch {
        Write-Host "Error generating QR code: $_" -ForegroundColor Red
    }

    $again = Read-Host "Do you want to generate another QR code? (yes/no)"
} while ($again -match '^(yes|y)$')
