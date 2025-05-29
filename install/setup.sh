#!/bin/bash
clear
echo -ne "\e[0;37mOneliner QWRT By\e[0m \e[1;32mXoolVPN\e[0m"
sleep 3

clear
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
    echo -ne "\e[1;32mInstallation In Progress\e[0m \e[1;37m[\e[0m"
    while true; do
        for ((i = 0; i < 15; i++)); do
            echo -ne "\033[0;32m>"
            sleep 0.1s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e "\033[0;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "\e[1;32mInstallation In Progress\e[0m \e[1;37m[\e[0m"
    done
    echo -e "\e[1;37m] -\e[0m \033[1;32m Done!\033[1;37m"
    tput cnorm
    sleep 3s
}

res1() {
    wget -q -O /usr/bin/nf https://raw.githubusercontent.com/vinstechmy/MediaUnlockerTest/main/media.sh && chmod +x /usr/bin/nf
}

echo -e "\e[1;37mDownloading Passwall\e[0m"
fun_bar 'res1'
echo  ""

rm -f /root/setup.sh
clear
echo -ne "\e[1;37m[\e[0m \e[1;32mSuccessful!\e[0m \e[1;37m]\e[0m \e[0;37mReboot Now? (y/n)? : \e[0m"
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi
