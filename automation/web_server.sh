#!/bin/bash

echo "param1=$1" >> /tmp/params.txt
echo "param2=$2" >> /tmp/params.txt
echo "param3=$3" >> /tmp/params.txt
echo "param4=$4" >> /tmp/params.txt


LC_ALL=C.UTF-8 apt-add-repository ppa:ondrej/php
apt-get update -y
apt-get install -y php7.2 php7.2-mysql mysql-client-core-5.7 unzip php7.2-xml


mkdir -p /mnt/MyAzureFileShare
sudo mount -t cifs //$3.file.core.windows.net/myshare /mnt/MyAzureFileShare -o vers=3.0,username=$3,password=$4,dir_mode=0777,file_mode=0777,serverino


cd /var/www/html
wget https://wordpress.org/wordpress-4.9.8.tar.gz
tar -xf wordpress-4.9.8.tar.gz
mv wordpress/* .
rm -rf wp-content
ln -s  /mnt/MyAzureFileShare/wp-content wp-content
cp wp-config-sample.php wp-config.php
sed -i s/database_name_here/wp_db/ wp-config.php
sed -i s/username_here/wp_user@$1/ wp-config.php
sed -i s/password_here/$2/ wp-config.php
sed -i s/localhost/$1.mysql.database.azure.com/ wp-config.php
rm /var/www/html/index.html

openssl genrsa -out ca.key 2048
openssl req -subj '/CN=10.0.0.5/O=eugenitus/C=RU' -nodes -new -key ca.key -out ca.csr
openssl x509 -req -days 365 -in ca.csr -signkey ca.key -out ca.crt
mv ca.key /etc/ssl/private/apache-selfsigned.key
mv ca.crt /etc/ssl/certs/apache-selfsigned.crt

cat <<EOF >> /etc/apache2/sites-enabled/000-default.conf
<VirtualHost *:443>
                ServerAdmin webmaster@localhost
                DocumentRoot /var/www/html
                ErrorLog ${APACHE_LOG_DIR}/error.log
                CustomLog ${APACHE_LOG_DIR}/access.log combined
                SSLEngine on
                SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
                SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
                LoadModule ssl_module /usr/lib/apache2/modules/mod_ssl.so
</VirtualHost>
EOF

a2enmod ssl
service apache2 restart
