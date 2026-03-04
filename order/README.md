## docker build and up
docker compose down
docker volume rm ecommerce-project_mysql_data
docker compose up --build -d

## inside docker

docker exec -it order sh

## log check
docker compose logs order

## curl request to order service
curl -X POST http://localhost:8083/api/orders/test

## test
## test 1