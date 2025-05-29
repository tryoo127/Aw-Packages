#!/bin/bash
clear
echo -ne "\e[0;37mAutoscript Passwall QWRT By\e[0m \e[1;32mXoolVPN\e[0m"
sleep 3

clear
#!/bin/sh
fun_bar() {
    CMD[0]="$1"
    CMD[1]="$2"
    (
        [[ -e $HOME/fim ]] && rm $HOME/fim
        ${CMD[0]} -y >/dev/null 2>&1
        ${CMD[1]} -y >/dev/null 2>&1
        touch $HOME/fim
    ) >/dev/null 2>&1 &
    tput civis
    echo -ne "\e[1;32mPlease Wait\e[0m \e[1;37m[\e[0m"
    while true; do
        for ((i = 0; i < 15; i++)); do
            echo -ne "\033[0;32m>"
            sleep 0.2s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e "\033[0;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "\e[1;32mPlease Wait\e[0m \e[1;37m[\e[0m"
    done
    echo -e "\e[1;37m] -\e[0m \033[1;32mDone!\033[1;37m"
    tput cnorm
    sleep 3s
}

sc1() {
echo "src/gz custom_packages https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2" | tee -a /etc/opkg/customfeeds.conf;opkg update;opkg install luci-app-passwall htop haproxy;cd /tmp;curl -L https://github.com/mssvpn/Xray-core/releases/download/v1.7.2.1/Xray-linux-arm64-v8a.zip > Xray-linux-arm64-v8a.zip && unzip *.zip && mv xray /usr/bin && chmod +x /usr/bin/xray

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
}
echo -e "\e[1;37mDownloading Now\e[0m"
fun_bar 'sc1'

rm -f /root/setup.sh
clear
echo -ne "\e[1;37m[\e[0m \e[1;32mSuccessful!\e[0m \e[1;37m]\e[0m \e[0;37mReboot Now? (y/n)? : \e[0m"
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi
