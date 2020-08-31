### build environment
FROM golang:1.15.0-alpine3.12 AS build

### update apk and existing packages
RUN apk upgrade --update &&\
    ### build packages
    apk add \
        build-base \    
        git \
        zlib-dev \
    && apk add \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
        leveldb-dev \
        geos-dev
    # && apk add \
    #     --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \

RUN wget -O - http://m.m.i24.cc/osmconvert.c | cc -x c - -lz -O3 -o /osmconvert

RUN go get github.com/omniscale/imposm3 \
    # && ( cd /go/src/github.com/omniscale/imposm3 \
    #     && TAG=$(git name-rev --tags --name-only $(git rev-parse --short HEAD))  ) \
    # && go build -X github.com/omniscale/imposm3.Version=$(TAG)
    && go install github.com/omniscale/imposm3/cmd/imposm

FROM alpine:3.12.0
# This docker-image can be run in AWS batch.

### update apk and existing packages
RUN apk upgrade --update \
    ### packages from main repo
    && apk add \
        bash \ 
        wget \
        curl \
        git \
        postgresql-client \
    ### packages from other repos
    && apk add --virtual .build-deps-edge \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        poppler \
    && apk add \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
        leveldb \
        geos \
        postgis \
        aws-cli \
        proj-dev \
    && rm -rf /var/cache/apk/*

COPY fetch_and_run.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/fetch_and_run.sh

### add imposm binary
COPY --from=build /go/bin/imposm /usr/local/bin/

COPY --from=build /osmconvert /usr/local/bin/

COPY grids /grids/
RUN chmod -R 777 /grids

RUN mkdir -p /data
RUN chmod -R 777 /data

WORKDIR /tmp
USER nobody
ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]
