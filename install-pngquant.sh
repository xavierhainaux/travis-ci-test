#!/bin/sh
set -e
if [ ! -d "$HOME/pngquant-2.5.0/bin" ]; then
  wget https://github.com/pornel/pngquant/archive/2.5.0.tar.gz -O pngquant.tar.gz
  tar -xzvf pngquant.tar.gz
  cd pngquant-2.5.0 && ./configure --prefix=$HOME/pngquant-2.5.0 && make install
else
  echo 'Using cached directory.';
fi
