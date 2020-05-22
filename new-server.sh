#!/bin/bash

random-string(){
    cat /dev/urandom | tr -dc 'a-zA-Z0-9~!@#$%^&()={}[]/<>,;?:|' | fold -w 32 | head -n 1
}

cat << EOF
Welcome!

We're going to try installing all the software needed to run Wordpress on this server, please follow instructions.
EOF

cat << EOF

  ------------------------------------------//
  First we're going to update the server...
  ------------------------------------------//

EOF
sleep 2s
sudo apt update

cat << EOF

  --------------------------//
  Next we'll install Nginx...
  --------------------------//

EOF
sleep 2s
sudo apt install nginx

cat << EOF

  -----------------------------------------------------//
  Now we're going to allow it access to certain ports...
  -----------------------------------------------------//
EOF
sleep 2s
sudo ufw allow 'Nginx HTTP'

cat << EOF

  -----------------------------------------------------//
  Now were going to install MySQL...
  -----------------------------------------------------//

EOF
sleep 2s
sudo apt install mysql-server

cat << EOF

  -----------------------------------------------------//
  Now for some security updates to MySQL...
  -----------------------------------------------------//

EOF
sleep 2s
sudo mysql_secure_installation

cat << EOF

  -----------------------------------------------------//
  Now Lets create the three databases we're going to be using...
  -----------------------------------------------------//

EOF
sleep 2s
passwordDevelopment=$(random-string)

mysql -e "CREATE DATABASE development /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -e "CREATE USER development@localhost IDENTIFIED BY '$passwordDevelopment';"
mysql -e "GRANT ALL PRIVILEGES ON development.* TO 'development'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo "$passwordDevelopment - Development Password"