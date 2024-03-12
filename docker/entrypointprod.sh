#!/bin/sh
if [ ! -f "vendor/autoload.php" ]; then
    composer install --optimize-autoload --no-progress --no-interaction
fi

if [ ! -f ".env" ]; then
    cp .env.example .env
fi

php artisan optimize
php artisan key:generate
php artisan storage:link

echo "Starting php-fpm"
exec "$@"
