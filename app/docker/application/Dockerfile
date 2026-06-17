FROM php:8.2-apache

WORKDIR /var/www/html

# Added dependencies for Memcached and AMQP (RabbitMQ)
RUN apt-get update && apt-get install -y \
    libmemcached-dev zlib1g-dev librabbitmq-dev \
    && pecl install memcached amqp \
    && docker-php-ext-enable memcached amqp \
    && docker-php-ext-install mysqli pdo pdo_mysql

COPY app/ecommerce-app/* .

RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

EXPOSE 80

CMD ["apache2-foreground"]