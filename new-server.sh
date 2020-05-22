#!/bin/bash

random-string(){
    cat /dev/urandom | tr -dc 'a-zA-Z0-9~!@#$%^&()={}[]/<>,;?:|' | fold -w 32 | head -n 1
}

cat << EOF
Welcome!

We're going to try installing all the software needed to run Wordpress on this server, please follow instructions.
EOF

cat << EOF

  ############################################
  First we're going to update the server...
  ############################################

EOF
sleep 2s
sudo apt update
sudo apt -y dist-upgrade
sudo apt -y autoremove
sudo apt clean

cat << EOF

  ############################
  Next we'll install Nginx...
  ############################

EOF
sleep 2s
sudo apt install nginx << EOF
y
EOF

sudo echo 'server {
    listen 80;
    listen [::]:80;
    server_name staging_subdomain.bulbdigital.co.uk;
    root /var/www/staging/current/web;
    client_max_body_size 2M;
    location / {
        index index.htm index.html index.php;
        try_files $uri $uri/ /index.php?$query_string;
        auth_basic "Restricted Content";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
    # pass PHP scripts to FastCGI server
    #
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
    }
}' > /etc/nginx/sites-available/staging

sudo echo 'server {
    listen 80;
    listen [::]:80;
    server_name production_subdomain.bulbdigital.co.uk;
    root /var/www/production/current/web;
    client_max_body_size 2M;
    location / {
        index index.htm index.html index.php;
        try_files $uri $uri/ /index.php?$query_string;
        auth_basic "Restricted Content";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
    # pass PHP scripts to FastCGI server
    #
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
    }
}' > /etc/nginx/sites-available/production

cat << EOF

  #######################################################
  Now we're going to allow it access to certain ports...
  #######################################################
EOF
sleep 2s
sudo ufw allow 'Nginx HTTP'

cat << EOF

  #######################################################
  Now were going to install MySQL...
  #######################################################

EOF
sleep 2s
sudo apt install mysql-server << EOF
y
EOF

passwordRoot=$(random-string)

cat << EOF

  #######################################################
  Now for some security updates to MySQL...
  Root Password Will Be: $passwordRoot
  #######################################################

EOF
sleep 2s
#sudo mysql_secure_installation

# Make sure that NOBODY can access the server without a password
mysql -e "UPDATE mysql.user SET authentication_string = PASSWORD('$passwordRoot') WHERE User = 'root'"
# Kill the anonymous users
mysql -e "DELETE FROM mysql.user WHERE User=''"
# Delete random root user.. I guess?
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
# Kill off the demo database
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"
# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param

cat << EOF

  ###############################################################
  Now Lets create the three databases we're going to be using...
  ###############################################################

EOF
sleep 2s
passwordDevelopment=$(random-string)
passwordStaging=$(random-string)
passwordProduction=$(random-string)

mysql -e "CREATE DATABASE development /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -e "CREATE USER development@localhost IDENTIFIED BY '$passwordDevelopment';"
mysql -e "GRANT ALL PRIVILEGES ON development.* TO 'development'@'localhost';"

mysql -e "CREATE DATABASE staging /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -e "CREATE USER staging@localhost IDENTIFIED BY '$passwordStaging';"
mysql -e "GRANT ALL PRIVILEGES ON staging.* TO 'staging'@'localhost';"

mysql -e "CREATE DATABASE production /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -e "CREATE USER production@localhost IDENTIFIED BY '$passwordProduction';"
mysql -e "GRANT ALL PRIVILEGES ON production.* TO 'production'@'localhost';"

mysql -e "FLUSH PRIVILEGES;"

cat << EOF

  #######################################################
  Here are the DB passwords that were created
  #######################################################

  $passwordDevelopment - Development Password
  $passwordStaging - Staging Password
  $passwordProduction - Production Password

EOF

cat << EOF

  ###############################################################
  Lastly lets install php and set it up to use nginx...
  ###############################################################

EOF

sudo apt install php-fpm php-mysql

sudo ln -s /etc/nginx/sites-available/staging /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/production /etc/nginx/sites-enabled/
sudo unlink /etc/nginx/sites-enabled/default
sudo service nginx restart