#! /bin/sh

openssl genrsa 2048 > server.key
openssl req -new -key server.key > server.csr
openssl x509 -days 3650 -req -signkey server.key < server.csr > server.crt

sudo cp server.crt /etc/ssl/certs/server.crt
sudo cp server.key /etc/ssl/private/server.key

