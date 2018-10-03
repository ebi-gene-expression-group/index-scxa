FROM alpine:3.8

RUN apk update && apk add bash curl jq

ADD bin/* /usr/local/bin/
