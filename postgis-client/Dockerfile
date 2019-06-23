FROM alpine:3.10.0
# This docker-images can be run in AWS batch.

### update apk and existing packages
RUN apk upgrade --update \
    ### packages from main repo
    && apk add \
        bash=~5.0 \ 
        wget=~1.20 \
        curl=~7.65 \
        git=~2.22 \
        postgresql-client=~11.3 \
    ### packages from testing repo
    && apk add \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        postgis=~2.5 \
        aws-cli=~1.16

ADD fetch_and_run.sh /usr/local/bin/fetch_and_run.sh
WORKDIR /tmp
USER nobody
ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]
