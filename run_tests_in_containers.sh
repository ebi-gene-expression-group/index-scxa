#!/usr/bin/env bash
# Above ^^ will test that bash is installed
SOLR_HOST=my_solr:8983
SOLR_CONT_NAME=my_solr
# 8.11.1
SOLR_VERSION=8.7
ZK_HOST=gxa-zk-1
ZK_PORT=2181
# 3.6.2
ZK_VERSION=3.5.8
DOCKER_NET=net-index-scxa
docker stop $SOLR_CONT_NAME && docker rm $SOLR_CONT_NAME
docker stop $ZK_HOST && docker rm $ZK_HOST


docker network create $DOCKER_NET

docker run --rm --net $DOCKER_NET --name $ZK_HOST \
    -d -p $ZK_PORT:$ZK_PORT \
    -e ZOO_MY_ID=1 \
    -e ZOO_4LW_COMMANDS_WHITELIST="mntr,conf,ruok" \
    -e ZOO_SERVERS="server.1=$ZK_HOST:2888:3888;$ZK_PORT" \
    -t zookeeper:$ZK_VERSION
sleep 10

export SIGNING_PRIVATE_KEY=signing_key.pem
export SIGNING_PUBLIC_KEY_DER=signing_key.der
export BIOSOLR_VERSION=2.0.0

bash tests/create-keys-for-tests.sh

docker run --rm --net $DOCKER_NET --name $SOLR_CONT_NAME \
    -d -p 8983:8983 \
    -e ZK_HOST=$ZK_HOST:$ZK_PORT \
    -v $( pwd )/tests:/opt/tests \
    -v $( pwd )/$SIGNING_PUBLIC_KEY_DER:/tmp/$SIGNING_PUBLIC_KEY_DER \
    -t solr:$SOLR_VERSION \
    -c -Denable.packages=true -m 2g



SECURITY_JSON=/usr/local/tests/security.json

# Setup auth
echo "Setup auth"
docker run --net $DOCKER_NET \
    -d -v $( pwd )/tests/security.json:$SECURITY_JSON \
    -t solr:$SOLR_VERSION bin/solr zk cp file:$SECURITY_JSON zk:/security.json -z $ZK_HOST:$ZK_PORT

sleep 20

# Upload der to Solr
echo "Upload public der key to Solr"
docker exec -d $SOLR_CONT_NAME \
    bin/solr package add-key /tmp/$SIGNING_PUBLIC_KEY_DER

docker build -t test/index-scxa-module .
sleep 10

BIOSOLR_REMOTE_JAR_PATH=/packages/solr-ontology-update-processor-$BIOSOLR_VERSION.jar

docker exec --user=solr $SOLR_CONT_NAME bin/solr create_collection -c scxa-analytics-v6
docker exec --user=solr $SOLR_CONT_NAME bin/solr create_collection -c scxa-gene2experiment-v1
docker run -i --net $DOCKER_NET -v $( pwd )/tests:/opt/tests \
    -v $(pwd)/lib/solr-ontology-update-processor-$BIOSOLR_VERSION.jar:$BIOSOLR_REMOTE_JAR_PATH \
    -v $(pwd)/$SIGNING_PRIVATE_KEY:/packages/$SIGNING_PRIVATE_KEY \
    -e SOLR_HOST=$SOLR_HOST \
    -e BIOSOLR_JAR_PATH=$BIOSOLR_REMOTE_JAR_PATH \
    -e BIOSOLR_VERSION=$BIOSOLR_VERSION \
    -e SIGNING_PRIVATE_KEY=/packages/$SIGNING_PRIVATE_KEY \
    -e ADMIN_USER=atlas \
    -e ADMIN_U_PWD=fjaso983dada \
    -e QUERY_USER=queryu \
    -e QUERY_U_PWD=fsaf897asd3 \
    --entrypoint=/opt/tests/run-tests.sh test/index-scxa-module
