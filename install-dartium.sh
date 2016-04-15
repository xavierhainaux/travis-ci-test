#!/bin/bash

set -e -x

DART_CHANNEL=$1
VERSION=$2
ARCH=$3

AVAILABLE_DART_VERSION=$(curl "https://storage.googleapis.com/dart-archive/channels/${DART_CHANNEL}/release/${VERSION}/VERSION" | python -c \
    'import sys, json; print(json.loads(sys.stdin.read())["version"])')

echo Fetch Dart channel: ${DART_CHANNEL}

URL_PREFIX=https://storage.googleapis.com/dart-archive/channels/${DART_CHANNEL}/release/${VERSION}
DARTIUM_URL="$URL_PREFIX/dartium/dartium-$ARCH-release.zip"

download_and_unzip() {
  ZIPFILE=${1/*\//}
  curl -O -L $1 && unzip -q $ZIPFILE && rm $ZIPFILE
}

download_and_unzip $DARTIUM_URL

echo Fetched new dart version $(<dart-sdk/version)

if [[ -n $DARTIUM_URL ]]; then
  mv dartium-* $HOME/dartium
  mv $HOME/dartium/chrome $HOME/dartium/dartium
fi