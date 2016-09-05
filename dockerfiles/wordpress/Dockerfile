FROM php:7-fpm

# Enable mysql
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Install blackfire probe
RUN curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/70 \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so `php -r "echo ini_get('extension_dir');"`/blackfire.so
RUN echo "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707" > $PHP_INI_DIR/conf.d/blackfire.ini

# Enable opcache
RUN echo "zend_extension=opcache.so\nopcache.enable = 1" > $PHP_INI_DIR/conf.d/opcache.ini

# Install wp-cli
RUN apt-get update && apt-get install -y less && rm -rf /var/lib/apt/lists/*
RUN curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/bin/wp-cli && chmod +x /usr/bin/wp-cli

COPY . /