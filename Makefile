up: docker-data/drupal/sites # Start docker-compose
	docker-compose up -d --build
	docker-compose logs -f

down:
	docker-compose down

stop:
	docker-compose stop

logs:
	docker-compose logs -f

docker-data/drupal/sites: # copy the sites folder from drupal container to our volume location
	mkdir -p docker-data/drupal/sites
	docker run --rm drupal:8.5.6 tar -cC /var/www/html/sites . | tar -xC ./docker-data/drupal/sites

# use `docker diff CONTAINER_ID` to see if any meaningful files are changed from the image

dump-sql: # dump database roles and contents to docker-data/dump.sql
	docker-compose exec postgres su-exec postgres pg_dumpall -r > ./docker-data/dump.sql
	docker-compose exec postgres su-exec postgres pg_dump drupal_test >> ./docker-data/dump.sql