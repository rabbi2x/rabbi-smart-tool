# 🚀 RABBI UNIVERSAL SMART FLASHER & EXTRACTOR (V2.1)

A professional, lightweight, and dynamic Android flashing tool designed specifically for **Linux** and **Termux** users. This tool simplifies the process of flashing stock firmware and extracting encrypted OFP files.

## ✨ Features
* **Auto-Detect Flashing:** Automatically scans and flashes all `.img` and `.bin` files from a folder based on their filenames.
* **OFP Extractor:** Decrypts and extracts Oppo/Realme/OnePlus `.ofp` firmware files into flashable images.
* **Fastboot Integration:** Real-time device detection and product info checking.
* **Universal Compatibility:** Works on any Android device with an unlocked bootloader.

---

## 📂 How to Organize Your Files

### 1. For Flashing Stock ROM:
* Keep all your `.img` files (e.g., `boot.img`, `system.img`, `vendor.img`) in **one single folder**.
* The tool will automatically detect the partition name from the file name.
* **Example:** `recovery.img` will be flashed to the `recovery` partition.

### 2. For OFP Extraction:
* Place your `.ofp` firmware file anywhere on your storage.
* **Output:** The extracted files will be saved in a new folder named `out/` inside the tool's directory on your phone. **Note:** Extracted files are saved to your storage first; you need to flash them manually using Option 1 after extractionsh
 ⚠️ Important Notes
​Unlocked Bootloader: Your device must have an unlocked bootloader to flash images.
​OFP Extraction: The extraction process saves files to your phone's internal memory. Ensure you have enough storage space (at least 15-20GB for full firmware).
​Safety: Always double-check your file names before starting the auto-flash process.
​👨‍💻 Developer
​Fazle Rabbi from Bangladesh 
## 🛠️ How to Use in Termux

1. **Clone the Repository:**
   ```bash
   git clone [https://github.com/rabbi2x/rabbi-smart-tool](https://github.com/rabbi2x/rabbi-smart-tool)
   cd rabbi-smart-tool
   chmod +x rabbi_tool.sh
   ./rabbi_tool.sh
   
