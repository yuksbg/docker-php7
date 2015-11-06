FROM phusion/baseimage:0.9.17
MAINTAINER Yuksel Saliev <yuksel.saliev@gmail.com>

# Install base packages
RUN apt-get update && \
        apt-get install -y \
        git \
        wget \
        nano \
    build-essential \
    pkg-config \
    git-core \
    autoconf \
    bison \
    libxml2-dev \
    libbz2-dev \
    libmcrypt-dev \
    libicu-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libltdl-dev \
    libjpeg-dev \
    libpng-dev \
    libpspell-dev \
    libreadline-dev

RUN sudo mkdir /usr/local/php7

RUN git clone https://github.com/php/php-src.git
RUN cd php-src &&  git checkout PHP-7.0.0 &&  git pull &&  ./buildconf --force

RUN cd php-src && ./configure "--prefix=/usr/local/php7 \
                  --with-config-file-scan-dir=/usr/local/php7/etc/conf.d \
                  --enable-bcmath \
                  --with-bz2 \
                  --enable-calendar \
                  --enable-intl \
                  --enable-exif \
                  --enable-dba \
                  --enable-ftp \
                  --with-gettext \
                  --with-gd \
                  --with-jpeg-dir \
                  --enable-mbstring \
                  --with-mcrypt \
                  --with-mhash \
                  --enable-mysqlnd \
                  --with-mysql=mysqlnd \
                  --with-mysql-sock=/var/run/mysqld/mysqld.sock \
                  --with-mysqli=mysqlnd \
                  --with-pdo-mysql=mysqlnd \
                  --with-openssl \
                  --enable-pcntl \
                  --with-pspell \
                  --enable-shmop \
                  --enable-soap \
                  --enable-sockets \
                  --enable-sysvmsg \
                  --enable-sysvsem \
                  --enable-sysvshm \
                  --enable-wddx \
                  --with-zlib \
                  --enable-zip \
                  --with-readline \
                  --with-curl \
                  --enable-fpm \
                  --with-fpm-user=www-data \
                  --with-fpm-group=www-data"

RUN cd php-src && make
RUN cd php-src && make install

RUN mkdir /usr/local/php7/etc/conf.d
RUN ln -s /usr/local/php7/sbin/php-fpm /usr/local/php7/sbin/php7-fpm
RUN ln -s /usr/local/php7/bin/php /usr/bin/php
RUN cp php-src/php.ini-production /usr/local/php7/lib/php.ini


COPY include-conf/www.conf /usr/local/php7/etc/php-fpm.d/www.conf
COPY include-conf/php-fpm.conf /usr/local/php7/etc/php-fpm.conf
COPY include-conf/modules.ini /usr/local/php7/etc/conf.d/modules.ini
COPY include-conf/php7-fpm.init /etc/init.d/php7-fpm

RUN chmod +x /etc/init.d/php7-fpm
RUN update-rc.d php7-fpm defaults
RUN service php7-fpm start
