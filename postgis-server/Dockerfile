FROM postgres:14.0-alpine

### Versions
ARG CGAL_VERSION="5.3"
ARG SFCGAL_VERSION="1.4.0"
ARG PROJ_VERSION="8.1.1"
ARG POSTGIS_VERSION="3.1.4"

### Download Locations
ARG CGAL_SOURCE="https://github.com/CGAL/cgal/releases/download/v$CGAL_VERSION/CGAL-$CGAL_VERSION.tar.xz"
ARG SFCGAL_SOURCE="https://gitlab.com/Oslandia/SFCGAL/-/archive/v$SFCGAL_VERSION/SFCGAL-v$SFCGAL_VERSION.tar.gz"
ARG PROJ_SOURCE="https://download.osgeo.org/proj/proj-$PROJ_VERSION.tar.gz"
ARG POSTGIS_SOURCE="https://download.osgeo.org/postgis/source/postgis-$POSTGIS_VERSION.tar.gz"

### Checksums (MUST match the version)
ARG CGAL_SHA256="2c242e3f27655bc80b34e2fa5e32187a46003d2d9cd7dbec8fbcbc342cea2fb6"
ARG PROJ_MD5="f017fd7d35311b0d65b2cf0503844690"

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
        llvm11-dev \
        tiff-dev \
        json-c-dev \
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
### PROJ: Source download, verify and extract
    && wget -nv $PROJ_SOURCE -O /tmp/proj-$PROJ_VERSION.tar.gz \
    && echo "$PROJ_MD5  /tmp/proj-$PROJ_VERSION.tar.gz" | md5sum -c - \
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
### CGAL installation (https://doc.cgal.org/latest/Manual/usage.html#secusingwebsite)
    && cd /usr/src/CGAL-${CGAL_VERSION} \
    && cmake . -Wno-dev \
    && make -j $(nproc) \
    && make install \
#
### SFCGAL installation (https://oslandia.github.io/SFCGAL/installation.html)
    && cd /usr/src/SFCGAL-v${SFCGAL_VERSION} \
    && cmake . -Wno-dev -Wno-deprecated -Wdeprecated-declarations \
    && make -j $(nproc) \
    && make install \
#
### PROJ installation (https://proj.org/install.html)
    && cd /usr/src/proj-${PROJ_VERSION} \
    && ./configure --without-curl \
    && make -j $(nproc) \
    && make install \
#
### postgis installation (https://postgis.net/source/)
    && cd /usr/src/postgis-${POSTGIS_VERSION} \
    && ./configure \
		--disable-gtktest \
        # FIXME: otherwise LTO produces a "LLVM ERROR: ThinLTO cannot create input file: Invalid record"
        CFLAGS="-D LLVM_ENABLE_LTO=OFF" \ 
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
