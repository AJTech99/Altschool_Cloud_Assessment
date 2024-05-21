#!/bin/bash

# Define some constants and variables
APP_DIR="/var/www/html"
APP_NAME="aj-app"
APP_GITHUB_URL="https://github.com/laravel/laravel.git"
MYSQL_ROOT_PASSWORD="ajtech99"
MYSQL_DATABASE="my_database"
MYSQL_USER="my_user"
MYSQL_PASSWORD="ajtech99"
# Make sure you're running with root privileges
if [[ $EUID -ne 0 ]]; then
echo "Please run this script as root"
exit 1
fi
# Update and upgrade system packages
sudo apt-get update
sudo apt-get upgrade -y

# Install necessary packages
sudo apt-get install -y apache2 mysql-server php php-mysql git
sudo apt install apache2 mysql-server php libapache2-mod-php php-mysql -y

# Set appropriate ownership and permissions for web directory:
sudo chown -R www-data:www-data /var/www/html/

# Configure firewall rules to allow HTTP traffic:
sudo ufw allow in "Apache Full"

# Configure MySQL server
mysql -u root --password=$MYSQL_ROOT_PASSWORD <<- _EOF_
CREATE DATABASE $MYSQL_DATABASE;
CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'localhost';
FLUSH PRIVILEGES;
_EOF_
# Clone PHP application from GitHub
rm -rf $APP_DIR/$APP_NAME
git clone $APP_GITHUB_URL $APP_DIR/$APP_NAME
# Configure Apache web server
echo "<?php phpinfo(); ?>" > $APP_DIR/info.php
cp $APP_DIR/info.php $APP_DIR/$APP_NAME/index.php
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
service apache2 restart
sudo systemctl enable apache2 && sudo systemctl restart apache2 

# Display the script's completion message
echo "LAMP stack deployed successfully!"
echo "You can access your PHP application at http://YOUR_SERVER_IP/info.php"
