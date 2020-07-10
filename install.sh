#!/bin/bash
me=$(whoami)
dirpath=$(pwd)

# Set no password for sudo
echo "unifi ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# Set autologin
cat > /home/$me/override.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --noissue --autologin $me %I \$TERM
Type=idle
EOF
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
sudo mv /home/$me/override.conf /etc/systemd/system/getty@tty1.service.d/
sudo chown -R root:root /etc/systemd/system/getty@tty1.service.d

# Update and clone repo and install requirements
sudo apt update
sudo apt upgrade -y
sudo apt install python3-pip git -y
git clone https://github.com/UncleDan/unifi-va.git /home/$me/unifi-va
sudo pip3 install -r /home/$me/unifi-va/requirements.txt
chmod 755 /home/$me/unifi-va/*.sh

# Install VMware Tools
sudo apt install open-vm-tools

# Download Glenn R. scripts and launch install
rm /home/$me/unifi-va/unifi-latest.sh &> /dev/null
curl https://get.glennr.nl/unifi/install/install_latest/unifi-latest.sh --output /home/$me/unifi-va/unifi-latest.sh &> /dev/null
rm /home/$me/unifi-va/unifi-update.sh &> /dev/null
curl https://get.glennr.nl/unifi/update/unifi-update.sh --output /home/$me/unifi-va/unifi-update.sh &> /dev/null
rm unifi-lets-encrypt.sh &> /dev/null
curl https://get.glennr.nl/unifi/extra/unifi-lets-encrypt.sh --output /home/$me/unifi-va/unifi-lets-encrypt.sh &> /dev/null
chmod 755 /home/$me/unifi-va/*.sh
sudo /home/$me/unifi-va/unifi-latest.sh --skip

# Enable menu
cd /etc/profile.d/
sudo ln -s /home/$me/unifi-va/menu.sh
cd ~

# Bye
echo -e "\nAll done. Type 'exit' and re-login tu use @recklessop menu!\n"
