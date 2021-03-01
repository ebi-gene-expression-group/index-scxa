FROM quay.io/jitesoft/alpine:3.8

RUN apk update && apk add bash curl jq bats

ENV BIOSOLR_JAR_PATH /usr/local/lib/solr-ontology-update-processor-1.2.jar

COPY bin/* /usr/local/bin/
COPY lib/* /usr/local/lib/
