pullImage:
	docker pull postgres:13-alpine

postgres:
	docker run --name postgres13-LetsGoFurther -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=secret -d postgres:13-alpine

createdb:
	docker exec -it postgres13-LetsGoFurther createdb --username=postgres --owner=postgres greenlight 

createUser: 
	docker exec -it postgres13-LetsGoFurther psql -U postgres -d greenlight -c "CREATE ROLE greenlight WITH LOGIN PASSWORD 'pa55word';"

createExtension: 
	docker exec -it postgres13-LetsGoFurther psql -U postgres -d greenlight -c "CREATE EXTENSION IF NOT EXISTS citext;"


.PHONY: pullImage postgres createdb createUser 