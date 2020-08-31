FROM postgres:11.9-alpine

### Versions
ARG CGAL_VERSION="4.14.3"
ARG SFCGAL_VERSION="1.3.8"
ARG PROJ_VERSION="6.3.2"
ARG POSTGIS_VERSION="2.5.5"

### Download Locations
ARG CGAL_SOURCE="https://github.com/CGAL/cgal/releases/download/releases%2FCGAL-$CGAL_VERSION/CGAL-$CGAL_VERSION.tar.xz"
ARG SFCGAL_SOURCE="https://gitlab.com/Oslandia/SFCGAL/-/archive/v$SFCGAL_VERSION/SFCGAL-v$SFCGAL_VERSION.tar.gz"
ARG PROJ_SOURCE="https://download.osgeo.org/proj/proj-$PROJ_VERSION.tar.gz"
ARG POSTGIS_SOURCE="https://download.osgeo.org/postgis/source/postgis-$POSTGIS_VERSION.tar.gz"

### Checksums
ARG CGAL_SHA256="5bafe7abe8435beca17a1082062d363368ec1e3f0d6581bb0da8b010fb389fe4"
#ARG POSTGIS_SHA256="b9754c7b9cbc30190177ec34b570717b2b9b88ed271d18e3af68eca3632d1d95"

### update apk and existing packages
RUN apk upgrade --update \
#
### install dependencies
    && apk add --virtual .build-deps \
        ### basic build packages              
        build-base \
        cmake \
        wget \
        ### additional build packages    
        perl \
        gmp-dev \
        mpfr-dev \
        boost-dev \
        libxml2-dev \
        sqlite \
        sqlite-dev \
    ### build packages from edge repo
    && apk add --virtual .build-deps-edge \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        openssl-dev \
        protobuf-c-dev \
        poppler \
        clang \
        llvm10-dev \
    ### build packages from testing repo
    && apk add --virtual .build-deps-testing \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        \
    ### build packages from community repo
    && apk add --virtual .build-deps-community \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
        geos-dev \
    #        
    ### various runtime packages 
    && apk add --virtual .postgis-run-deps-edge \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        openssl \
        protobuf-c \
    # community
    && apk add --virtual .postgis-run-deps-community \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
        gdal-dev \
        geos \
    # testing
    && apk add --virtual .postgis-run-deps-testing \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        \
    # main
    && apk add --virtual .postgis-run-deps \
        json-c \
        gmp \
        mpfr4 \
        boost \
        boost-serialization \
#
### CGAL: Source download, verify and extract
    && wget -nv $CGAL_SOURCE -O /tmp/CGAL-$CGAL_VERSION.tar.xz \
    && echo "$CGAL_SHA256  /tmp/CGAL-$CGAL_VERSION.tar.xz" | sha256sum -c - \
    && mkdir -p /usr/src \
    && tar xf /tmp/CGAL-$CGAL_VERSION.tar.xz -C /usr/src \
#
### SFCGAL: Source download, verify and extract
    && wget -nv $SFCGAL_SOURCE -O /tmp/SFCGAL-$SFCGAL_VERSION.tar.gz \
    && mkdir -p /usr/src \
    && tar xzf /tmp/SFCGAL-$SFCGAL_VERSION.tar.gz -C /usr/src \
#
### PROJ: Source download
    && wget -nv $PROJ_SOURCE -O /tmp/proj-$PROJ_VERSION.tar.gz \
    && mkdir -p /usr/src \
    && tar xzf /tmp/proj-$PROJ_VERSION.tar.gz -C /usr/src \
    && wget -nv https://download.osgeo.org/proj/proj-datumgrid-1.7.zip -O /tmp/proj-datumgrid-1.7.zip \
    && unzip -o /tmp/proj-datumgrid-1.7.zip -d /usr/src/proj-$PROJ_VERSION/data/ \
#
### postgis: Source download, verify and extract
    && wget -nv $POSTGIS_SOURCE -O /tmp/postgis-$POSTGIS_VERSION.tar.gz \
    # && echo "$POSTGIS_SHA256  /tmp/postgis-$POSTGIS_VERSION.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src \
    && tar xzf /tmp/postgis-$POSTGIS_VERSION.tar.gz -C /usr/src \
#
### CGAL installation
    && cd /usr/src/CGAL-${CGAL_VERSION} \
    && cmake . -Wno-dev \
    && make -j $(nproc) \
    && make install \
#
### SFCGAL installation
    && cd /usr/src/SFCGAL-v${SFCGAL_VERSION} \
    && cmake . -Wno-dev -Wno-deprecated -Wdeprecated-declarations \
    && make -j $(nproc) \
    && make install \
#
### PROJ installation
    && cd /usr/src/proj-${PROJ_VERSION} \
    && ./configure \
    && make -j $(nproc) \
    && make install \
#
### postgis installation
    && cd /usr/src/postgis-${POSTGIS_VERSION} \
    && ./configure \
		--disable-gtktest \
    && make -j $(nproc) \
    && make install \
#
### clean up files
    && apk del .build-deps .build-deps-edge .build-deps-testing .build-deps-community \
    && rm -rf /tmp/* /var/cache/apk/* /usr/src/* \
#
# FIXME - find a way to make postgis use /usr/local/lib64 as location for SFCGAL libraries
    && ln -s /usr/local/lib64/libSFCGAL.so* /usr/local/lib/

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-postgis.sh /usr/local/bin
COPY ./postgresql.conf /etc/postgresql/postgresql.conf
