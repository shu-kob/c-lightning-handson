FROM ubuntu:18.04

RUN apt-get update -y \
    && apt-get install -y \
        automake \
        autotools-dev \
        bsdmainutils \
        build-essential \
        git \
        gosu \
        libboost-chrono-dev \
        libboost-filesystem-dev \
        libboost-system-dev \
        libboost-test-dev \
        libboost-thread-dev \
        libevent-dev \
        libminiupnpc-dev \
        libssl-dev \
        libtool \
        libzmq3-dev \
        pkg-config \
        python3 \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/bitcoin/bitcoin /workspace

WORKDIR /workspace

RUN git fetch origin pull/16411/head:signet

RUN git checkout signet

RUN ./contrib/install_db4.sh `pwd`

RUN ./autogen.sh

ENV BDB_PREFIX='/workspace/db4'

RUN  ./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include" --disable-tests --disable-bench --without-gui --prefix=/workspace/build

RUN V=1 make clean

RUN V=1 make -j2

RUN make install

ENV BITCOIN_VERSION=0.20.0
ENV BITCOIN_DATA=/root/.bitcoin
ENV PATH=/workspace/contrib/signet:$PATH

RUN mkdir -p ${BITCOIN_DATA}

COPY ./bitcoin.conf /root/.bitcoin/bitcoin.conf

COPY ./config /root/.lightning/config

COPY ./start_lightning.sh /root/lightning/start_lightning.sh

COPY docker-entrypoint.sh /entrypoint.sh

EXPOSE 8332 8333 18332 18333 18443 18444 38332 38333

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bitcoind", "-signet", "-txindex"]

RUN apt-get update -y \
    && apt-get install -y \
        autoconf \
        automake \
        build-essential \
        git \
        libtool \ 
        libgmp-dev \
        libsqlite3-dev \ 
        python3 \ 
        python3-mako \
        net-tools \ 
        zlib1g-dev \
        libsodium-dev \
        gettext \
        valgrind \ 
        python3-pip \ 
        libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/ElementsProject/lightning.git /lightning
WORKDIR /lightning
RUN git checkout -b v0.8.2

RUN pip3 install -r requirements.txt

RUN ./configure
RUN make
RUN make install

RUN cp cli/lightning-cli /usr/local/bin/

ENV LIGHTNING_DATA=/root/.lightning

RUN mkdir -p ${LIGHTNING_DATA}