# PowerShell QR Code Generator

A quick QR code generator I made for my partner at their request. Pull requests welcome.

---

## What it does

 - Generate QR codes from URLs   
 - Output as PNG<br>
 - Preview as ASCII art to confirm creation of QR code worked <br>
 - Supports logo overlay in center (png)<br>
 - Customize colors<br>
 - Works in **PowerShell 7+**<br>

---

## 🚀 How It Works

Just download QRCoder.dll and QRGeneratorFancy.ps1 then place them in a folder. From there, simply run the script in [**Powershell 7.5 or newer**](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows), and it will:

1. Ask you for a URL
2. Ask for a name for the output file
3. Check if a logo.png file exists and add it to the center (will be resized to fit in the center)
   - If you don't want a logo, please use the /otherversions/QRGenerator.ps1 script instead!
   - Make sure to move the script to the root folder, otherwise it won't parse the required DLL 
5. Generate both:
   - A **terminal preview** using ASCII
   - A **PNG file** with customizable design
6. Ask if you'd like to generate another
