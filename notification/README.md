## Docker build command 
docker build -t notification .

## mysql run container command
docker run -d \
--name mysql-container \
-e MYSQL_ROOT_PASSWORD=rootpassword \
-e MYSQL_DATABASE=notification \
-e MYSQL_USER=app \
-e MYSQL_PASSWORD=app123 \
-p 3306:3306 \
mysql:8.0

## check running container
docker ps 

## stop mysql
docker stop mysql-container

## remove container

docker rm -f mysql-container

## run php myadmin
docker network create dev-net
docker network connect dev-net mysql-container

docker run -d \
--name phpmyadmin \
--network dev-net \
-e PMA_HOST=mysql-container \
-p 8085:80 \
--restart unless-stopped \
phpmyadmin/phpmyadmin:latest

## now run notification service image
docker run -d \
--name notification \
--network dev-net \
-e SPRING_DATASOURCE_URL=jdbc:mysql://mysql-container:3306/notification \
-e SPRING_DATASOURCE_USERNAME=app \
-e SPRING_DATASOURCE_PASSWORD=app123 \
-p 8082:8082 \
notification

## After adding something need to do the steps

first maven clean install for getting the latest jar file
then docker image built by below command...
docker build -t notification:latest .
docker ps
docker stop notification
docker rm -f notification

docker run -d \
--name notification \
--network dev-net \
-e SPRING_DATASOURCE_URL=jdbc:mysql://mysql-container:3306/notification \
-e SPRING_DATASOURCE_USERNAME=app \
-e SPRING_DATASOURCE_PASSWORD=app123 \
-p 8082:8082 \
notification

## Now actuator endpoint can check by this end point... 
http://localhost:8082/actuator/health

## check logs
docker logs notification -f

## test runner
