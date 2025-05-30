#!/bin/sh
clear
echo -e "\e[0;37mAutoscript Passwall QWRT By\e[0m \e[1;32m@XoolVPN\e[0m"
sleep 3

# Function to display a spinning progress indicator
spin_progress() {
    local pid=$1
    local delay=0.1
    local spinstr="|"
    echo -n " "
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "\b%c" "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep "$delay"
    done
    printf "\b \n"
}

echo -n "Adding custom opkg feed..."
(echo "src/gz custom_packages https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2" | tee -a /etc/opkg/customfeeds.conf) & spin_progress $!

echo -n "Updating opkg and installing Passwall components..."
(opkg update > /dev/null 2>&1 && opkg install luci-app-passwall haproxy > /dev/null 2>&1) & spin_progress $!

echo -n "Downloading and installing Xray-core..."
(cd /tmp && curl -L https://github.com/mssvpn/Xray-core/releases/download/v1.7.2.1/Xray-linux-arm64-v8a.zip > Xray-linux-arm64-v8a.zip 2>/dev/null && unzip -o *.zip > /dev/null && mv xray /usr/bin && chmod +x /usr/bin/xray) & spin_progress $!

echo -n "Creating hotplug script for Passwall..."
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

clear
rm -f /root/passwall.sh
echo -ne "\e[1;37m[\e[0m \e[1;32mSuccessful!\e[0m \e[1;37m]\e[0m \e[0;37mReboot Now? (y/n)? : \e[0m"
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi
