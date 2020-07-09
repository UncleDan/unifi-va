#!/bin/bash
##########################################################
#
# Info and Config Menu for Unifi Appliance
#
# Disclaimer: Unifi is a trademark of Ubiquiti Networks
# I make no claim to their I.P. and provide this virtual
# appliance for simplicity for new users. I make no 
# guarentee that it works, or that it will be super awesome
# use at your own risk.
#
##########################################################
while true
do
  # get network information (get each time in case it changes)
  interface=$(cat /etc/network/interfaces | grep -i "iface" | grep -vi "lo" | awk '{print $2}')
  interface=$(python3 /home/unifi/unifi-va/netinfo.py interface)
  ipinfo=$(python3 /home/unifi/unifi-va/netinfo.py address)
  ipgw=$(ip route | grep -i "default" | awk '{ print $3 }')

  # start menu output
  clear
  echo "  _    _       _  __ _    _____            _             _ _           "
  echo " | |  | |     (_)/ _(_)  / ____|          | |           | | |          "
  echo " | |  | |_ __  _| |_ _  | |     ___  _ __ | |_ _ __ ___ | | | ___ _ __ "
  echo " | |  | | '_ \| |  _| | | |    / _ \| '_ \| __| '__/ _ \| | |/ _ \ '__|"
  echo " | |__| | | | | | | | | | |___| (_) | | | | |_| | | (_) | | |  __/ |   "
  echo -e "  \____/|_| |_|_|_| |_|  \_____\___/|_| |_|\__|_|  \___/|_|_|\___|_|   \n"
  echo -e "      V I R T U A L   A P P L I A N C E   B Y   R E C K L E S S O P\n"
  echo -e "   F E A T U R I N G   G L E N N   R.   I N S T A L L   S C R I P T S\n"
  echo "Current Network Config:"
  echo "   Interface Name: $interface"
  echo "   Details: $ipinfo"
  echo -e "   Default Gateway: $ipgw\n"
  echo -e "Select an action from the menu below:\n"
  echo "1. Update Unifi Application   | 2. Configure Network Settings"
  echo "3. Update Unifi-va Scripts    | 4. Bash Shell"
  echo "5. Change unifi user password | 6. Update system UUIDs"
  echo -e "7. Exit\n"
  read choice
  case "$choice" in
          1) # Update Unifi Appliance
              clear
              echo "Updating Unifi from Ubuntu APT repo"
              (sudo apt update && sudo apt upgrade -y)
              ;;
          2) # Config Network Settings
              clear
              echo "====================="
              echo "Network Config Wizard"
              echo -e "=====================\n"
              (sudo python3 /home/unifi/unifi-va/netplan-cfg.py)
              echo "Running Netplan Generate & Netplan Apply"
              (sudo netplan generate)
              (sudo netplan apply)
              echo "Press any key to reboot"
              read reboot
              sudo reboot
              ;;
          3) # Update Unifi Scripts from Github
              clear
              echo "Updating Unifi from GitHub"
              (cd /home/unifi/unifi-va/ && git reset --hard HEAD && git pull https://github.com/UncleDan/unifi-va/)
              rm /home/unifi/unifi-va/unifi-latest.sh &> /dev/null
              curl https://get.glennr.nl/unifi/install/install_latest/unifi-latest.sh --output /home/unifi/unifi-va/unifi-latest.sh &> /dev/null
              rm /home/unifi/unifi-va/unifi-update.sh &> /dev/null
              curl https://get.glennr.nl/unifi/update/unifi-update.sh --output /home/unifi/unifi-va/unifi-update.sh &> /dev/null
              rm unifi-lets-encrypt.sh &> /dev/null
              curl https://get.glennr.nl/unifi/extra/unifi-lets-encrypt.sh --output /home/unifi/unifi-va/unifi-lets-encrypt.sh &> /dev/null
              ;;
          4) # enter bash shell prompt
              clear
              /bin/bash
              ;;
          5) # enter bash shell prompt
              clear
	      echo "Enter a new password for user unifi:"
              /usr/bin/passwd
              ;;
          6) # update system UUIDs
              uuid=$(uuidgen)
              reporter=$(uuidgen)
              echo "Setting system uuid to $uuid"
              sudo sed -i ':a;N;$!ba;s/uuid=[A-Fa-f0-9-]*/uuid='"$uuid"'/2' /var/lib/unifi/system.properties
              echo "Setting system reporter-id to $reporter"
              sudo sed -i ':a;N;$!ba;s/uuid=[A-Fa-f0-9-]*/uuid='"$reporter"'/1' /var/lib/unifi/system.properties
              echo "Restarting Unifi service"
              sudo /etc/init.d/unifi restart
              ;;

          7) # exit the menu script
              exit
              ;;
          *) echo "invalid option try again";;
      esac
      echo "Press any key to Continue..."
      read input
done
done

