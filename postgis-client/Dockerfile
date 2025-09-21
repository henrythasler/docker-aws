### build environment
FROM golang:1.25.1-alpine3.22 AS build

### update apk and existing packages
RUN apk upgrade --update \
    ### build packages
    && apk add \
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

RUN go install github.com/omniscale/imposm3/cmd/imposm@v0.14.2

FROM alpine:3.22.1
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
        gdal-tools \
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
