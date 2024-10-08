#!/bin/bash

#------------------ wordpress config -----------------#
wp --allow-root config create \
	--path=/var/www/html \
	--dbname="$WP_DATABASE" \
	--dbuser="$WP_USER" \
	--dbpass="$WP_PASSWORD" \
	--dbhost=mariadb \
	--dbprefix="wp_"

#------------------ wordpress install -----------------#
wp core install --allow-root \
	--path=/var/www/html \
	--title="42 - Inception" \
	--url=arsobrei.42.fr \
	--admin_user=$WP_USER \
	--admin_password=$WP_PASSWORD \
	--admin_email=$WP_EMAIL

#---- ----------- wordpress user config ----------------#
wp user create --allow-root \
	--path=/var/www/html/ \
	"$WP_AUTHOR_USER" "$WP_AUTHOR_EMAIL" \
	--user_pass=$WP_AUTHOR_PASSWORD \
	--role='author'

#---------------- install redis-cache -----------------#
wp plugin install --allow-root redis-cache --path=/var/www/html/

#--------------- activate redis-cache -----------------#
wp config set WP_CACHE true --add --type=constant --allow-root --path=/var/www/html/

#-------------- set redis-cache config ----------------#
wp config set WP_REDIS_PORT 6379 --add --type=constant --allow-root --path=/var/www/html/
wp config set WP_REDIS_HOST redis --add --type=constant --allow-root --path=/var/www/html/
wp plugin activate --allow-root redis-cache --path=/var/www/html/
wp redis enable --allow-root --path=/var/www/html/

#------------------ wordpress check ------------------#
while ! wp db check --allow-root --path=/var/www/html/; do
	echo "Waiting for database to be ready..."
	sleep 1
done

#------------------ wordpress start ------------------#
exec php-fpm7.4 -F
