#!/bin/sh
clear
echo "\e[0;37mAutoscript Passwall QWRT By\e[0m \e[1;32m@XoolVPN\e[0m"
sleep 2
echo "\e[1;37m[\e[0m \e[1;32mInstallation Starts Now...\e[0m \e[1;37m]\e[0m"
sleep 3

# Main installation block: redirects all output to /dev/null
(
    # Add custom package feed
    echo "src/gz custom_packages https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2" | tee -a /etc/opkg/customfeeds.conf >/dev/null 2>&1

    # Update package lists
    opkg update >/dev/null 2>&1

    # Install packages
    opkg install luci-app-passwall htop haproxy >/dev/null 2>&1

    # Download, extract, and install Xray
    cd /tmp && \
    curl -L https://github.com/mssvpn/Xray-core/releases/download/v1.7.2.1/Xray-linux-arm64-v8a.zip > Xray-linux-arm64-v8a.zip && \
    unzip -o Xray-linux-arm64-v8a.zip && \
    mv xray /usr/bin && \
    chmod +x /usr/bin/xray
) >/dev/null 2>&1

# Check if the main installation block exited successfully
if [ $? -eq 0 ]; then
    echo "\033[1;32mPackages and Xray core installed successfully.\033[0m"
    else
    echo "\033[1;31mError: Installation of packages or Xray failed. Check network or disk space.\033[0m"
    exit 1
fi

# Hotplug configuration block: redirects all output to /dev/null
(
cat << 'EOF' > /etc/hotplug.d/iface/99-passwall
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
EOF
) >/dev/null 2>&1

# Check if hotplug config was written successfully
if [ $? -eq 0 ]; then
echo "\033[1;32mPassWall hotplug configuration applied.\033[0m"
else
echo "\033[1;31mError: Failed to write hotplug configuration.\033[0m"
exit 1
fi

clear
rm -f /root/setup.sh
echo "\e[1;37m[\e[0m \e[1;32mSuccessful!\e[0m \e[1;37m]\e[0m \e[0;37mReboot Now? (y/n)? : \e[0m"
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi
