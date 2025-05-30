#!/bin/sh
clear
echo -e "\e[1;36m=============================================\e[0m"
echo -e "\e[1;37m     Autoscript Oneliner QWRT By \e[1;32m@XoolVPN\e[0m"
echo -e "\e[1;36m=============================================\e[0m"
echo
sleep 2

#Installation Starts
execute_and_check() {
    local cmd="$1"
    local message="$2"
    echo -n -e "\e[1;37m$message...\e[0m"
    # Run command in background and redirect output to /dev/null
    eval "$cmd" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\r\e[1;37m$message...\e[0m\e[1;32mDone!\e[0m"
    else
        echo -e "\r\e[1;31m$message...Failed!\e[0m"
    fi
}

# Step 1: Configure /etc/rc.local for TTL settings
execute_and_check "rm -f /etc/rc.local && cat > /etc/rc.local <<-'RCD'
#!/bin/sh -e

# Apply TTL settings to modify network packets
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
exit 0
RCD
chmod +x /etc/rc.local && /etc/rc.local enable && /etc/rc.local start && /etc/rc.local restart" "Setting up TTL modifications."

# Step 2: Configure LuCI language and System Timezone
execute_and_check "uci set luci.main.lang='en'; uci commit" "Setting language to English"
execute_and_check "uci set system.@system[0].zonename='Asia/Kuala_Lumpur'; uci commit" "Setting system timezone to Asia/Kuala_Lumpur"

# Step 3: Configure NTP server
execute_and_check "uci -q delete system.ntp.server; uci add_list system.ntp.server='time.cloudflare.com'; uci commit system.ntp; /etc/init.d/sysntpd restart" "Configuring and restarting NTP with Cloudflare"

# Step 4: Configure WAN interface names
execute_and_check "uci set network.wan.ifname='wwan0_1'; uci commit network.wan" "Setting WAN interface to wwan0_1"
execute_and_check "uci set network.wan6.ifname='wwan0_1'; uci commit network.wan6" "Setting WAN6 interface to wwan0_1"

# Step 5: Download and update LuCI web interface files
echo -e "\r\e[1;37mDownloading LuCI web interface files...\e[0m\e[1;32mDone!\e[0m"
wget -q -O /usr/lib/lua/luci/model/cbi/rooter/customize.lua "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/customize.lua" &> /dev/null
wget -q -O /usr/lib/lua/luci/model/cbi/rooter/profiles.lua "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/profiles.lua" &> /dev/null
wget -q -O /usr/lib/lua/luci/controller/admin/modem.lua "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/modem.lua" &> /dev/null
wget -q -O /usr/lib/lua/luci/controller/modlog.lua "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/modlog.lua" &> /dev/null
wget -q -O /usr/lib/lua/luci/controller/sms.lua "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/sms.lua" &> /dev/null
wget -q -O /usr/lib/lua/luci/view/rooter/debug.htm "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/debug.htm" &> /dev/null
wget -q -O /usr/lib/lua/luci/view/rooter/misc.htm "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/misc.htm" &> /dev/null
wget -q -O /usr/lib/lua/luci/view/rooter/custom.htm "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/custom.htm" &> /dev/null
wget -q -O /usr/lib/lua/luci/view/rooter/net_status.htm "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/net_status.htm" &> /dev/null
wget -q -O /usr/lib/lua/luci/view/rooter/sms.htm "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/sms.htm" &> /dev/null
wget -q -O /usr/lib/lua/luci/view/modlog/modlog.htm "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/modlog.htm" &> /dev/null
echo
sleep 5

clear
rm -f /root/oneliner.sh
echo -ne "\e[1;37m[\e[0m \e[1;32mSuccessful!\e[0m \e[1;37m]\e[0m \e[0;37mReboot Now? (y/n)? : \e[0m"
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
    echo -e "\e[1;31mReboot skipped. Please reboot manually later for changes to take effect.\e[0m"
    exit 0
else
    echo -e "\e[1;32mRebooting...\e[0m"
    reboot
fi
