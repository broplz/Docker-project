# Установка ОC, Установка ПО
FROM debian:buster
RUN apt-get update && apt-get upgrade -y && apt-get -y install wget nginx mariadb-server php php-mysql php7.3-fpm php-mbstring

# Копируем конфиг nginx
RUN ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf && rm -rf /etc/nginx/sites-enabled/default
COPY ./srcs/nginx.conf /etc/nginx/sites-available/nginx.conf

# устанавливаем wordpress, разархивируем и удаляем архиv, копируем конфиг вордпресса
RUN wget https://wordpress.org/latest.tar.gz && tar -xvf latest.tar.gz && rm -rf latest.tar.gz && mv wordpress /var/www/mysite && rm -rf wordpress
COPY ./srcs/wp-config.php /var/www/mysite/

# рабочая директория в майсайт
WORKDIR /var/www/mysite

# устанавливаем phpmyadmin, разархивируем, переименовываем, удаляем tar.gz, копируем конфиг phpmyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-english.tar.gz && tar -xf phpMyAdmin-5.0.4-english.tar.gz && rm phpMyAdmin-5.0.4-english.tar.gz && mv phpMyAdmin-5.0.4-english phpmyadmin
COPY ./srcs/phpmyadmin.inc.php /var/www/mysite/phpmyadmin/config.inc.php

# копирую скрипт с базой данных
COPY ./srcs/wp_database.sql /tmp/wp_database.sql

# создание и настройки ssl
RUN mkdir /etc/nginx/ssl && openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out /etc/nginx/ssl/private.pem -keyout /etc/nginx/ssl/public.key -subj "/C=RU/L=KAZAN/OU=21school/" && openssl rsa -noout -text -in /etc/nginx/ssl/public.key

# меняем владельца
RUN chown -R www-data:www-data /var/www/*

# Выношу за контейнеры номера портов чтобы были видимы за пределами контейнер    а
EXPOSE 80 443

# копирую скрипты
COPY ./srcs/init.sh /tmp/init.sh
COPY ./srcs/autoindex_off.sh /tmp/autoindex_off.sh
COPY ./srcs/autoindex_on.sh /tmp/autoindex_on.sh

# Запуск команд
ENTRYPOINT sh /tmp/init.sh && cat /var/log/nginx/error.log && /bin/bash
