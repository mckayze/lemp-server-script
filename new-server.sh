#!/bin/bash

sudo apt update

sudo apt install nginx

sudo ufw allow 'Nginx HTTP'

sudo apt install mysql-server

sudo mysql_secure_installation