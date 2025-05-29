#!/bin/sh
clear
echo -e "\e[0;37mAutoscript Passwall QWRT By\e[0m \e[1;32m@XoolVPN\e[0m"
sleep 3

clear
echo -e "\e[1;37m[\e[0m \e[1;32mInstallation Starts Now...\e[0m \e[1;37m]\e[0m"
sleep 2
echo "src/gz custom_packages https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2" | tee -a /etc/opkg/customfeeds.conf >/dev/null 2>&1
opkg update >/dev/null 2>&1
opkg install luci-app-passwall htop haproxy >/dev/null 2>&1
(
    cd /tmp && \
    curl -L https://github.com/mssvpn/Xray-core/releases/download/v1.7.2.1/Xray-linux-arm64-v8a.zip -o Xray-linux-arm64-v8a.zip && \
    unzip -o Xray-linux-arm64-v8a.zip >/dev/null 2>&1 && \
    mv xray /usr/bin/xray && \
    chmod +x /usr/bin/xray && \
)

clear
echo -e "\e[1;37m[\e[0m \e[1;32mDownloading...Please Wait...\e[0m \e[1;37m]\e[0m"
sleep 3
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
