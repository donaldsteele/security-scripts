#!/bin/bash 
# le big shebang

less -FX liamdev.txt # Show figlet text

# Checks for root
if [[ $EUID -ne 0 ]]; then
   echo "ERROR!  Script is not being run as root!" 
   exit 1
   else echo "Success!  Script is being run as root."
fi

# Install Programs
apt-get install git
apt-get install gufw

# Git buck security
git clone https://github.com/davewood/buck-security

# Firewall
ufw enable
ufw deny 23
ufw deny 2049
ufw deny 515
ufw deny 111

# Updates
apt-get -y update
apt-get upgrade

# Turns off Guest ACCT
echo "allow-guest=false" >> /etc/lightdm/lightdm.conf

# Password Age Limits
sed -i '/^PASS_MAX_DAYS/ c\PASS_MAX_DAYS   90' /etc/login.defs
sed -i '/^PASS_MIN_DAYS/ c\PASS_MIN_DAYS   10'  /etc/login.defs
sed -i '/^PASS_WARN_AGE/ c\PASS_WARN_AGE   7' /etc/login.defs

# Password Auth
sed -i '1 s/^/auth optional pam_tally.so deny=5 unlock_time=900 onerr=fail audit even_deny_root_account silent\n/' /etc/pam.d/common-auth

# Makes strong password
apt-get -y install libpam-cracklib
sed -i '1 s/^/password requisite pam_cracklib.so retry=3 minlen=8 difok=3 reject_username minclass=3 maxrepeat=2 dcredit=1 ucredit=1 lcredit=1 ocredit=1\n/' /etc/pam.d/common-password

# Cracking tools/malware.  You get the drift.
apt-get -y purge hydra*
apt-get -y purge john*
apt-get -y purge nikto*
apt-get -y purge netcat*
apt-get -y purge aircrack-ng*
apt-get -y purge hashcat*
apt-get -y purge nmap*
apt-get -y purge ncrack*
apt-get -y purge ophcrack*

# Enables auto updates
dpkg-reconfigure -plow unattended-upgrades

# Disable Root Login (SSHd.CONF)
    if [[ -f /etc/ssh/sshd_config ]]; then
        sed -i 's/PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config
    else
        echo "No SSH server detected so nothing changed"
    fi
    echo "Disabled SSH root login (if any)"
    
# Remove Samba (If Installed)
echo "Would you like to remove SAMBA?"
# while true; do
        read -r -p "$* [y/n]: " yn
        case $yn in
            [Yy]* ) apt remove --purge samba;;
            [Nn]* ) echo "Aborted";;
            * ) echo "Invalid input! Please answer y (yes) or n (no)."
        esac

# Change Root Login
echo "Would you like to change the root login?"
# while true; do
        read -r -p "$* [y/n]: " yn
        case $yn in
            [Yy]* ) passwd;;
            [Nn]* ) echo "Aborted";;
            * ) echo "Invalid input! Please answer y (yes) or n (no)."
        esac
	
#Passwords for everyone! (the HUMANS)
echo Changing password for user root
passwd
for i in `awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd`; do 
echo Changing password for user $i
passwd $i
done
	
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

# Run The Trusty Ol' Buck Security
cd buck-security
./buck
