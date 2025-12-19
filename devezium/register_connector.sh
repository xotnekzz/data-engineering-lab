#!/bin/bash

# Debezium 서비스 URL
CONNECT_HOST="127.0.0.1"
CONNECT_PORT="8083"
HEADER="Content-Type: application/json"

echo "Waiting for Debezium to start..."

# Health Check Loop
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://${CONNECT_HOST}:${CONNECT_PORT}/)" != "200" ]]; do 
    sleep 5
    echo -n "."
done

echo -e "\nDebezium is up! Registering Connector..."

# 커넥터 등록 요청 (Kafka Broker IP 수정 포함)
curl -i -X POST -H "${HEADER}" http://${CONNECT_HOST}:${CONNECT_PORT}/connectors/ -d '{
  "name": "mariadb-connector",
  "config": {
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "tasks.max": "1",
    "database.hostname": "mariadb",
    "database.port": "3306",
    "database.user": "debezium",
    "database.password": "dbz",
    "database.server.id": "184054",
    "topic.prefix": "mysql",
    "database.include.list": "demo_db",
    "schema.history.internal.kafka.bootstrap.servers": "10.100.0.41:29092,10.100.0.42:29092,10.100.0.43:29092",
    "schema.history.internal.kafka.topic": "schema-changes.inventory"
  }
}'

echo -e "\n\nConnector Registration Completed."
