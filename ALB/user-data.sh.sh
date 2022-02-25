

#!/bin/bash

 # setpassword & DB variables

DBName = 'tcw'
DBUser = 'tcw'
DBPassword = 'TheCloudWorld.2019'
DBRootPassword = 'TheCloudWorld.2019'
DBEndpoint = 'RDS_ENDPOINT'

# system update
yum -y update
yum -y upgrade

# Step-2 -- Install system software -including web and DB

yum install -y mariadb-server httpd
amazan-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2

# Setp 3 --- web and DB servers online --and set to startup

systemctl enable httpd
systemctl enable mariadb
systemctl start httpd
systemctl start mariadb

# Step 4 --set mairadb Root password

mysqladmin -u root password  $DBRootPassword

# Step 5 -- Install wordpress

wget http://wordpress.org/latest.tar.gz -p /var/www/html
cd /var/www/html
tar -zxvf latest.tar.gz
cp -rvf wordpress/*.
rm -R wordpress
rm latest.tar.gz

# Step 6---configure wordpress

cp ./wp-config-sample.php ./wp-config.php
sed -i "s/'database_name_here'/'$DBName'/g" wp-config.php
sed -i "s/'username_here'/'$DBUser'/g" wp-config.php
sed -i "s/'password_here'/'$DBPassword'/g" wp-config.php
sed -i "s/'localhost'/'$DBEndpoint'/g"wp-config.php

# Step 6a ---permission

usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# Step 7 --- Create wordpress DB

echo "CREAT DATABASE $DBName;" >> /tmp/db.setup
echo "CREAT USER '$DBUser'@'localhost' IDENTFIED BY '$DBPassword';" >> /tmp/db.setup
echo "GRRANT ALL ON $DBName.* TO '$DBUser'@'localhost';" >> /tmp/db.setup
echo "FLUSH PRIVILEGES;" >> /tmp/db.setup
mysql -u root --password=$DBRootPassword < /tmp/db.setup
sudo rm /tmp/db.setup



