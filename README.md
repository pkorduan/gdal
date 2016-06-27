# gdal-sshd
Dockerfile for the image pkorduan/gdal on docker hub

geodata/gdal image include the binaries to convert geodata from and to a PostGIS database, but it is not possible to run a container based on that imamge from within another container. To execute gdal and ogr2ogr commands from applications in other containers we add a sshd that make it possible to connect via ssh to the running container.

The gdal container will be startet as a service with 
```
docker run --name gdal \
  -h ${SERVER_NAME}_gdal-container \
  -v /var/www/data:/data \
  --link pgsql-server:pgsql \
  -P \
  -d pkorduan/gdal:2.0.0
```
The Hostname is only to identify the container when you are inside. A local directory is mounted to the /data directory in the gdal container and the database. The precondition is that a database container would be created before, e.g. like this:
```
docker run --name pgsql-server \
  -h ${SERVER_NAME}_pgsql-container \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=$PGSQL_ROOT_PASSWORD \
  -d mdillon/postgis:${POSTGRESQL_IMAGE_VERSION}
```
If you are now in a web container like this:
```
docker run --name web \
    -h ${SERVER_NAME}_web-container \
    -v /var/www:/var/www \
    --link pgsql-server:pgsql \
    --link gdal:gdal \
    -p 80:80 \
    -p 443:443 \
    -d pkorduan/kvwmap-server:${KVWMAP_IMAGE_VERSION}
```
You can connect from within the web container via ssh to the gdal container and can execute gdal and ogr commands to load data from or to shared directory /var/www/data from or to the PostGIS database.
