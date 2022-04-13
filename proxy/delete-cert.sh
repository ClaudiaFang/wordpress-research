# docker run -t --rm -v /services/nginx/conf/letsencryptcertificates:/etc/letsencrypt -v /services/nginx/certdata:/data/letsencrypt certbot/certbot:v1.10.0 delete --cert-name any.certificate

DOMAIN=$1
OPTIONS=$2

echo "Unregist lagency certificate..."
if [ "$#" -lt 1 ]; then
    echo "Usage: ...  <domain> [options]"
    exit
fi

docker run --rm \
  -v $PWD/letsencrypt:/etc/letsencrypt \
  -v $PWD/webroot:/webroot \
  certbot/certbot \
  --non-interactive \
  delete --cert-name $DOMAIN \
  -d $DOMAIN \
  $OPTIONS