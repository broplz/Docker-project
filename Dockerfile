# Установка ОC, Установка ПО
FROM debian:buster
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get -y install wget vim nginx mariadb-server php php-mysql php7.3-fpm php-mbstring

# Копируем конфиг nginx
COPY ./srcs/nginx.conf /etc/nginx/sites-available/mysite.conf
RUN ln -s /etc/nginx/sites-available/mysite.conf /etc/nginx/sites-enabled/mysite.conf

# Создадим папку с нашим сайтом
RUN mkdir /var/www/mysite
WORKDIR /var/www/mysite

# устанавливаем phpmyadmin, разархивируем, переименовываем, удаляем tar.gz, копируем конфиг phpmyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-english.tar.gz
RUN tar -xf phpMyAdmin-5.0.4-english.tar.gz && rm phpMyAdmin-5.0.4-english.tar.gz
RUN mv phpMyAdmin-5.0.4-english phpmyadmin
COPY ./srcs/phpmyadmin.inc.php /var/www/mysite/phpmyadmin/config.inc.php

# устанавливаем wordpress, разархивируем и удаляем архиv, копируем конфиг вордпресса
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xvf latest.tar.gz && rm -rf latest.tar.gz
RUN mv wordpress/* /var/www/mysite/ && rm -rf wordpress
COPY ./srcs/wp-config.php /var/www/mysite/

# копирую базу данных
COPY ./srcs/wp_database.sql /var/www/mysite/wp_database.sql
# удаляем дефолтный сайт нджинкса
RUN rm -rf /etc/nginx/sites-enabled/default

# создание и настройки ssl
RUN mkdir /etc/nginx/ssl
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out /etc/nginx/ssl/private.pem -keyout /etc/nginx/ssl/public.key -subj "/C=RU/L=KAZAN/OU=21school/"
RUN openssl rsa -noout -text -in /etc/nginx/ssl/public.key

# меняем владельца
RUN chown -R www-data:www-data /var/www/*

# Выношу за контейнеры номера портов чтобы были видимы за пределами контейнер    а
EXPOSE 80 443

# копирую скрипт инициализирующий сервисы
COPY ./srcs/init.sh /tmp/init.sh

# Запуск команд
ENTRYPOINT sh /tmp/init.sh && /bin/bash
