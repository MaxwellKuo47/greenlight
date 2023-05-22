pullImage:
	docker pull postgres:13-alpine

createContainer:
	docker run --name postgres13-LetsGoFurther -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=secret -d postgres:13-alpine

createdb:
	docker exec -it postgres13-LetsGoFurther createdb --username=postgres --owner=postgres greenlight 

createUser: 
	docker exec -it postgres13-LetsGoFurther psql -U postgres -d greenlight -c "CREATE ROLE greenlight WITH LOGIN PASSWORD 'pa55word';"

createExtension: 
	docker exec -it postgres13-LetsGoFurther psql -U postgres -d greenlight -c "CREATE EXTENSION IF NOT EXISTS citext;"

genMigrateFile:
	migrate create -seq -ext=.sql -dir=./migrations $(des)

migrateCheck:
	migrate -path=./migrations -database=$(TEST_GREENLIGHT_DB_DSN) version

migrateUp:
	migrate -path=./migrations -database=$(TEST_GREENLIGHT_DB_DSN) up

migrateDown:
	migrate -path=./migrations -database=$(TEST_GREENLIGHT_DB_DSN) down

migrateToVersion:
	migrate -path=./migrations -database=$(TEST_GREENLIGHT_DB_DSN) goto $(version)

.PHONY: pullImage postgres createdb createUser genMigrateFile migrateCheck migrateUp migrateDown migrateToVersion