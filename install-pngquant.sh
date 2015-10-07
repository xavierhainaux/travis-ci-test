#!/bin/sh
set -e
if [ ! -d "$HOME/pngquant/lib" ]; then
  wget https://github.com/pornel/pngquant/archive/2.5.0.tar.gz -O pngquant
  tar -xvf pngquant
  cd pngquant && make && make install
else
  echo 'Using cached directory.';
fi