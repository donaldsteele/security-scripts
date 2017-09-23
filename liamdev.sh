#!/bin/bash 
# le big shebang

less -FX liamdev.txt # Show figlet text

if [[ $EUID -ne 0 ]]; then
   echo "ERROR!  Script is not being run as root!" 
   exit 1
   else echo "Success!  Script is being run as root."
fi # Checks for root

# Firewall
sudo ufw enable
sudo ufw deny 23
sudo ufw deny 2049
sudo ufw deny 515
sudo ufw deny 111

# Updates
sudo apt-get -y upgrade
sudo apt-get -y update

# Shuts off Guest ACCT
sudo echo "allow-guest=false" .. /etc/lightdm/lightdm.conf

# Password Age Limits
sudo sed -i '/^PASS_MAX_DAYS/ c\PASS_MAX_DAYS   90' /etc/login.defs
sudo sed -i '/^PASS_MIN_DAYS/ c\PASS_MIN_DAYS   10'  /etc/login.defs
sudo sed -i '/^PASS_WARN_AGE/ c\PASS_WARN_AGE   7' /etc/login.defs

# Password Auth
sudo sed -i '1 s/^/auth optional pam_tally.so deny=5 unlock_time=900 onerr=fail audit even_deny_root_account silent\n/' /etc/pam.d/common-auth

# Makes strong password
sudo apt-get -y install libpam-cracklib
sudo sed -i '1 s/^/password requisite pam_cracklib.so retry=3 minlen=8 difok=3 reject_username minclass=3 maxrepeat=2 dcredit=1 ucredit=1 lcredit=1 ocredit=1\n/' /etc/pam.d/common-password

# Cracking tools/malware.  You get the drift.
sudo apt-get -y purge hydra*
sudo apt-get -y purge john*
sudo apt-get -y purge nikto*
sudo apt-get -y purge netcat*

# Enables auto updates
sudo dpkg-reconfigure -plow unattended-upgrades

# Installs Clam Antivirus
sudo apt-get install -y clamav
sudo freshclam
sudo clamscan -r --delete
