#!/bin/bash
clear
echo -e "\e[0;37mQWRT Package Installer By\e[0m \e[1;32m@XoolVPN\e[0m"
sleep 3

rm -rf /etc/rc.local
cat > /etc/rc.local <<-RCD
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
chmod +x /etc/rc.local
/etc/rc.local enable
/etc/rc.local start
/etc/rc.local restart

uci set luci.main.lang='en'; uci commit
uci set system.@system[0].zonename='Asia/Kuala Lumpur'; uci commit
uci -q delete system.ntp.server
uci add_list system.ntp.server='time.cloudflare.com'
uci commit system.ntp;/etc/init.d/sysntpd restart
uci set network.wan.ifname='wwan0_1'; uci commit network.wan
uci set network.wan6.ifname='wwan0_1'; uci commit network.wan6

clear
echo -e "\e[1;37m[\e[0m \e[1;32mInstallation Starts Now...\e[0m \e[1;37m]\e[0m"
sleep 3

wget -q -O /usr/lib/lua/luci/model/cbi/rooter/customize.lua "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/customize.lua";
wget -q -O /usr/lib/lua/luci/model/cbi/rooter/profiles.lua "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/profiles.lua";
wget -q -O /usr/lib/lua/luci/controller/admin/modem.lua "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/modem.lua";
wget -q -O /usr/lib/lua/luci/controller/modlog.lua "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/modlog.lua";
wget -q -O /usr/lib/lua/luci/controller/sms.lua "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/sms.lua";
wget -q -O /usr/lib/lua/luci/view/rooter/debug.htm "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/debug.htm";
wget -q -O /usr/lib/lua/luci/view/rooter/misc.htm "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/misc.htm";
wget -q -O /usr/lib/lua/luci/view/rooter/custom.htm "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/custom.htm";
wget -q -O /usr/lib/lua/luci/view/rooter/net_status.htm "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/net_status.htm";
wget -q -O /usr/lib/lua/luci/view/rooter/sms.htm "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/sms.htm";
wget -q -O /usr/lib/lua/luci/view/modlog/modlog.htm "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/modlog.htm";
wget -q -O /usr/bin/speedtest "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/speedtest";chmod +x /usr/bin/speedtest

clear
echo -e "\e[1;37m[\e[0m \e[1;32mInstall TuneCPU Modem\e[0m \e[1;37m]\e[0m"
sleep 3

clear
uci set turboacc.config.bbr_cca='1'; uci commit turboacc.config
uci set turboacc.config.dns_caching='1'; uci set turboacc.config.dns_caching_dns='1.1.1.1,1.0.0.1'; uci commit turboacc.config
uci set cpufreq.cpufreq.governor='performance'; uci commit cpufreq.cpufreq
uci set cpufreq.cpufreq.minifreq='2208000'; uci commit cpufreq.cpufreq
uci set dhcp.lan.dhcp_option='6,1.1.1.1,1.0.0.1'; uci commit dhcp.lan

wget -q -O /etc/config/rirq "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/rirq";
wget -q -O /etc/hotplug.d/iface/82-irqbalance "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/82-irqbalance";
wget -q -O /etc/hotplug.d/net/97-smp-tune "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/97-smp-tune";
clear

clear
echo -e "\e[1;37m[\e[0m \e[1;32mInstall Passwall Service\e[0m \e[1;37m]\e[0m"
sleep 3

clear
echo "src/gz custom_packages https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2" | tee -a /etc/opkg/customfeeds.conf;opkg update;opkg install luci-app-passwall htop haproxy;cd /tmp;curl -L https://github.com/mssvpn/Xray-core/releases/download/v1.7.2.1/Xray-linux-arm64-v8a.zip > Xray-linux-arm64-v8a.zip && unzip *.zip && mv xray /usr/bin && chmod +x /usr/bin/xray

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
echo -e "\e[1;37m[\e[0m \e[1;32mDownloading...Please Wait...\e[0m \e[1;37m]\e[0m"
sleep 3

clear
rm -f /root/qwrt-package.sh
echo -ne "\e[1;37m[\e[0m \e[1;32mSuccessful!\e[0m \e[1;37m]\e[0m \e[0;37mReboot Now? (y/n)? : \e[0m"
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi
