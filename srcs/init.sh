service nginx start
service mysql start
service $(ls /etc/init.d | grep php | grep fpm) start
mysql < /tmp/wp_database.sql
