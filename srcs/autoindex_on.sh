cat /etc/nginx/sites-available/nginx.conf | grep autoindex
sed -i {'s/autoindex off/autoindex on/'} /etc/nginx/sites-available/nginx.conf
cat /etc/nginx/sites-available/nginx.conf | grep autoindex
service nginx reload
