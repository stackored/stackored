###################################################################
# STACKORED PHP EXTENSION INSTALLER TEMPLATE
###################################################################

#!/bin/bash

extensions="{{ PHP_EXTENSIONS }}"

for ext in ${extensions//,/ }; do
case "$ext" in
redis)
pecl install redis && docker-php-ext-enable redis
;;
xdebug)
pecl install xdebug && docker-php-ext-enable xdebug
;;
intl)
apt-get update && apt-get install -y libicu-dev && docker-php-ext-install intl
;;
gd)
docker-php-ext-install gd
;;
pcntl)
docker-php-ext-install pcntl
;;
*)
echo "Unknown extension: $ext"
;;
esac
done
