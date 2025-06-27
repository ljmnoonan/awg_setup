#!/bin/bash



# Parameters
$AWG_SERVER_PORT=51820

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
    error() {
        echo -e "${RED}[ERROR]${NC} $*" >&2
        exit 1
    }

    warn() {
        echo -e "${YELLOW}[WARN]${NC} $*" >&2
    }

    info() {
        echo -e "${BLUE}[INFO]${NC} $*" >&2
    }

    success() {
        echo -e "${GREEN}[SUCCESS]${NC} $*" >&2
    }

# Create directory
mkdir -p /opt/amnezia/amnezia-awg
chown root /opt/amnezia/amnezia-awg

# Setup docker network
if ! sudo docker network ls | grep -q amnezia-dns-net; then sudo docker network create \
  --driver bridge \
  --subnet=172.29.172.0/24 \
  --opt com.docker.network.bridge.name=amn0 \
  amnezia-dns-net;\
fi

# Delete old container if exists
docker stop amnezia-awg
docker rm -fv amnezia-awg
docker rmi amnezia-awg
rm /opt/amnezia/amnezia-awg/Dockerfile

# Set new
cp ./files/Dockerfile /opt/amnezia/amnezia-awg/Dockerfile
chown root /opt/amnezia/amnezia-awg/Dockerfile

# Build new container
docker build --no-cache --pull -t amnezia-awg /opt/amnezia/amnezia-awg

# Run container
docker run -d \
    --log-driver none \
    --restart always \
    --privileged \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    -p $AWG_SERVER_PORT:$AWG_SERVER_PORT/udp \
    -v /lib/modules:/lib/modules \
    --sysctl=net.ipv4.conf.all.src_valid_mark=1 \
    --name amnezia-awg \
    amnezia-awg

docker network connect amnezia-dns-net amnezia-awg

# Start modifying the container
docker exec -i amnezia-awg mkdir -p /opt/amnezia
docker cp /tmp/5LaJWzE7FNMJuhUN.tmp amnezia-awg://opt/amnezia/hVeRqrUzwRWX23W1.sh
docker exec -i amnezia-awg bash /opt/amnezia/hVeRqrUzwRWX23W1.sh
docker exec -i amnezia-awg rm /opt/amnezia/hVeRqrUzwRWX23W1.sh

















