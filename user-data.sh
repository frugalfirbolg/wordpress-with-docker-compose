#!/bin/sh
#
# WordPress Setup Script
#
# This script will install and configure WordPress on
# an Ubuntu 14.04 droplet
export DEBIAN_FRONTEND=noninteractive;

generate_password () {
  echo `dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev |  tr -dc 'a-zA-Z0-9,._+:@%/-' | head -c 64`;
}

# Get around PAM audit during MySQL install
ln -s -f /bin/true /usr/bin/chfn && \
fallocate -l 1G /swapfile && \
chmod 600 /swapfile && \
mkswap /swapfile && \
swapon /swapfile && \
echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab && \
echo "Setup 1GB swapfile" && \
rootmysqlpass=$(generate_password) && \
wpmysqlpass=$(generate_password) && \
echo "mysql-server-5.6 mysql-server/root_password $rootmysqlpass" | debconf-set-selections && \
echo "mysql-server-5.6 mysql-server/root_password_again password $rootmysqlpass" | debconf-set-selections && \
echo "Root MySQL Password: $rootmysqlpass" > /root/passwords.txt && \
echo "Wordpress MySQL Password: $wpmysqlpass" >> /root/passwords.txt && \
echo "Setup random passwords and placed them in /root/passwords.txt" && \
apt-get update && \
apt-get -y dist-upgrade && \
echo "full-upgrade complete" && \
apt-get -y install mysql-server-5.6 && \
apt-get -y install mysql-client-5.6 apache2 php5 php5-mysql unzip && \
unlink /usr/bin/chfn && \
echo "Done with installing Ubuntu packages" && \
wget https://wordpress.org/latest.zip -O /tmp/wordpress.zip && \
cd /tmp/ && \
unzip /tmp/wordpress.zip && \
/usr/bin/mysqladmin -u root -h localhost password $rootmysqlpass && \
/usr/bin/mysqladmin -u root -p$rootmysqlpass -h localhost create wordpress && \
/usr/bin/mysql -u root -p$rootmysqlpass -e "CREATE USER wordpress@localhost IDENTIFIED BY '"$wpmysqlpass"'" && \
/usr/bin/mysql -u root -p$rootmysqlpass -e "GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@localhost" && \
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php && \
sed -i "s~'DB_NAME', 'database_name_here'~'DB_NAME', 'wordpress'~g" /tmp/wordpress/wp-config.php && \
sed -i "s~'DB_USER', 'username_here'~'DB_USER', 'wordpress'~g" /tmp/wordpress/wp-config.php && \
sed -i "s~'DB_PASSWORD', 'password_here'~'DB_PASSWORD', '$wpmysqlpass'~g" /tmp/wordpress/wp-config.php && \
for i in `seq 1 8`
  do
    wp_salt=$(</dev/urandom 2>/dev/null tr -dc 'a-zA-Z0-9!@#$%^&*()\-_ []{}<>~`+=,.;:/?|' | head -c 64 | sed -e 's/[\/&]/\\&/g') && \
    sed -i "0,/put your unique phrase here/s/put your unique phrase here/$wp_salt/" /tmp/wordpress/wp-config.php;
done && \
cp -Rf /tmp/wordpress/* /var/www/html/.  && \
rm -f /var/www/html/index.html && \
chown -Rf www-data:www-data /var/www/html  && \
echo "Done setting up initial Wordpress files and DB" && \
a2enmod rewrite && \
service apache2 restart;
