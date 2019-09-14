### build environment
FROM golang:1.12.6-alpine3.10 AS build

### update apk and existing packages
RUN apk upgrade --update &&\
    ### build packages
    apk add \
        build-base \    
        git \
    && apk add \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
        leveldb-dev \
    && apk add \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        geos-dev
RUN go get github.com/omniscale/imposm3 \
    # && ( cd /go/src/github.com/omniscale/imposm3 \
    #     && TAG=$(git name-rev --tags --name-only $(git rev-parse --short HEAD))  ) \
    # && go build -X github.com/omniscale/imposm3.Version=$(TAG)
    && go install github.com/omniscale/imposm3/cmd/imposm

FROM alpine:3.10.0
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
    && apk add \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
        leveldb \
    && apk add \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        postgis \
        aws-cli \
        geos \
        proj-dev \
    && rm -rf /var/cache/apk/*

COPY fetch_and_run.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/fetch_and_run.sh

### add imposm binary
COPY --from=build /go/bin/imposm /usr/local/bin/

COPY grids /grids/
RUN chmod -R +r /grids

WORKDIR /tmp
USER nobody
ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]
