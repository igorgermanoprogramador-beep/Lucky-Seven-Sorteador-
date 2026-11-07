FROM php:8.3-apache

# Instala dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install \
    pdo_mysql \
    mbstring \
    zip \
    xml \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Instala o Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Configura a pasta pública do Laravel no Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

RUN sed -ri 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/000-default.conf \
    /etc/apache2/apache2.conf

# Define a pasta do projeto
WORKDIR /var/www/html

# Copia o projeto
COPY . .

# Instala dependências do Laravel
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --prefer-dist

# Ajusta permissões
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Porta do servidor
EXPOSE 80

CMD ["apache2-foreground"]