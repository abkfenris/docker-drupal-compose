# Drupal in Docker test

Testing out if Drupal can be made to play well with Docker for GMRI purposes.
This uses the Docker Library PostgreSQL image as is, and rebuilds the Docker Library Drupal image using Composer.


## Usage

If setting up for the first time, see [Initial Configuration](#initial-configuration) down below.

Otherwise use `make up` to start the server which you can then access at [localhost:8080](http://localhost:8080/).

If you `ctrl-c` out of the logs (or close the window), you can get the logs back with `make logs`. 

The docker containers are launched in the background with `make-up`, so they won't dissapear if you close the window or logs, so once you're done, `ctrl-c` out of the logs and run `make down` to shut down the server.

If you wish to take a backup of the database, you can use `make dump-sql` which will save the database roles and content to `./docker-data/dump.sql`.

### Installing and updating modules or themes

If you want to add a module or a theme, you should use Composer and `composer.yaml` to do so.

For example if you wanted to add the [Behat Drupal Extension](https://www.drupal.org/project/drupalextension), you would first search on [Packagist](https://packagist.org/) to find the full package name. In this case it's `drupal/drupal-extension`.

Then you can test if composer can add it with `docker-compose exec drupal composer require drupal/drupal-extension`, and that way you can see what version it will use.

```bash
$  docker-compose exec drupal composer require drupal/drupal-extension
Do not run Composer as root/super user! See https://getcomposer.org/root for details
Using version ^3.4 for drupal/drupal-extension
./composer.json has been updated
> DrupalProject\composer\ScriptHandler::checkComposerVersion
Loading composer repositories with package information
Updating dependencies (including require-dev)
Package operations: 6 installs, 0 updates, 0 removals
As there is no 'unzip' command installed zip files are being unpacked using the PHP zip extension.
This may cause invalid reports of corrupted archives. Installing 'unzip' may remediate them.
  - Installing drupal/drupal-driver (v1.4.0): Downloading (100%)
  - Installing behat/transliterator (v1.2.0): Downloading (100%)
  - Installing behat/gherkin (v4.5.1): Downloading (100%)
  - Installing behat/behat (v3.5.0): Downloading (100%)
  - Installing behat/mink-extension (2.3.1): Downloading (100%)
  - Installing drupal/drupal-extension (v3.4.1): Downloading (100%)
Writing lock file
Generating autoload files
> DrupalProject\composer\ScriptHandler::createRequiredFiles
$ 
```
Then you add the version number (from `Using version ^3.4`) to the `require` dictionary in `app/composer.json`. 

```json
{
    //...other stuff
    "require": {
        // ... existing requirements
        "drupal/drupal-extension": "^3.4"
    }

}
```
Then run `make down up` to bring down the development environment and rebuild it.

Once the environment is up and rebuilt, then you can go into the Django admin and enable the module or theme.

Updating modules or themes should also be done via `compose.json`

If you're wondering why there is the `^` caret in front of the version number, see [Version](https://getcomposer.org/doc/articles/versions.md) in the Composer docs. 
The caret in this case will allow any version greater than or equal to 3.4 but less than 4.0 (so there shouldn't be any breaking changes).

### Composer.lock

To make sure that you're getting the exact same packages as were initially installed in this image move `composer.lock` into the `app` directory then `make up`. 

If you wish to generate a new `composer.lock` file, you can build without it in the `app` directory, then use `docker cp` to copy it out of the container. 

For example, if I use `docker ps` to find the container ID is `fea4777feeb4`, 
I can use `docker cp fea:/app/composer.lock app/composer.lock` to copy the current 
version to the `app` directory to guarentee that future builds will use the same libary versions.

## Initial Configuration

### Database Settings
To start, you need to configure a username and password for the PostgreSQL database. 

To do so, start by creating a `secret.env` file in `./docker-data` that looks something like this.

```
POSTGRES_PASSWORD=secret_string
POSTGRES_USER=a_user_name
```

### Starting Docker

Then you can use `make up` to start up the database and Drupal server.
Docker will take a few min to download the containers for both PostgresSQL and Drupal.
It will also bootstrap the `sites` directory as `./docker-data/drupal/sites` from the Drupal image.

After the images are downloaded, and the sites bootstrapped, you'll see the logs start to stream, and you'll be able to access the site at [localhost:8080](http://localhost:8080/).

### Configuring Drupal

When configuring Drupal, you'll use the username and password for the PostgreSQL database that you set up in `secret.env`.

You'll also need to go into the advanced database settings and set the host to `postgres`.

After that, you can continue with the normal Drupal configuration.

## How I built this

I built this by adapting information from a few sources to make sure it is reproducable.

- [CircleCI - Continuous Drupal](https://circleci.com/blog/continuous-drupal-p1-maintaining-with-docker-git-composer/)
- [Drupal - Using Composer to Manage Drupal Site Dependencies](https://www.drupal.org/docs/develop/using-composer/using-composer-to-manage-drupal-site-dependencies)
- [Drupal - Docker Development Environments](https://www.drupal.org/docs/develop/local-server-setup/docker-development-environments)
- [Github - Composer Template](https://github.com/drupal-composer/drupal-project)

To repeat, comment out everthing in the `Dockerfile` after `WORKDIR /app`.

Then uncomment the `- ./app:/app` volume mount in `docker-compose.yaml` so that you can edit the `app` directory from the container.

Next, you can run `docker compose drupal exec composer create-project drupal-composer/drupal-project:8.x-dev /app --stability dev --no-interaction --no-install` which will scaffold the app directory for us.

Finally undo your commenting and uncommenting and follow it up with a `make up` and you should be up and running with the latest changes from the `drupal-composer` project.

Note if you've added or changed any required modules or themes, this will cause them to get removed 
from the `composer.json` file and your site will be unhappy if it was depending on them.
