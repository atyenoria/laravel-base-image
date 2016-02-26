#docker build -t atyenoria/laravel-base .
#docker build -t atyenoria/laravel-base . && docker run -it atyenoria/laravel-base zsh
FROM php:7-fpm

# php extension
ENV PHP_DEP_PACKAGE "libfreetype6-dev libjpeg62-turbo-dev libjpeg62-turbo-dev libmcrypt-dev libpng12-dev libcurl4-openssl-dev libxml2-dev libc-client-dev libkrb5-dev libicu-dev openssl"
RUN apt-get update && apt-get install -y $PHP_DEP_PACKAGE \
    && docker-php-ext-install -j$(nproc) iconv mcrypt mbstring mysqli pdo pdo_mysql sockets intl dom curl zip ftp bcmath gettext soap \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install mysqli pdo pdo_mysql

RUN pecl install xdebug-beta && \
    docker-php-ext-enable xdebug


# composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN composer self-update


#nginx
ENV NGINX_VERSION 1.9.11-1~jessie
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
    && echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y ca-certificates nginx=${NGINX_VERSION} gettext-base \
    && rm -rf /var/lib/apt/lists/*
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log





#laravel setting
RUN useradd laravel -d /laravel
RUN mkdir -p /laravel/.ssh

#zsh
ENV ZSH_DEP_PACKAGE  "software-properties-common build-essential"
RUN apt-get update && apt-get install -y $ZSH_DEP_PACKAGE
RUN apt-get install -y zsh git
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh \
    && cp -R /root/.oh-my-zsh /laravel \
    && chsh -s /bin/zsh \
    && chsh -s /bin/zsh laravel

#vim plugin
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


# Surpress Upstart errors/warning
# RUN dpkg-divert --local --rename --add /sbin/initctl
# RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
# ENV DEBIAN_FRONTEND noninteractive


# Install software requirements

ENV EXT_PACKAGES "wget curl lsof sudo supervisor dnsutils jq openssh-server"
RUN apt-get update && \
    apt-get -y install $EXT_PACKAGES && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*


#clean up
RUN apt-get remove --purge -y software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

RUN ln -sf /usr/share/zoneinfo/Japan /etc/localtime


ENV TERM xterm