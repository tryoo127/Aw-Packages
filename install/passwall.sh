#!/bin/sh
clear
echo -e "\e[1;36m=============================================\e[0m"
echo -e "\e[0;37m       Autoscript Passwall QWRT By \e[1;32m@XoolVPN\e[0m"
echo -e "\e[1;36m=============================================\e[0m"
echo
sleep 2

# ---
## Installation Progress

# Function to display a simple progress spinner
spin_progress() {
    local pid=$1
    local delay=0.1
    local spinstr="\\|/-"
    local i=0
    echo -n " "
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        i=$(( (i+1) % 4 ))
        printf "\b\e[1;33m%c\e[0m" "${spinstr:$i:1}"
        sleep "$delay"
    done
    printf "\b\e[1;32m✓\e[0m\n" # Checkmark on success
}

echo -e "\e[1;37m[1/4] Adding custom opkg feed...\e[0m"
(echo "src/gz custom_packages https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2" | tee -a /etc/opkg/customfeeds.conf > /dev/null 2>&1) & spin_progress $!
sleep 1

echo -e "\e[1;37m[2/4] Updating opkg and installing Passwall components...\e[0m"
(opkg update > /dev/null 2>&1 && opkg install luci-app-passwall haproxy > /dev/null 2>&1) & spin_progress $!
sleep 1

echo -e "\e[1;37m[3/4] Downloading and installing Xray-core...\e[0m"
(cd /tmp && curl -L https://github.com/mssvpn/Xray-core/releases/download/v1.7.2.1/Xray-linux-arm64-v8a.zip -o Xray-linux-arm64-v8a.zip > /dev/null 2>&1 && unzip -o Xray-linux-arm64-v8a.zip > /dev/null && mv xray /usr/bin && chmod +x /usr/bin/xray) & spin_progress $!
sleep 1

echo -e "\e[1;37m[4/4] Creating hotplug script for Passwall...\e[0m"
(cat << 'EOF' > /etc/hotplug.d/iface/99-passwall
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
EOF
) & spin_progress $!
sleep 1

clear
rm -f /root/passwall.sh
echo -e "\n\e[1;36m=============================================\e[0m"
echo -e "\e[1;37m[\e[0m \e[1;32mInstallation Successful!\e[0m \e[1;37m]\e[0m"
echo -e "\e[1;36m=============================================\e[0m"
echo -ne "\e[0;37mReboot Now to apply changes? (y/n): \e[0m"
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
    echo -e "\e[1;31mReboot skipped. Please reboot manually later for changes to take effect.\e[0m"
    exit 0
else
    echo -e "\e[1;32mRebooting system...\e[0m"
    reboot
fi
