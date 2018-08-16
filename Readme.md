# Drupal in Docker test

Testing out if Drupal can be made to play well with Docker for GMRI purposes.
This uses the Docker Library PostgreSQL image as is, and rebuilds the Docker Library Drupal image using Composer.


## Using

If setting up for the first time, see _Initial Configuration_ down below.

Otherwise use `make up` to start the server which you can then access at [localhost:8080](http://localhost:8080/).

If you `ctrl-c` out of the logs (or close the window), you can get the logs back with `make logs`. 

The docker containers are launched in the background with `make-up`, so they won't dissapear if you close the window or logs, so once you're done, `ctrl-c` out of the logs and run `make down` to shut down the server.

If you wish to take a backup of the database, you can use `make dump-sql` which will save the database roles and content to `./docker-data/dump.sql`.


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
