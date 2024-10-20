@echo off

docker compose up -d

echo Starting docker...
timeout /t 120

echo Initializing config server...
docker compose exec -T configSrv mongosh --port 27017 --quiet --eval "rs.initiate({_id: 'config_server', configsvr: true, members: [{ _id: 0, host: 'configSrv:27017' }]})"

echo Initializing shard1...
docker compose exec -T shard1 mongosh --port 27018 --quiet --eval "rs.initiate({_id: 'shard1', members: [{ _id: 0, host: 'shard1:27018' }]})"

echo Initializing shard2...
docker compose exec -T shard2 mongosh --port 27019 --quiet --eval "rs.initiate({_id: 'shard2', members: [{ _id: 0, host: 'shard2:27019' }]})"

echo Waiting for config server and shards to initialize...
timeout /t 120

echo Initializing MongoDB router...
docker compose exec -T mongos_router  mongosh --port 27020 --quiet --eval "sh.addShard('shard1/shard1:27018')"
docker compose exec -T mongos_router  mongosh --port 27020 --quiet --eval "sh.addShard('shard2/shard2:27019')"

echo Waiting for MongoDB router to initialize...
timeout /t 120

echo Filling up the DB...
docker compose exec -T mongos_router  mongosh --port 27020 --quiet --eval "sh.enableSharding('somedb');"
docker compose exec -T mongos_router  mongosh --port 27020 --quiet --eval "sh.shardCollection('somedb.helloDoc', { 'name' : 'hashed' } )"
docker compose exec -T mongos_router  mongosh --port 27020 --quiet --eval "db.getSiblingDB('somedb').helloDoc.insertMany([...Array(1000).keys()].map(i => ({ age: i, name: 'ly' + i })))"

echo Counting documents in MongoDB router...
docker compose exec -T mongos_router  mongosh --port 27020 --quiet --eval "db.getSiblingDB('somedb').helloDoc.countDocuments()"

echo Counting documents in mongo shard1...
docker compose exec -T shard1  mongosh --port 27018 --quiet --eval "db.getSiblingDB('somedb').helloDoc.countDocuments()"

echo Counting documents in mongo shard2...
docker compose exec -T shard2  mongosh --port 27019 --quiet --eval "db.getSiblingDB('somedb').helloDoc.countDocuments()"
timeout /t 120