#!/bin/sh
set -e
if [ ! -d "optipng-0.7.5" ]; then
  wget http://prdownloads.sourceforge.net/optipng/optipng-0.7.5.tar.gz
  tar -xzvf optipng-0.7.5.tar.gz
  cd optipng-0.7.5 && make
else
  echo 'Using cached directory.';
fi
