#!/bin/sh
WHITE='\e[1;37m'
GREEN='\e[1;32m'
RED='\e[1;31m'
NC='\e[0m' # No Color

clear
echo -e "\e[0;37mAutoscript Passwall QWRT By\e[0m \e[1;32m@XoolVPN\e[0m"
sleep 3

clear
echo -e "\e[1;37m[\e[0m \e[1;32mInstallation Starts Now...\e[0m \e[1;37m]\e[0m"
sleep 2

clear
# Function to display progress messages
log_message() {
    echo -e "${WHITE} ${1} ${NC}"
}

# Function to check if a command was successful
check_command() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  - ${1} successful.${NC}"
    else
        echo -e "${RED}  - ${1} FAILED! Exiting.${NC}"
        exit 1
    fi
}

echo "src/gz custom_packages https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2" | tee -a /etc/opkg/customfeeds.conf >/dev/null 2>&1
opkg update >/dev/null 2>&1
log_message "Installing Passwall. Please wait..."
opkg install luci-app-passwall htop haproxy

log_message "Installing Xray core. Please wait..."
    cd /tmp && \
    curl -L https://github.com/mssvpn/Xray-core/releases/download/v1.7.2.1/Xray-linux-arm64-v8a.zip -o Xray-linux-arm64-v8a.zip && \
    check_command "Xray download" && \
    unzip -o Xray-linux-arm64-v8a.zip >/dev/null 2>&1 && \
    check_command "Xray unzip" && \
    mv xray /usr/bin/xray && \
    chmod +x /usr/bin/xray && \

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
rm -f /root/setup.sh
echo -ne "\e[1;37m[\e[0m \e[1;32mSuccessful!\e[0m \e[1;37m]\e[0m \e[0;37mReboot Now? (y/n)? : \e[0m"
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi
