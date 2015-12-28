#!/bin/bash
# -*- coding: utf-8 -*-

start_time=`date +%s`

if [ "$(id -u)" != "0" ]; then
	echo "You need admin (root) right to run the script."
	echo "Syntax: sudo $0"
	exit 1
fi

source "./setupmethisbitch.cfg"

echo                                                                    
echo -e "\033[0;41m \033[5m _____     _           _____    _____ _   _     _____ _ _       _   \033[0m \033[0m"
echo -e "\033[0;41m \033[5m|   __|___| |_ _ _ ___|     |__|_   _| |_|_|___| __  |_| |_ ___| |_ \033[0m \033[0m"
echo -e "\033[0;41m \033[5m|__   | -_|  _| | | . | | | | -_|| | |   | |_ -| __ -| |  _|  _|   |\033[0m \033[0m"
echo -e "\033[0;41m \033[5m|_____|___|_| |___|  _|_|_|_|___||_| |_|_|_|___|_____|_|_| |___|_|_|\033[0m \033[0m"
echo -e "\033[0;41m \033[5m                  |_|                                               \033[0m \033[0m"


echo
echo -e "\033[1;34m--------------------------------------------------------------------\033[0m"
echo -e "\033[1;34m--------------------------------------------------------------------\033[0m"
echo -e "\033[1;34m         欢迎, Welcome, Bienvenue, добро пожаловать, សូមស្វាគមន៍\033[0m"
echo -e "\033[1;34m--------------------------------------------------------------------\033[0m"
echo -e "\033[1;34m--------------------------------------------------------------------\033[0m"
echo
echo -en "\033[0;00m. "
sleep 1
echo -en "\033[0;00m. "
sleep 1
echo -en "\033[0;00m. "
sleep 1
echo -en "\033[0;00m. "
sleep 1
echo -en "\033[0;00m. "
sleep 1

# end_time=`date +%s`
# diff_time=`expr $end_time - $start_time`

# ((sec=diff_time%60, diff_time/=60, min=diff_time%60, hrs=diff_time/60))
# timestamp=$(printf "%dh %02dm %02ds" $hrs $min $sec)
# echo $timestamp
# exit 1

echo "   Let's go !"
echo

##### Setup auto-complete installation
#####
echo $password >> /etc/passwd.txt
echo $password >> /etc/passwd.txt

echo $mysqlrootpassword > /etc/z_mysql_config.txt
echo "n" >> /etc/z_mysql_config.txt
echo "Y" >> /etc/z_mysql_config.txt
echo "Y" >> /etc/z_mysql_config.txt
echo "Y" >> /etc/z_mysql_config.txt
echo "Y" >> /etc/z_mysql_config.txt
#####

##### Useful aliases
#####
echo "export EDITOR='emacs'" >> /root/.bashrc
echo "alias ls='ls --color'" >> /root/.bashrc
echo "alias ll='ls -l'" >> /root/.bashrc
echo "alias la='ls -la'" >> /root/.bashrc
echo "alias emacs='emacs -nw'" >> /root/.bashrc
echo "alias ne='emacs -nw'" >> /root/.bashrc
echo "alias clean='rm -f *~ && rm -f .*~'" >> /root/.bashrc
echo "alias memoryclean='sync; echo 3 | sudo tee /proc/sys/vm/drop_caches'" >> /root/.bashrc
echo "alias memoryswapclean='sudo swapoff -a && sudo swapon -a'" >> /root/.bashrc
echo "alias mc='memoryswapclean && memoryclean'" >> /root/.bashrc
#####

apt="apt-get -q -y --force-yes"
wget="wget --no-check-certificate -c"

printmethis () {
	echo
	echo -e "\033[1;32m----------------------------------------------------------------\033[0m"
	echo -e "\033[1;33m$1\033[0m"
	echo -e "\033[1;32m----------------------------------------------------------------\033[0m"
	echo
}


printmethis "Mise à jour des paquets ..."
$apt update
$apt upgrade
$apt dist-upgrade
$apt install

####################################################################################
####################################################################################
####################################################################################
####################################################################################
####################################################################################
####################################################################################

printmethis "Installation mysql ..."
debconf-set-selections <<< 'mysql-server mysql-server/root_password password $mysqlrootpassword'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $mysqlrootpassword'
$apt install mysql-server
# mysql_install_db
# /usr/bin/mysql_secure_installation < /etc/z_mysql_config.txt

####################################################################################
####################################################################################
####################################################################################
####################################################################################
####################################################################################
####################################################################################

printmethis "Installation de php et nginx ..."
$apt install nginx
service nginx start
$apt install php5-fpm php5-mysql
echo "Change config /etc/php5/fpm/php.ini"
sed -i -e "s/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
echo "Change config /etc/php5/fpm/pool.d/www.conf"
sed -i -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php5-fpm.sock/g" /etc/php5/fpm/pool.d/www.conf
echo "Restart php5-fpm"
service php5-fpm restart

printmethis "Installation des softwares utiles ..."
$apt install emacs nano byobu htop locate sudo nano zip unzip gcc libc6-dev linux-kernel-headers wget bzip2 make build-essential checkinstall git bind9 curl telnet


printmethis "Installation de python3 ..."
$apt install python3 python3-pip python3-setuptools


printmethis "Config user : $username ..."
addgroup $username
adduser --uid 5400 --ingroup $username $username --shell /bin/bash --home /home/$username --gecos "" < /etc/passwd.txt
adduser $username sudo
cp /root/.bashrc /home/$username/.bashrc


printmethis "Config ssh ..."
sed -i -e "s/Port 22/Port $sshport/g" /etc/ssh/sshd_config
if [ "$rootlogin" == 0 ]; then
	sed -i -e "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
	echo "AllowUsers $username"
	echo "AllowUsers $username" >> /etc/ssh/sshd_config
fi
/etc/init.d/ssh restart

# Delete passwords files
rm /etc/z_mysql_config.txt
rm /etc/passwd.txt

end_time=`date +%s`
diff_time=`expr $end_time - $start_time`

((sec=diff_time%60, diff_time/=60, min=diff_time%60, hrs=diff_time/60))
timestamp=$(printf "%dh %02dm %02ds" $hrs $min $sec)
echo -e "\033[1;32m================================================================\033[0m"
echo -e "\033[1;32m================================================================\033[0m"
echo -e "\033[1;32m     Done ! Execution time : $timestamp     "
echo -e "\033[1;32m================================================================\033[0m"
echo -e "\033[1;32m================================================================\033[0m"

exit 0