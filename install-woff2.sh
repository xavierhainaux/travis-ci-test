#!/bin/sh
set -e
if [ ! -d "woff2" ]; then
  git clone --recursive https://github.com/google/woff2.git
  cd woff2
  ./configure --enable-cxx11 && make clean all
else
  echo 'Using cached directory.';
fi
