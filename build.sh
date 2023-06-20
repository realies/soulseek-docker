#!/bin/sh

usage() {
    echo "Usage: $0 <target> [push-user]"
    echo "<target> can be 'latest', 'testing', or a specific target version, e.g. '3.2.8'"
    echo "[push-user] optionally, the user for the hub and try to perform a push"
    exit 1
}


if [ -z "$1" ]
  then
    echo "No target supplied"
    usage
fi


case "$1" in
    'latest')
        URL='https://github.com/nicotine-plus/nicotine-plus/releases/latest/download/debian-package.zip'
        ;;
    'testing')
        URL='https://nightly.link/nicotine-plus/nicotine-plus/workflows/packaging/master/debian-package.zip'
        ;;
    *)
        URL="https://github.com/nicotine-plus/nicotine-plus/releases/download/$1/debian-package.zip"
        ;;
esac

echo "Download package from: $URL"
rm debian-package.zip
curl -fL# "$URL" -o debian-package.zip

TAG=$1 docker-compose build --progress plain

if [ ! -z "$2" ]
  then
    IMAGE=nicotine-docker
    IMAGE_W_TAG="${IMAGE}:$1"
    IMAGE_W_USR_TAG="$2/${IMAGE_W_TAG}"

    echo "#------------------------------"
    echo "docker tag ${IMAGE_W_TAG} ${IMAGE_W_USR_TAG}"
    docker tag ${IMAGE_W_TAG} ${IMAGE_W_USR_TAG}

    echo "#------------------------------"
    echo "docker push ${IMAGE_W_USR_TAG}"
    docker push ${IMAGE_W_USR_TAG}
fi

