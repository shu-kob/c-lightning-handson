FROM ubuntu:18.04

RUN apt-get update -y && apt install -y wget xz-utils
RUN wget https://github.com/ElementsProject/lightning/releases/download/v0.8.2.1/clightning-v0.8.2.1-Ubuntu-18.04.tar.xz
RUN tar -xvf clightning-v0.8.2.1-Ubuntu-18.04.tar.xz
RUN chmod +x /usr/bin/lightning*

COPY ./config /root/.lightning/config

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

RUN  ./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include" --disable-tests --disable-bench --without-gui

RUN V=1 make clean

RUN V=1 make -j2

RUN make install

ENV BITCOIN_DATA=/root/.bitcoin

RUN mkdir -p ${BITCOIN_DATA}

EXPOSE 8332 8333 18332 18333 18443 18444 38332 38333

COPY ./bitcoin.conf /root/.bitcoin/bitcoin.conf

CMD ["bitcoind"]