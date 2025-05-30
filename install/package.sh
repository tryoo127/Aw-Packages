#!/bin/sh
clear
echo -e "\e[1;36m=============================================\e[0m"
echo -e "\e[1;37m     Installer Package QWRT By \e[1;32m@XoolVPN\e[0m"
echo -e "\e[1;36m=============================================\e[0m"
sleep 2

execute_and_check() {
    local cmd="$1"
    local message="$2"
    echo -n -e "\e[1;37m$message...\e[0m"
    eval "$cmd" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\r\e[1;37m$message...\e[0m\e[1;32mDone!\e[0m"
    else
        echo -e "\r\e[1;31m$message...Failed!\e[0m"
    fi
}

execute_and_check "rm -f /etc/rc.local && cat > /etc/rc.local <<-'RCD'
#!/bin/sh -e

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
chmod +x /etc/rc.local && /etc/rc.local enable && /etc/rc.local start && /etc/rc.local restart" "- Setting up TTL modifications"

execute_and_check "uci set luci.main.lang='en'; uci commit" "- Setting language to English"
execute_and_check "uci set system.@system[0].zonename='Asia/Kuala Lumpur'; uci commit system" "- Change timezone to Asia/Kuala Lumpur"
execute_and_check "uci -q delete system.ntp.server; uci add_list system.ntp.server='time.cloudflare.com'; uci commit system.ntp; /etc/init.d/sysntpd restart" "- Configuring and restarting NTP service"
execute_and_check "uci set network.wan.ifname='wwan0_1'; uci commit network.wan" "- Setting WAN interface network"
execute_and_check "uci set network.wan6.ifname='wwan0_1'; uci commit network.wan6" "- Setting WAN6 interface network"
execute_and_check "uci set turboacc.config.bbr_cca='1'; uci commit turboacc.config" "- Set CPU modem performance"
execute_and_check "uci set turboacc.config.dns_caching='1'; uci set turboacc.config.dns_caching_dns='1.1.1.1,1.0.0.1'; uci commit turboacc.config" "- Set DNS & enable BBR CCA"
execute_and_check "uci set cpufreq.cpufreq.governor='performance'; uci commit cpufreq.cpufreq" "- Set CPU to maximum frequency"
uci set cpufreq.cpufreq.minifreq='2208000'; uci commit cpufreq.cpufreq
uci set dhcp.lan.dhcp_option='6,1.1.1.1,1.0.0.1'; uci commit dhcp.lan
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
wget -q -O /etc/config/rirq "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/rirq";
wget -q -O /etc/hotplug.d/iface/82-irqbalance "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/82-irqbalance";
wget -q -O /etc/hotplug.d/net/97-smp-tune "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/97-smp-tune";
sleep 3

clear
rm -f /root/package.sh
echo -ne "\e[1;37m[\e[0m \e[1;32mSuccessful!\e[0m \e[1;37m]\e[0m \e[1;37mReboot Now? (y/n)? : \e[0m"
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
    echo -e "\e[1;31mReboot skipped. Please reboot manually for changes to take effect.\e[0m"
    exit 0
else
    echo -e "\e[1;32mRebooting...\e[0m"
    reboot
fi
