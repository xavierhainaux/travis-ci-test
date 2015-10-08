#!/bin/sh
set -e
if [ ! -d "ttf2woff-0.12" ]; then
  wget http://wizard.ae.krakow.pl/~jb/ttf2woff/ttf2woff-0.12.tar.gz -O ttf2woff.tar.gz
  tar -xzvf ttf2woff.tar.gz
  cd ttf2woff-0.12 && make install
else
  echo 'Using cached directory.';
fi


