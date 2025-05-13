#!/bin/bash

# Load SERVER_URL from .env file
if [ -f .env ]; then
    # Use envsubst to handle variable expansion
    export $(cat .env | sed 's/\r$//' | xargs)
fi

if [ -z "$SERVER_URL" ]; then
    echo "Error: SERVER_URL not found in .env file"
    exit 1
fi

# Create certs directory if it doesn't exist and set permissions
sudo mkdir -p certs
sudo chown -R $USER:$USER certs
sudo chmod 755 certs

# Generate private key and certificate with proper DNS names
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout certs/nginx.key \
    -out certs/nginx.crt \
    -subj "/CN=${SERVER_NAME}" \
    -addext "subjectAltName=DNS:localhost,DNS:${SERVER_URL}" \
    -addext "keyUsage=digitalSignature,keyEncipherment" \
    -addext "extendedKeyUsage=serverAuth" || {
        echo "Failed to generate certificates"
        exit 1
    }

# Set appropriate permissions only if files exist
if [ -f certs/nginx.crt ] && [ -f certs/nginx.key ]; then
    sudo chmod 644 certs/nginx.crt
    sudo chmod 600 certs/nginx.key
    echo "SSL certificate generated successfully for ${SERVER_URL}"
else
    echo "Certificate files were not created successfully"
    exit 1
fi

chmod +x generate-certs.sh
