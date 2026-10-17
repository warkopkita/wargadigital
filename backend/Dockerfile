FROM php:8.3-cli-alpine

# Install required system dependencies & PHP extensions
RUN apk add --no-cache \
    sqlite-dev \
    sqlite \
    libpng-dev \
    libxml2-dev \
    oniguruma-dev \
    git \
    curl \
    unzip \
    && docker-php-ext-install pdo_sqlite mbstring bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy application files
COPY . .

# Set permissions
RUN chmod -R 777 storage bootstrap/cache database

# Install PHP dependencies without dev packages
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Create database file if not exists and run migrations
RUN touch database/database.sqlite && chmod 777 database/database.sqlite
RUN php artisan key:generate --force || true
RUN php artisan config:cache || true
RUN php artisan route:cache || true

# Dynamic PORT support for Render, Koyeb, Railway (defaults to 8000)
ENV PORT=8000
EXPOSE 8000

CMD ["sh", "-c", "php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=${PORT}"]
