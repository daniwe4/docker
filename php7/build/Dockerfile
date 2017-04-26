FROM php:7.1.3-apache

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libxml2-dev \
        libxslt-dev \
        libc6 \
    && docker-php-ext-install -j$(nproc) iconv mcrypt pdo pdo_mysql xsl xml soap\
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
	&& apt-get install imagemagick zip unzip mysql-client git wget findutils sudo -y -qq


RUN rm /etc/apache2/sites-enabled/000-default.conf
RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
RUN mkdir -p /var/www/html/dw
RUN mkdir -p /var/www/log/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+w /var/www

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

CMD /startup.sh