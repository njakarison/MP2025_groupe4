#!/usr/bin/bash

REAL_USER=$(logname)
#check if the script is running as root
if [ "$(id -u)" -ne 0 ]; then
        echo "This script needs root privilegies to be executed."
        exit 1
fi

echo "updating packages and installing apache..."
#sudo apt update
#sudo apt install apache2

#set the website name
read -p "Saisir le nom de votre site web: " SITENAME
DOCROOT="/var/www/$SITENAME"
CONF="/etc/apache2/sites-available/$SITENAME.conf"

#creating web directory
echo "Creating website directory..."
sudo mkdir -p "$DOCROOT"

#creating html content
echo "<html><body><h1>Welcome to $SITENAME</h1></body></html>" | sudo tee "$DOCROOT/index.html"

#set permissions
sudo chmod -R 777 "$DOCROOT"

#creating virtual host 
echo "Creating virtual host config..."
sudo tee "$CONF" > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $SITENAME
    DocumentRoot $DOCROOT

    <Directory $DOCROOT>
        Options FollowSymLinks
        AllowOverride None
        Require all granted
        DirectoryIndex index.html
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$SITENAME-error.log
    CustomLog \${APACHE_LOG_DIR}/$SITENAME-access.log combined
</VirtualHost>
EOF


#enable the site
echo "Enabling the site..."
sudo a2ensite "$SITENAME.conf"
sudo systemctl reload apache2

echo "Done"









