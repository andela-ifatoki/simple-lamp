#/bin/bash

password=$1

# Download and install project dependencies
install_dependencies() {
  sudo apt-get update
  sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${password}"
  sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${password}"
  sudo apt-get install git mysql-server -y
  sudo apt-get install apache2 php libapache2-mod-php php-mcrypt php-mysql php-curl php-xml php-memcached -y
  sudo service apache2 restart
}

download_project() {
  echo -e "$password\n$password\n" | sudo passwd ubuntu
  cd /var
  sudo chown -R ubuntu:ubuntu www
  cd /var/www/html
  git clone https://github.com/qyjohn/simple-lamp
}

configure_db() {
  mysql -u root -p${password} -e "CREATE DATABASE simple_lamp;CREATE USER ubuntu@localhost IDENTIFIED BY '${password}';GRANT ALL PRIVILEGES ON simple_lamp.* TO ubuntu@localhost;"
}

populate_demo_data() {
  cd /var/www/html/simple-lamp
  mysql -u ubuntu -p${password} simple_lamp < simple_lamp.sql
}

configure_apache_permissions() {
  # set database username and password in config.php
  sed -i "s/\"username\"/\"ubuntu\"/g" config.php
  sed -i "s/\"password\"/\"$password\"/g" config.php
  cd /var/www/html/simple-lamp
  sudo chown -R www-data:www-data uploads
}

main() {
  export DEBIAN_FRONTEND="noninteractive"
  install_dependencies
  download_project
  configure_db
  populate_demo_data
  configure_apache_permissions
}

main