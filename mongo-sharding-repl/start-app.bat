@echo off

docker compose up -d

echo Starting docker...
timeout /t 120

echo Initializing config server...
echo =============================
docker compose exec -T configSrv mongosh --port 27017 --quiet --eval "rs.initiate({_id: 'config_server', configsvr: true, members: [{ _id: 0, host: 'configSrv:27017' }]})"
echo =============================
echo Initializing shard1...
echo =============================
docker compose exec -T shard1-1 mongosh --port 27018 --quiet --eval "rs.initiate({_id: 'shard1ReplicaSet', members: [{ _id: 1, host: 'shard1-1:27018', priority: 1},{ _id: 2, host: 'shard1-2:27021', priority: 2},{ _id: 3, host: 'shard1-3:27022', priority: 3}]})"
echo =============================
echo Initializing shard2...
echo =============================
docker compose exec -T shard2-1 mongosh --port 27019 --quiet --eval "rs.initiate({_id: 'shard2ReplicaSet', members: [{ _id: 1, host: 'shard2-1:27019', priority: 1},{ _id: 2, host: 'shard2-2:27023', priority: 2},{ _id: 3, host: 'shard2-3:27024', priority: 3}]})"
echo =============================
echo If OK press any key to continue, if not - close
timeout /t 120

echo Initializing MongoDB router...
echo =============================
docker compose exec -T mongos_router  mongosh --port 27020 --quiet --eval "sh.addShard('shard1ReplicaSet/shard1-1:27018')"
docker compose exec -T mongos_router  mongosh --port 27020 --quiet --eval "sh.addShard('shard2ReplicaSet/shard2-1:27019')"
echo =============================
echo If OK press any key to continue, if not - close
timeout /t 120

echo Filling up the DB...
echo =============================
docker compose exec -T mongos_router  mongosh --port 27020 --quiet --eval "sh.enableSharding('somedb');"
docker compose exec -T mongos_router  mongosh --port 27020 --quiet --eval "sh.shardCollection('somedb.helloDoc', { 'name' : 'hashed' } )"
docker compose exec -T mongos_router  mongosh --port 27020 --quiet --eval "db.getSiblingDB('somedb').helloDoc.insertMany([...Array(1000).keys()].map(i => ({ age: i, name: 'ly' + i })))"
echo =============================
echo Counting documents in MongoDB router...
echo =============================
docker compose exec -T mongos_router  mongosh --port 27020 --quiet --eval "db.getSiblingDB('somedb').helloDoc.countDocuments()"
echo =============================
echo Counting documents in mongo shard1...
echo =============================
docker compose exec -T shard1-1  mongosh --port 27018 --quiet --eval "db.getSiblingDB('somedb').helloDoc.countDocuments()"
echo =============================
echo Counting documents in mongo shard2...
echo =============================
docker compose exec -T shard2-1  mongosh --port 27019 --quiet --eval "db.getSiblingDB('somedb').helloDoc.countDocuments()"
echo =============================
echo Check: overall = 1000, shard 1 = 492, shard 2 = 508
timeout /t 120