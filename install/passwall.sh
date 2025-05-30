#!/bin/sh
clear
echo -e "\e[0;37mAutoscript Passwall QWRT By\e[0m \e[1;32m@XoolVPN\e[0m"
sleep 3

clear
# Add the custom feed if it's not already present
if ! grep -q "custom_packages" /etc/opkg/customfeeds.conf; then
    echo "src/gz custom_packages https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2" | tee -a /etc/opkg/customfeeds.conf > /dev/null
else
    echo "Installation folder already exists."
fi

# Update package lists silently with progress indication
opkg update > /dev/null 2>&1 &
OPKG_UPDATE_PID=$!
while kill -0 "$OPKG_UPDATE_PID" 2>/dev/null; do
    echo -n "."
    sleep 1
done
echo " Done."

# Check if opkg update was successful
if [ $? -ne 0 ]; then
    echo -e "\e[1;31mError: Failed to update package lists. Please check your internet connection.\e[0m"
    exit 1
fi

# Install passwall and haproxy silently with progress indication
echo -n "Installing passwall and haproxy: "
{ opkg install luci-app-passwall haproxy; } > /dev/null 2>&1 &
OPKG_INSTALL_PID=$!
while kill -0 "$OPKG_INSTALL_PID" 2>/dev/null; do
    echo -n "."
    sleep 1
done
echo " Done."

# Check if the installation was successful
if [ $? -eq 0 ]; then
    echo -e "\e[1;32mPasswall QWRT installation successfully!\e[0m"
    else
    echo -e "\e[1;31mError: Installation failed. Please check your internet connection.\e[0m"
    exit 1
fi
sleep 1

clear
# Define the URL and destination
XRAY_URL="https://github.com/mssvpn/Xray-core/releases/download/v1.7.2.1/Xray-linux-arm64-v8a.zip"
XRAY_ZIP="Xray-linux-arm64-v8a.zip"
INSTALL_DIR="/usr/bin"
XRAY_EXECUTABLE="xray"

# Create a temporary directory if it doesn't exist
mkdir -p /tmp/xray_install
cd /tmp/xray_install || { echo -e "\e[1;31mError: Failed to change to temporary directory.\e[0m"; exit 1; }

# Download Xray-core silently with progress
echo -n "Downloading Xray Core 1.7.2.1 By @MssVPN: "
curl -L "$XRAY_URL" -o "$XRAY_ZIP" --progress-bar > /dev/null 2>&1 &
CURL_PID=$!
while kill -0 "$CURL_PID" 2>/dev/null; do
    echo -n "."
    sleep 1
done
echo " Done."

# Check if download was successful
if [ ! -f "$XRAY_ZIP" ] || [ ! -s "$XRAY_ZIP" ]; then
    echo -e "\e[1;31mError: Xray Core download failed or file is empty.\e[0m"
    rm -rf /tmp/xray_install # Clean up
    exit 1
fi

# Unzip the archive silently with progress
echo -n "Unzipping Xray Core: "
unzip -o "$XRAY_ZIP" > /dev/null 2>&1 &
UNZIP_PID=$!
while kill -0 "$UNZIP_PID" 2>/dev/null; do
    echo -n "."
    sleep 1
done
echo " Done."

# Check if unzipping was successful and 'xray' executable exists
if [ ! -f "./$XRAY_EXECUTABLE" ]; then
    echo -e "\e[1;31mError: Failed to unzip Xray Core or 'xray' executable not found.\e[0m"
    rm -rf /tmp/xray_install # Clean up
    exit 1
fi

# Move xray to destination and set permissions silently
echo -n "Installing Xray Core to $INSTALL_DIR: "
if mv "$XRAY_EXECUTABLE" "$INSTALL_DIR/" > /dev/null 2>&1; then
    echo -n "."
    if chmod +x "$INSTALL_DIR/$XRAY_EXECUTABLE" > /dev/null 2>&1; then
        echo -n "."
        echo " Done."
        echo -e "\e[1;32mXray Core installed successfully!\e[0m"
    else
        echo -e "\e[1;31mError: Failed to set executable permissions for Xray Core.\e[0m"
        rm -rf /tmp/xray_install # Clean up
        exit 1
    fi
else
    echo -e "\e[1;31mError: Failed to move Xray Core to $INSTALL_DIR. Check permissions or if directory exists.\e[0m"
    rm -rf /tmp/xray_install # Clean up
    exit 1
fi

# Clean up temporary files
echo "Cleaning up temporary files..."
rm -rf /tmp/xray_install

clear
cat << 'EOF' > /etc/hotplug.d/iface/99-passwall
#!/bin/sh

log () {
modlog "$@"
}

if [ "$ACTION" = "ifup" -a $INTERFACE = wan  -a $(uci -q get passwall.@global[0].enabled) -eq 1 ]; then
sleep 10
/etc/init.d/passwall restart
if [ $? -eq 0 ]; then
log "Restart Passwall"
else
log "failed to restart Passwall"
fi
fi
done
EOF

clear
rm -f /root/passwall.sh
## Reboot Prompt

echo -ne "\e[1;37m[\e[0m \e[1;32mSuccessful!\e[0m \e[1;37m]\e[0m \e[0;37mA reboot is recommended for changes to take full effect. Reboot now? (y/n)? : \e[0m"
read -r answer # Use -r for read to prevent backslash interpretation

if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo -e "\e[1;33mRebooting your device now...\e[0m"
    reboot
else
    echo -e "\e[1;34mYou chose not to reboot. Login QWRT WEB UI and refresh the page.\e[0m"
    exit 0
fi
