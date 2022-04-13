#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR
echo $DIR

echo "$(date) About to renew certificates" >> ./log/letsencrypt-renew.log
docker run \
       -i \
       --rm \
       --name certbot \
       -v $PWD/letsencrypt:/etc/letsencrypt \
       -v $PWD/webroot:/webroot \
       certbot/certbot \
       renew -w /webroot

echo "$(date) Cat certificates" >> ./log/letsencrypt-renew.log

function cat-cert() {
  dir="./letsencrypt/live/$1"
  cat "$dir/privkey.pem" "$dir/fullchain.pem" > "./certs/$1.pem"
}

for dir in ./letsencrypt/live/*; do
  if [[ "$dir" != *"README" ]]; then
    cat-cert $(basename "$dir")
  fi
done

echo "$(date) Reload haproxy" >> ./log/letsencrypt-renew.log
docker service update --force proxy_proxy

echo "$(date) Done" >> ./log/letsencrypt-renew.log