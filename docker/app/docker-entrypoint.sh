#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$APP_ENV" != 'prod' ]; then
	chmod +x bin/console
    # Always try to reinstall deps when not in prod
    composer install --prefer-dist --no-progress --no-suggest --no-interaction
    php bin/console doctrine:database:create  --no-interaction --if-not-exists
    php bin/console doctrine:migration:migrate  --allow-no-migration --no-interaction
fi

# Permissions hack because setfacl does not work on Mac and Windows
chown -R www-data var

exec docker-php-entrypoint "$@"
