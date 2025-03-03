#!/bin/bash

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Error: .env file not found"
  exit 1
fi

if [ -z "$SSL_DOMAIN" ] || [ -z "$SSL_EMAIL" ]; then
  echo "Error: SSL_DOMAIN or SSL_EMAIL not set in .env file"
  exit 1
fi

domains=($SSL_DOMAIN www.$SSL_DOMAIN)
rsa_key_size=4096
data_path="./nginx/certbot"
email="$SSL_EMAIL" # Adding a valid address is strongly recommended
staging=${SSL_STAGING:-0} # Set to 1 if you're testing your setup to avoid hitting request limits

if [ -d "$data_path/conf/live/$SSL_DOMAIN" ]; then
  read -p "Existing data found for $SSL_DOMAIN. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

mkdir -p "$data_path/conf/live/$SSL_DOMAIN"
mkdir -p "$data_path/www"

# Create dummy certificate for domain
echo "Creating dummy certificate for $SSL_DOMAIN..."
openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1 \
  -keyout "$data_path/conf/live/$SSL_DOMAIN/privkey.pem" \
  -out "$data_path/conf/live/$SSL_DOMAIN/fullchain.pem" \
  -subj "/CN=localhost"

echo "Starting nginx..."
docker-compose up --force-recreate -d nginx

echo "Deleting dummy certificate for $SSL_DOMAIN..."
rm -Rf "$data_path/conf/live/$SSL_DOMAIN"

echo "Requesting Let's Encrypt certificate for $SSL_DOMAIN..."
# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    --email $email \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal \
    --no-eff-email \
    -d $SSL_DOMAIN -d www.$SSL_DOMAIN" certbot

echo "Reloading nginx..."
docker-compose exec nginx nginx -s reload