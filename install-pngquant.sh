#!/bin/sh
set -e
if [ ! -d "$HOME/pngquant-2.5.0/lib" ]; then
  echo 'TODO remettre la compilation ici';
else
  echo 'Using cached directory.';
fi
wget https://github.com/pornel/pngquant/archive/2.5.0.tar.gz -O pngquant.tar.gz
tar -xzvf pngquant.tar.gz
cd pngquant-2.5.0 && make
export PATH=$PATH:pngquant-2.5.0