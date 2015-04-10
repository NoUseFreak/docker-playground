FROM php:5.6-fpm

# Install modules
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        curl \
        mysql-client

RUN docker-php-ext-install gd pdo_mysql mcrypt

RUN apt-get install -y \
        libicu-dev \
        libcurl4-gnutls-dev
RUN docker-php-ext-install curl

CMD ["php-fpm"]
