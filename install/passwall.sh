#!/bin/sh
GREEN="\e[1;32m"
WHITE="\e[1;37m"
YELLOW="\e[1;33m"
CYAN="\e[1;36m"
NC="\e[0m" # No Color

# Initial welcome banner
echo -e "${CYAN}-----------------------------------------------------${NC}"
echo -e "${WHITE}  Autoscript Passwall QWRT By ${GREEN}@XoolVPN${NC}"
echo -e "${CYAN}-----------------------------------------------------${NC}"
echo ""
echo -e "${YELLOW}Starting Passwall and Xray installation...${NC}"
sleep 2

# Start a spinner or progress indicator while commands run silently
(
  # Add custom opkg feed
  echo "src/gz custom_packages https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2" | tee -a /etc/opkg/customfeeds.conf

  # Update opkg and install packages
  opkg update
  opkg install luci-app-passwall htop haproxy

  # Download, extract, and move Xray
  cd /tmp
  curl -L https://github.com/mssvpn/Xray-core/releases/download/v1.7.2.1/Xray-linux-arm64-v8a.zip > Xray-linux-arm64-v8a.zip && \
  unzip -o Xray-linux-arm64-v8a.zip && \
  mv xray /usr/bin && \
  chmod +x /usr/bin/xray

  # Create hotplug script for Passwall restart on WAN up
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

) > /dev/null 2>&1 & # Run the entire installation block in the background and suppress all its output

# Display a progress indicator while the background process is running
pid=$! # Get the PID of the background process
i=1
sp="/-\|"
echo -n "${YELLOW}Working... ${NC}"
while kill -0 $pid 2>/dev/null; do
  printf "\b%c" "${sp:i++%${#sp}:1}"
  sleep 0.1
done
echo -ne "\n" # Newline after spinner finishes

clear

# Final success message and reboot prompt
rm -f /root/passwall.sh # Remove the script itself
echo -e "${CYAN}-----------------------------------------------------${NC}"
echo -e "${WHITE}  Passwall and Xray Installation ${GREEN}COMPLETE!${NC}"
echo -e "${CYAN}-----------------------------------------------------${NC}"
echo ""
echo -ne "${WHITE}  ${GREEN}[Successful!]${NC} ${WHITE}Reboot Now? (y/n)? : ${NC}"
read answer

if [ "$answer" == "${answer#[Yy]}" ] ;then
  echo -e "${YELLOW}  Exiting without reboot. Please reboot manually later.${NC}"
  sleep 2
  exit 0
else
  echo -e "${GREEN}  Rebooting router now...${NC}"
  sleep 2
  reboot
fi
