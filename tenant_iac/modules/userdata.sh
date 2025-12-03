#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

TENANT="${tenant_name}"
CERT_DIR="/etc/nginx/ssl"
mkdir -p $CERT_DIR

apt update -y
apt install -y docker.io nginx openssl
systemctl enable docker && systemctl start docker

echo "==== SSL Certificate Logic ===="

######################################
# USE USER-PROVIDED SSL IF AVAILABLE
######################################
if [[ -n "${custom_cert_pem}" && -n "${custom_key_pem}" ]]; then
    echo "➡ Using USER PROVIDED SSL certificate"

    echo "${custom_cert_pem}" > $CERT_DIR/custom.crt
    echo "${custom_key_pem}"  > $CERT_DIR/custom.key

    SSL_CERT="$CERT_DIR/custom.crt"
    SSL_KEY="$CERT_DIR/custom.key"
else
    echo "➡ No cert passed ⇒ generating self-signed certificate"

    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout $CERT_DIR/selfsigned.key \
        -out $CERT_DIR/selfsigned.crt \
        -subj "/CN=$TENANT.duckdns.org"

    SSL_CERT="$CERT_DIR/selfsigned.crt"
    SSL_KEY="$CERT_DIR/selfsigned.key"
fi

######################################
# NGINX CONFIGURATION
######################################
cat > /etc/nginx/sites-available/default <<EOF
server {
  listen 80;
  server_name $TENANT.duckdns.org;
  return 301 https://\$host\$request_uri;
}

server {
  listen 443 ssl;
  server_name $TENANT.duckdns.org;

  ssl_certificate $SSL_CERT;
  ssl_certificate_key $SSL_KEY;

  location / {
    proxy_pass http://localhost:8080;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOF

nginx -t && systemctl restart nginx

docker run -d -p 8080:80 --name hello-world nginx

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
curl -s "https://www.duckdns.org/update?domains=$TENANT&token=${duckdns_token}&ip=$${PUBLIC_IP}"

echo "🚀 Userdata completed for $TENANT"
