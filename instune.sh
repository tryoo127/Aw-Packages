#!/bin/bash
clear
echo -e "\e[0;37mAutoscript TuneCPU QWRT By\e[0m \e[1;32m@XoolVPN\e[0m"
sleep 3

clear
uci set turboacc.config.bbr_cca='1'; uci commit turboacc.config
uci set turboacc.config.dns_caching='1'; uci set turboacc.config.dns_caching_dns='1.1.1.1,1.0.0.1'; uci commit turboacc.config
uci set cpufreq.cpufreq.governor='performance'; uci commit cpufreq.cpufreq
uci set cpufreq.cpufreq.minifreq='2208000'; uci commit cpufreq.cpufreq
uci set dhcp.lan.dhcp_option='6,1.1.1.1,1.0.0.1'; uci commit dhcp.lan

clear
echo -e "\e[1;37m[\e[0m \e[1;32mInstallation Starts Now...\e[0m \e[1;37m]\e[0m"
sleep 3

wget -q -O /etc/config/rirq "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/rirq";
wget -q -O /etc/hotplug.d/iface/82-irqbalance "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/82-irqbalance";
wget -q -O /etc/hotplug.d/net/97-smp-tune "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/97-smp-tune";

clear
# Running Code 20%
echo -ne '>>>>>>>>                   [20%]\r'
sleep 1

clear
# Running Code 60%
echo -ne '>>>>>>>>>                  [60%]\r'
sleep 1

clear
# Running Code 80%
echo -ne '>>>>>>>>>>>>>>             [80%]\r'
sleep 1

clear
# Running Code 100%
echo -ne '>>>>>>>>>>>>>>>>>>>>>>>>>>[100%]\r'
sleep 3

clear
echo -e "\e[1;37m[\e[0m \e[1;32mDownloading...Please Wait...\e[0m \e[1;37m]\e[0m"
sleep 3

clear
echo -ne "\e[1;37m[\e[0m \e[1;32mSuccessful!\e[0m \e[1;37m]\e[0m \e[0;37mReboot Now? (y/n)? : \e[0m"
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi
