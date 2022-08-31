FROM alpine:3.16

RUN apk update && apk add bash curl jq bats openssl

ENV BIOSOLR_JAR_PATH /usr/local/lib/solr-ontology-update-processor-2.0.0.jar

COPY bin/* /usr/local/bin/
COPY lib/* /usr/local/lib/
