#!/bin/bash

echo "param1=$1" >> /tmp/params.txt
echo "param2=$2" >> /tmp/params.txt
echo "param3=$3" >> /tmp/params.txt
echo "param4=$4" >> /tmp/params.txt
echo "param5=$5" >> /tmp/params.txt

sudo apt-get install -y mysql-client-core-5.7
mysql --host $1.mysql.database.azure.com --user myadmin2018@$1 -p$2 -e "GRANT ALL PRIVILEGES ON wp_db.* TO 'wp_user'@'%' IDENTIFIED BY '$3'; FLUSH PRIVILEGES;"

mkdir -p /mnt/MyAzureFileShare
sudo mount -t cifs //$4.file.core.windows.net/myshare /mnt/MyAzureFileShare -o vers=3.0,username=$4,password=$5,dir_mode=0777,file_mode=0777,serverino

cd /mnt/MyAzureFileShare
wget https://wordpress.org/wordpress-4.9.8.tar.gz
tar -xf wordpress-4.9.8.tar.gz wordpress/wp-content/
mv wordpress/* .
chmod -R 777 wp-content