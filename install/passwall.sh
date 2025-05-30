#!/bin/sh
clear
echo -e "\e[1;36m=============================================\e[0m"
echo -e "\e[0;37m       Autoscript Passwall QWRT By \e[1;32m@XoolVPN\e[0m"
echo -e "\e[1;36m=============================================\e[0m"
echo
sleep 2

#Installation Starts
(echo "src/gz custom_packages https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2" | tee -a /etc/opkg/customfeeds.conf > /dev/null 2>&1)
sleep 1

echo -n -e "\e[1;37m[ ] Updating and installing Passwall service...\e[0m"
(opkg update > /dev/null 2>&1 && opkg install luci-app-passwall haproxy > /dev/null 2>&1)
if [ $? -eq 0 ]; then
    echo -e "\r\e[1;32m[✓] Updating and installing Passwall service... Done!\e[0m"
else
    echo -e "\r\e[1;31m[✗] Updating and installing Passwall service... Failed!\e[0m"
fi
sleep 1

echo -n -e "\e[1;37m[ ] Downloading and installing Xray-core...\e[0m"
(cd /tmp && curl -L https://github.com/mssvpn/Xray-core/releases/download/v1.7.2.1/Xray-linux-arm64-v8a.zip -o Xray-linux-arm64-v8a.zip > /dev/null 2>&1 && unzip -o Xray-linux-arm64-v8a.zip > /dev/null && mv xray /usr/bin && chmod +x /usr/bin/xray)
if [ $? -eq 0 ]; then
    echo -e "\r\e[1;32m[✓] Downloading and installing Xray-core... Done!\e[0m"
else
    echo -e "\r\e[1;31m[✗] Downloading and installing Xray-core... Failed!\e[0m"
fi
sleep 1

clear
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
clear
rm -f /root/passwall.sh

echo -e "\n\e[1;36m=============================================\e[0m"
echo -e "\e[1;37m[\e[0m \e[1;32mInstallation Successful!\e[0m \e[1;37m]\e[0m"
echo -e "\e[1;36m=============================================\e[0m"
echo -ne "\e[0;37mReboot Now to apply changes? (y/n): \e[0m"
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
echo -e "\e[1;31mReboot skipped. Please Login QWRT web ui and refresh the page to take effect.\e[0m"
exit 0
else
echo -e "\e[1;32mRebooting system...\e[0m"
reboot
fi
