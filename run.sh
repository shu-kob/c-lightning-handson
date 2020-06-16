set -e -a

imagename="kallewoof/signet:0.18"
datadirmp=$HOME/docker-signet

if [ $# -gt 0 ]; then imagename=$1; shift; fi
if [ $# -gt 0 ]; then datadirmp=$1; shift; fi
if [ $# -gt 0 ]; then echo "syntax: $0 [<image name> [<datadir>]]"; exit 1; fi

mkdir -p $datadirmp
docker run -p 38333:38333 -v $datadirmp:/root/.bitcoin $imagename