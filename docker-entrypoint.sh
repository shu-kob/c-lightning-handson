#!/bin/bash
# Source: https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.18/docker-entrypoint.sh

set -e

if [ ! -e "$BITCOIN_DATA/bitcoin.conf" ]; then
    echo "$0: creating $BITCOIN_DATA/bitcoin.conf with signet=1"
    echo "signet=1\ntxindex=1\n[signet]\nrpcuser=hoge\nrpcpassword=hoge\nrpcport=38332\nport=38333" > $BITCOIN_DATA/bitcoin.conf
    echo "network=signet" > $LIGHTNING_DATA/config
fi

if [ ! -e "$LIGHTNING_DATA/config" ]; then
    echo "network=signet" >> $LIGHTNING_DATA/config
fi

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for bitcoind"
  set -- bitcoind "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "bitcoind" ]; then
  mkdir -p "$BITCOIN_DATA"
  chmod 700 "$BITCOIN_DATA"

  echo "$0: setting data directory to $BITCOIN_DATA"

  set -- "$@" -datadir="$BITCOIN_DATA"
fi

echo
exec "$@"
