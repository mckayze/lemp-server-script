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
sudo apt install nginx << EOF
  echo y
EOF

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

passwordRoot=$(random-string)

cat << EOF

  -----------------------------------------------------//
  Now for some security updates to MySQL...

  Root Password Will Be: $passwordRoot
  -----------------------------------------------------//

EOF
sleep 2s
#sudo mysql_secure_installation

# Make sure that NOBODY can access the server without a password
mysql -e "UPDATE mysql.user SET authentication_string = PASSWORD('$passwordRoot') WHERE User = 'root'"
# Kill the anonymous users
mysql -e "DELETE FROM mysql.user WHERE User=''"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
# Because our hostname varies we'll use some Bash magic here.
mysql -e "DROP USER ''@'127.0.0.1'"
# Kill off the demo database
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"
# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param

cat << EOF

  -----------------------------------------------------//
  Now Lets create the three databases we're going to be using...
  -----------------------------------------------------//

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

  -----------------------------------------------------//
  Here are the DB passwords that were created
  -----------------------------------------------------//

  $passwordDevelopment - Development Password
  $passwordStaging - Staging Password
  $passwordProduction - Production Password

EOF