#!/bin/bash
clear
echo ""
echo -e "\e[1;36m=================================================\e[0m"
echo -e "\e[0;37mAutoscript TuneCPU QWRT By\e[0m \e[1;32m@XoolVPN\e[0m"
echo -e "\e[1;36m=================================================\e[0m"
echo ""
sleep 1

# Function for silent UCI configuration with progress
configure_uci() {
    local path=$1
    local value=$2
    local message=$3
    echo -n "$message"
    uci set "$path"="$value" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        # Commit only the specific UCI section
        uci commit "${path%%.*}" > /dev/null 2>&1 
        if [ $? -eq 0 ]; then
            echo -e "\e[1;32mDone!\e[0m""
        else
            echo -e "\e[1;31mFailed (commit).\e[0m"
            return 1
        fi
    else
        echo -e "\e[1;31mFailed (set).\e[0m"
        return 1
    fi
    return 0
}

# Apply UCI settings silently with real-time feedback
configure_uci "turboacc.config.bbr_cca" "1" "Setting BBR CCA (TCP congestion control)... " || exit 1
configure_uci "turboacc.config.dns_caching" "1" "Enabling DNS caching... " || exit 1
configure_uci "turboacc.config.dns_caching_dns" "1.1.1.1,1.0.0.1" "Setting DNS caching servers to Cloudflare... " || exit 1
configure_uci "cpufreq.cpufreq.governor" "performance" "Setting CPU governor to 'performance'... " || exit 1
configure_uci "cpufreq.cpufreq.minifreq" "2208000" "Setting minimum CPU frequency to 2.208 GHz... " || exit 1
configure_uci "dhcp.lan.dhcp_option" "6,1.1.1.1,1.0.0.1" "Setting LAN DHCP DNS option to Cloudflare... " || exit 1

# Function for silent wget download with reactive progress and permission setting
download_file() {
    local url=$1
    local dest=$2
    local filename=$(basename "$dest")
    echo -n "Downloading \e[1;37m$filename\e[0m: "

    # Execute wget in the background, suppressing all output
    wget -q -O "$dest" "$url" > /dev/null 2>&1 &
    local WGET_PID=$! # Capture PID for monitoring

    # Reactive progress indicator
    while kill -0 "$WGET_PID" 2>/dev/null; do
        echo -n "."
        sleep 0.5 # Check every half second
    done
    echo " Done."

    # Verify download success
    if [ -f "$dest" ] && [ -s "$dest" ]; then
        echo -e "\e[1;32mSuccessfully downloaded: $filename\e[0m"
        # Set executable permissions for hotplug scripts
        if [[ "$dest" == *"/etc/hotplug.d/"* ]]; then
            echo -n "Applying executable permissions for \e[1;37m$filename\e[0m... "
            chmod +x "$dest" > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo -e "\e[1;32mDone.\e[0m"
            else
                echo -e "\e[1;31mFailed to set permissions.\e[0m"
                return 1
            fi
        fi
        return 0
    else
        echo -e "\e[1;31mError: Failed to download $filename or file is empty.\e[0m"
        return 1
    end
}

# Download and install tuning scripts sequentially
download_file "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/rirq" "/etc/config/rirq" || exit 1
download_file "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/82-irqbalance" "/etc/hotplug.d/iface/82-irqbalance" || exit 1
download_file "https://raw.githubusercontent.com/tryoo127/Aw-Packages/main/system/97-smp-tune" "/etc/hotplug.d/net/97-smp-tune" || exit 1

## Installation Complete & Cleanup

echo ""
echo -e "\e[1;37mAll system configurations and tuning scripts have been deployed.\e[0m"
echo ""

echo -n "Cleaning up temporary script file \e[1;37m/root/tunecpu.sh\e[0m... "
if rm -f /root/tunecpu.sh; then
    echo -e "\e[1;32mDone.\e[0m"
else
    echo -e "\e[1;31mFailed to clean up. (File might not have existed)\e[0m"
fi

echo ""
echo -ne "\e[1;37m[\e[0m \e[1;32mSuccessful!\e[0m \e[1;37m]\e[0m \e[0;37mReboot Now? (y/n)? : \e[0m"
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
    echo -e "\e[1;31mReboot skipped. Please reboot manually for changes to take effect.\e[0m"
    exit 0
else
    echo -e "\e[1;32mRebooting...\e[0m"
    reboot
fi