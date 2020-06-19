set -e -a

imagename="signet-clightning"
datadirmp=$HOME/docker-signet
lighntingdatadir=$HOME/docker-lightning

if [ $# -gt 0 ]; then imagename=$1; shift; fi
if [ $# -gt 0 ]; then datadirmp=$1; shift; fi
if [ $# -gt 0 ]; then echo "syntax: $0 [<image name> [<datadir>]]"; exit 1; fi

mkdir -p $datadirmp
docker run -p 38333:38333 -v $datadirmp:/root/.bitcoin -p 9735:9735 -v $lighntingdatadir:/root/.lightning $imagename