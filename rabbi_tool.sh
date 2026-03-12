#!/bin/bash

# Professional Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}          RABBI UNIVERSAL SMART FLASHER          ${NC}"
echo -e "${CYAN}         (Works for Any Android Device)          ${NC}"
echo -e "${CYAN}==================================================${NC}"

# 1. Ask for Image Folder Path
echo -n -e "${YELLOW}[?] Enter the folder path containing image files: ${NC}"
read IMG_PATH

if [ ! -d "$IMG_PATH" ]; then
    echo -e "${RED}[❌] Error: Directory not found!${NC}"
    exit 1
fi

# 2. Wait for Fastboot Device
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

# 3. Dynamic File Scanning
echo -e "\n${CYAN}[*] Scanning folder for flashable files...${NC}"
cd "$IMG_PATH"

# Get all .img and .bin files
FILES=( *.{img,bin} )

# Check if any files exist
if [ ! -e "${FILES[0]}" ]; then
    echo -e "${RED}[❌] No .img or .bin files found in the folder!${NC}"
    exit 1
fi

echo -e "${YELLOW}[!] Found the following files to flash:${NC}"
for f in "${FILES[@]}"; do
    # Remove extension to show partition name
    part_name="${f%.*}"
    echo -e "  - $f  -->  (Partition: $part_name)"
done

# 4. User Confirmation
echo -n -e "\n${YELLOW}[?] Are you sure you want to flash these files? (y/n): ${NC}"
read choice
if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
    echo -e "${RED}[!] Flashing cancelled. Exiting...${NC}"
    exit 1
fi

# 5. Flashing Process
START_TIME=$SECONDS
LOG_FILE="universal_flash_log_$(date +%H%M%S).txt"

echo -e "\n${CYAN}[*] Starting Universal Flash... Logging to $LOG_FILE${NC}\n"

for f in "${FILES[@]}"; do
    # Get partition name by removing the extension (.img or .bin)
    partition="${f%.*}"
    
    echo -e "${YELLOW}[⚡] Flashing $f to partition [$partition]...${NC}"
    fastboot flash "$partition" "$f" 2>&1 | tee -a "$LOG_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo -e "${GREEN}[✅] $partition: SUCCESS${NC}"
    else
        echo -e "${RED}[❌] $partition: FAILED (Check partition name)${NC}"
    fi
done

# 6. Finish & Time Calculation
DURATION=$(( SECONDS - START_TIME ))
echo -e "\n${CYAN}==================================================${NC}"
echo -e "${GREEN}TASK FINISHED ✅ | Total Time: $((DURATION/60))m $((DURATION%60))s${NC}"
echo -e "${CYAN}==================================================${NC}"

# 7. Reboot Menu
echo -e "\n${YELLOW}[?] Select Reboot Option:${NC}"
echo -e "1. Reboot to System"
echo -e "2. Reboot to Recovery"
echo -e "3. Stay in Fastboot"
echo -n -e "${YELLOW}[?] Choice (1/2/3): ${NC}"
read reboot_choice

case $reboot_choice in
    1) fastboot reboot ;;
    2) fastboot reboot recovery ;;
    *) echo -e "${GREEN}Log saved in: $IMG_PATH/$LOG_FILE${NC}" ;;
esac
