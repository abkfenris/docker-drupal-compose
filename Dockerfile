# Adapted from https://circleci.com/blog/continuous-drupal-p1-maintaining-with-docker-git-composer/

# Start with docker library Drupal to make sure PHP is configured correctly
FROM drupal:8.5.6-apache

RUN apt-get update && apt-get install -y \
    git

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php composer-setup.php && \
	mv composer.phar /usr/local/bin/composer && \
	php -r "unlink('composer-setup.php');"

# Remove Drupal directory
RUN rm -rf /var/www/html/*

# Replace Apache site config
COPY apache-drupal.conf /etc/apache2/sites-enabled/000-default.conf

WORKDIR /app

# Run in container with /app mounted as a volume to setup
# composer create-project drupal-composer/drupal-project:8.x-dev . --stability dev --no-interaction --no-install

# Copy our composer create-project into /app
COPY ./app /app

# Install Drupal and dependencies with composer
RUN composer install

# change ownership of app/web directory so Apache can access it
RUN chown -R www-data:www-data /app/web