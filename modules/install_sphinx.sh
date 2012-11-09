#!/bin/bash

cd /tmp
wget http://sphinxsearch.com/files/sphinx-0.9.9.tar.gz
tar -xzf sphinx-0.9.9.tar.gz
cd sphinx-0.9.9
./configure --prefix=/usr
make all install

