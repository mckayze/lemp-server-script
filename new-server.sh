#!/bin/bash

cat << EOF
Welcome!

We're going to try installing all the software needed to run Wordpress on this server, please follow instructions.
EOF

cat << EOF
  First we're going to update the server.
EOF
sudo apt update

cat << EOF
  Next we'll install Nginx
EOF
sudo apt install nginx

cat << EOF
  Now we're going to allow it access to certain ports.
EOF
sudo ufw allow 'Nginx HTTP'

cat << EOF
  Now were going to install MySQL
EOF
sudo apt install mysql-server

cat << EOF
  Now for some security updates to MySQL
EOF
sudo mysql_secure_installation