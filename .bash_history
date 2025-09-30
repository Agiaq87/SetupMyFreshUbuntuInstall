./new.sh --tui
apt update
apt upgrade
apt install sudo
./new.sh --tui
exit
apt install adduser
exit
cat /etc/passwd | cut -d: -f1
usermod -aG sudo ubuntu
exit
