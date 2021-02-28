service nginx start
service mysql start
service $(ls /etc/init.d | grep php | grep fpm) start
mysql < /var/www/mysite/wp_database.sql
sed -i {'s/autoindex off/autoindex on/'} /etc/nginx/sites-available/mysite.conf
service nginx restart
