#!/bin/bash
clear
echo -e "\e[0;37mAutoscript Oneliner QWRT By\e[0m \e[1;32mXoolVPN\e[0m"
sleep 3

clear
#!/bin/sh
fun_bar() {
    tput civis
    echo -e "\e[1;32mPlease Wait\e[0m"
    echo -e "\[1;32mDone!\e[0m"
    tput cnorm
    sleep 3s
}

sc1() {
    wget -q -O /usr/bin/nf https://raw.githubusercontent.com/vinstechmy/MediaUnlockerTest/main/media.sh && chmod +x /usr/bin/nf
}
echo -e "\e[1;37mDownloading Now\e[0m"
fun_bar 'sc1'

rm -f /root/setup.sh
clear
echo -e "\e[1;37m[\e[0m \e[1;32mSuccessful!\e[0m \e[1;37m]\e[0m \e[0;37mReboot Now? (y/n)? : \e[0m"
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi
