#!/bin/bash 
# le big shebang

less -FX liamdev.txt # Show figlet text

if [[ $EUID -ne 0 ]]; then
   echo "ERROR!  Script is not being run as root!" 
   exit 1
   else echo "Success!  Script is being run as root."
fi # Checks for root

# Firewall
sudo apt-get install gufw
sudo ufw enable
sudo ufw deny 23
sudo ufw deny 2049
sudo ufw deny 515
sudo ufw deny 111

# Updates
sudo apt-get -y update
sudo apt-get upgrade

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

# List user accounts by size
echo "Home directory space by user"
	format="%8s%10s%10s   %-s\n"
	printf "$format" "Dirs" "Files" "Blocks" "Directory"
	printf "$format" "----" "-----" "------" "---------"
	if [ $(id -u) = "0" ]; then
		dir_list="/home/*"
	else
		dir_list=$HOME
	fi
	for home_dir in $dir_list; do
		total_dirs=$(find $home_dir -type d | wc -l)
		total_files=$(find $home_dir -type f | wc -l)
		total_blocks=$(du -s $home_dir)
		printf "$format" $total_dirs $total_files $total_blocks
	done

# Disable Root Login (SSHd.CONF)
    if [[ -f /etc/ssh/sshd_config ]]; then
        sed -i 's/PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config
    else
        echo "No SSH server detected so nothing changed"
    fi
    echo "Disabled SSH root login (if any)"
    
# Ask to remove SAMBA
    echo "Would you like to remove SAMBA?"
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) apt remove --purge samba
            [Nn]*) echo "Aborted"
        esac
    done
