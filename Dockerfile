#docker build -t atyenoria/laravel-app-base .
#docker build -t atyenoria/laravel-app-base . && docker run -it atyenoria/laravel-app-base zsh
#docker build -t atyenoria/laravel-app-base . && docker push atyenoria/laravel-app-base
#php7-fpm: https://github.com/docker-library/php/blob/cd075c9d4e53b255b4af6691a7ee10354d7fbb8d/7.0/fpm/Dockerfile
FROM php:7-fpm
MAINTAINER atyenoria

COPY ./php.ini ~/

##################################################nginx##############################################################
# nginx officical: https://github.com/nginxinc/docker-nginx/blob/a8b6da8425c4a41a5dedb1fb52e429232a55ad41/Dockerfile
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list

ENV NGINX_VERSION 1.9.9-1~jessie

RUN apt-get update && \
    apt-get install -y ca-certificates nginx=${NGINX_VERSION} && \
    rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# VOLUME ["/var/cache/nginx"]
# EXPOSE 80 443
# CMD ["nginx", "-g", "daemon off;"]
##################################################nginx##############################################################




# Surpress Upstart errors/warning
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive


# Install software requirements
RUN apt-get update && \
    BUILD_PACKAGES="git wget curl lsof sudo" && \
    apt-get -y install $BUILD_PACKAGES && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*






##################################################base##############################################################
# ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y build-essential software-properties-common



#local Install Zsh
RUN apt-get install -y zsh
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
      && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
      && chsh -s /bin/zsh

ADD  ./.zshrc /root/.zshrc


#local vim plugin
RUN apt-get install -y vim
RUN mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
RUN git clone https://github.com/atyenoria/vim-pathogen.git ~/.vim.tmp && \
    ln -sf ~/.vim.tmp/autoload/pathogen.vim ~/.vim/autoload/pathogen.vim && \
    git clone https://github.com/atyenoria/nerdcommenter.git ~/.vim/bundle/nerdcommenter && \
    git clone https://github.com/atyenoria/delimitMate.git ~/.vim/bundle/delimitMate && \
    git clone https://github.com/atyenoria/PDV--phpDocumentor-for-Vim.git ~/.vim/bundle/phpDocumentor && \
    git clone https://github.com/atyenoria/vim-colorschemes.git ~/.vim/bundle/colorschemes && \
    git clone https://github.com/atyenoria/vim-misc.git ~/.vim/bundle/vim-misc && \
    git clone https://github.com/atyenoria/vim-colorscheme-switcher.git ~/.vim/bundle/colorscheme-switcher

ADD .vimrc /root/.vimrc






# composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN composer self-update



RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libcurl4-openssl-dev \
        libxml2-dev \
        libc-client-dev \
        libkrb5-dev \
        libicu-dev \
        openssl \
    && docker-php-ext-install -j$(nproc) iconv mcrypt mbstring mysqli pdo pdo_mysql sockets intl dom curl zip ftp bcmath gettext soap \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install mysqli pdo pdo_mysql





#clean up
RUN apt-get remove --purge -y software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*


#php settings
COPY ./php.ini /usr/local/etc/php/conf.d
COPY ./php-fpm.conf /usr/local/etc/php-fpm.conf


RUN useradd laravel -d /laravel

RUN mkdir -p /etc/nginx/adminer/ /etc/nginx/ssl /laravel/.ssh /etc/nginx/sites-available /etc/nginx/sites-enabled


