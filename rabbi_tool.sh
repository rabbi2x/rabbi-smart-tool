#!/bin/bash

# ==================================================
#    RABBI UNIVERSAL SMART FLASHER & EXTRACTOR
#    Version: 2.1 (Dynamic Edition)
#    Developer: Fazle Rabbi (Ariyan)
# ==================================================

# Professional Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function: Display Banner
banner() {
    clear
    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}          RABBI UNIVERSAL SMART FLASHER          ${NC}"
    echo -e "${CYAN}         (Flash Images & Extract OFP)            ${NC}"
    echo -e "${CYAN}==================================================${NC}"
}

# Function: OFP Extractor Logic
extract_ofp() {
    echo -e "\n${YELLOW}[*] Preparing OFP Extractor...${NC}"
    
    # Installing Python dependencies if not present
    if ! command -v python3 &> /dev/null; then
        echo -e "${YELLOW}[!] Installing Python...${NC}"
        pkg install python -y
    fi
    pip install pycryptodome requests &> /dev/null

    # Downloading decryption script (Open Source by bkerler)
    if [ ! -f "ofp_decrypt.py" ]; then
        echo -e "${CYAN}[*] Downloading Decryption Engine...${NC}"
        curl -L -s -o ofp_decrypt.py "https://raw.githubusercontent.com/bkerler/oppo_tools/master/ofp_mtk_decrypt.py"
    fi

    echo -n -e "${YELLOW}[?] Enter the FULL PATH of your .ofp file: ${NC}"
    read OFP_FILE

    if [ -f "$OFP_FILE" ]; then
        echo -e "${GREEN}[🚀] Extraction Started... Please wait.${NC}"
        python3 ofp_decrypt.py "$OFP_FILE" out/
        echo -e "${GREEN}[✅] Done! Files extracted to 'out/' folder.${NC}"
    else
        echo -e "${RED}[❌] Error: OFP file not found!${NC}"
    fi
    read -p "Press Enter to return to menu..."
}

# Function: Flashing Logic
flash_images() {
    echo -n -e "${YELLOW}[?] Enter the folder path containing image files: ${NC}"
    read IMG_PATH

    if [ ! -d "$IMG_PATH" ]; then
        echo -e "${RED}[❌] Error: Directory not found!${NC}"
        return
    fi

    # Wait for Fastboot Device
    echo -e "\n${CYAN}[*] Waiting for device in fastboot mode...${NC}"
    while true; do
        DEVICE_SERIAL=$(fastboot devices | awk '{print $1}')
        if [ -n "$DEVICE_SERIAL" ]; then
            echo -e "${GREEN}[✅] Device Detected! Serial: $DEVICE_SERIAL${NC}"
            PRODUCT_NAME=$(fastboot getvar product 2>&1 | grep "product:" | awk '{print $2}')
            echo -e "${BLUE}[ℹ️] Target Device Product: ${PRODUCT_NAME:-Unknown}${NC}"
            break
        fi
        sleep 1
    done

    # Dynamic File Scanning
    echo -e "\n${CYAN}[*] Scanning folder for flashable files...${NC}"
    cd "$IMG_PATH"
    FILES=( *.{img,bin} )

    if [ ! -e "${FILES[0]}" ]; then
        echo -e "${RED}[❌] No .img or .bin files found!${NC}"
        return
    fi

    echo -e "${YELLOW}[!] Found these files to flash:${NC}"
    for f in "${FILES[@]}"; do
        part_name="${f%.*}"
        echo -e "  - $f  -->  (Partition: $part_name)"
    done

    echo -n -e "\n${YELLOW}[?] Start flashing? (y/n): ${NC}"
    read choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo -e "${RED}[!] Flashing cancelled.${NC}"
        return
    fi

    START_TIME=$SECONDS
    LOG_FILE="flash_log_$(date +%H%M%S).txt"

    for f in "${FILES[@]}"; do
        partition="${f%.*}"
        echo -e "${YELLOW}[⚡] Flashing $f to [$partition]...${NC}"
        fastboot flash "$partition" "$f" 2>&1 | tee -a "$LOG_FILE"
    done

    DURATION=$(( SECONDS - START_TIME ))
    echo -e "\n${GREEN}TASK FINISHED ✅ | Total Time: $((DURATION/60))m $((DURATION%60))s${NC}"
}

# Main Menu Loop
while true; do
    banner
    echo -e "${YELLOW}[1] Flash Stock ROM (Auto Detect)${NC}"
    echo -e "${YELLOW}[2] Extract .ofp Firmware (Oppo/Realme/OnePlus)${NC}"
    echo -e "${YELLOW}[3] Check Fastboot Devices${NC}"
    echo -e "${YELLOW}[4] Exit${NC}"
    echo -n -e "\n${CYAN}[?] Select Option: ${NC}"
    read main_choice

    case $main_choice in
        1) flash_images ;;
        2) extract_ofp ;;
        3) fastboot devices ;;
        4) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid Option!${NC}" ; sleep 1 ;;
    esac
done
