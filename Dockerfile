FROM php:5.6-apache

MAINTAINER Thomas Nabord <thomas.nabord@prestashop.com>

ENV PS_DOMAIN prestashop.local
ENV DB_SERVER 127.0.0.1
ENV DB_PORT 3306
ENV DB_NAME prestashop
ENV DB_USER root
ENV DB_PASSWD admin
ENV ADMIN_MAIL demo@prestashop.com
ENV ADMIN_PASSWD prestashop_demo
ENV PS_LANGUAGE en
ENV PS_COUNTRY gb
ENV PS_INSTALL_AUTO 0
ENV PS_DEV_MODE 0
ENV PS_HOST_MODE 0
ENV PS_HANDLE_DYNAMIC_DOMAIN 0

ENV PS_FOLDER_ADMIN admin
ENV PS_FOLDER_INSTALL install


RUN apt-get update \
	&& apt-get install -y libmcrypt-dev \
		libjpeg62-turbo-dev \
		libpng12-dev \
		libfreetype6-dev \
		libxml2-dev \
		mysql-client \
		wget \
		unzip \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install iconv mcrypt opcache pdo mysql pdo_mysql mbstring soap gd zip

ENV PS_VERSION 1.6.1.7

# Get PrestaShop
ADD https://download.prestashop.com/download/releases/prestashop_1.6.1.7_fr.zip /tmp/prestashop.zip
COPY config_files/ps-extractor.sh /tmp/
RUN mkdir /tmp/data-ps && unzip -q /tmp/prestashop.zip -d /tmp/data-ps/ && bash /tmp/ps-extractor.sh /tmp/data-ps && rm /tmp/prestashop.zip /tmp/ps-extractor.sh
COPY config_files/docker_updt_ps_domains.php /var/www/html/

# Apache configuration
RUN a2enmod rewrite
RUN chown www-data:www-data -R /var/www/html/
RUN sed -i -e"s/^Listen\s* \s*80/Listen 8080/" /etc/apache2/ports.conf
EXPOSE 8080

# PHP configuration
COPY config_files/php.ini /usr/local/etc/php/

VOLUME /var/www/html/modules
VOLUME /var/www/html/themes
VOLUME /var/www/html/override

COPY config_files/docker_run.sh /tmp/
USER 33
CMD ["/tmp/docker_run.sh"]
