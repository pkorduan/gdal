# gdal-sshd
Dockerfile for the image pkorduan/gdal on docker hub

This image install gdal from gdal/trunkk to support the current ogr NAS driver to import german cadastral data (ALKIS) in NAS format to a PostGIS database.
Additionally we install ruby-libxml and zip to prepare packed NAS files for the import with ogr2ogr.
To enable a call to ogr2ogr from within other containers an sshd was setting up and the images can be run as a demon.

Latest Version 2.2.1 is with debian:jessie and GDAL 2.2.0dev, released 2016/99/99

The gdal container will be startet as a service with 
```
docker run --name gdal \
  -h ${SERVER_NAME}_gdal-container \
  -v /var/www/data:/data \
  --link pgsql-server:pgsql \
  -P \
  -d pkorduan/gdal:latest
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
you can connect from within the web container via ssh to the gdal container and can execute gdal and ogr commands to load data from or to shared directory /var/www/data from or to the PostGIS database.
