#!/bin/bash

# Build the signet full node docker image
# Takes image name as first argument, which defaults to
#
#   kallewoof/signet:0.18

imagename="signet-clightning"

if [ $# -gt 0 ]; then imagename=$1; shift; fi
if [ $# -gt 0 ]; then echo "syntax: $0 [<image name>]"; exit 1; fi

docker build -t $imagename .
