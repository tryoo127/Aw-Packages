#!/bin/sh
clear
echo "\033[0;37mAutoscript Oneliner QWRT By\033[0m \033[1;32mXoolVPN\033[0m"
sleep 3

clear
fun_bar() {
    CMD0="$1"
    CMD1="$2"
    (
        [ -e "$HOME/fim" ] && rm "$HOME/fim"
        # Since CMD1 is not used in your original fun_bar call, it's commented out here
        # to avoid potential issues if it's empty or unexpected.
        # If CMD1 is intended to be used, ensure it's a valid command.
        $CMD0 -y >/dev/null 2>&1
        # $CMD1 -y >/dev/null 2>&1
        touch "$HOME/fim"
    ) >/dev/null 2>&1 &
    tput civis
    echo "\033[1;32mPlease Wait\033[0m \033[1;37m[\033[0m\c"
    while true; do
        i=0
        while [ "$i" -lt 15 ]; do
            echo "\033[0;32m>\c"
            sleep 0.2s
            i=$((i + 1))
        done
        [ -e "$HOME/fim" ] && rm "$HOME/fim" && break
        echo "\033[0;33m]\c"
        sleep 1s
        tput cuu1
        tput dl1
        echo "\033[1;32mPlease Wait\033[0m \033[1;37m[\033[0m\c"
    done
    echo "\033[1;37m] -\033[0m \033[1;32mDone!\033[1;37m"
    tput cnorm
    sleep 3s
}

sc1() {
    wget -q -O /usr/bin/nf https://raw.githubusercontent.com/vinstechmy/MediaUnlockerTest/main/media.sh && chmod +x /usr/bin/nf
}

echo "\033[1;37mDownloading Now\033[0m"
fun_bar 'sc1'

rm -f /root/setup.sh
clear
echo "\033[1;37m[\033[0m \033[1;32mSuccessful!\033[0m \033[1;37m]\033[0m \033[0;37mReboot Now? (y/n)? : \033[0m\c"
read answer
if [ "$answer" = "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi
