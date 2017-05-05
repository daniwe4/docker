#FROM php:5.6-apache

#RUN apt-get update && apt-get install -y \
#        libfreetype6-dev \
#        libjpeg62-turbo-dev \
#        libmcrypt-dev \
#        libpng12-dev \
#        libxml2-dev \
#        libxslt-dev \
#        libc6 \
#    && docker-php-ext-install -j$(nproc) iconv mcrypt pdo pdo_mysql xsl xml soap\
#    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
#    && docker-php-ext-install -j$(nproc) gd \
#	&& apt-get install imagemagick zip unzip mysql-client git wget findutils sudo -y -qq
FROM debian:jessie

RUN apt-get update && apt-get install apache2 php5 php5-mysql php5-gd php5-cli mysql-client git wget findutils sudo -y -qq
RUN apt-get install curl imagemagick zip unzip openjdk-7-jre -y -qq
RUN apt-get clean

RUN mkdir /root/.ssh
ADD id_rsa /root/.ssh/id_rsa
RUN ls -lah /root/.ssh
RUN chmod 400 ~/.ssh/id_rsa
RUN echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN rm /etc/apache2/sites-enabled/000-default.conf


RUN cd / && git clone git@github.com:daniwe4/ilias-tool-InstILIAS.git
RUN cd /ilias-tool-InstILIAS && git checkout release_5-2
#RUN git clone 'ext::ssh -i /root/.ssh/id_rsa github.com %S daniwe4/ilias-tool-InstILIAS.git'
RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
RUN ls -la /
RUN cd /ilias-tool-InstILIAS && composer install
RUN mkdir -p /var/www/html/dw
RUN mkdir -p /var/www/log/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+w /var/www

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

CMD /startup.sh
